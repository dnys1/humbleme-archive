import { spawn } from "child-process-promise";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as quiz from "./quiz";

admin.initializeApp();

var db = admin.firestore();
var storage = admin.storage();

let NotificationType = {
  NEW_FRIEND_REQUEST: 'NEW_FRIEND_REQUEST',
  NEW_FRIEND: 'NEW_FRIEND',
  NEW_SURVEY: 'NEW_SURVEY',
}

interface NotificationData {
  profile?: string,
  route?: string,
  icon?: string,
}

interface Notification {
  id: string,
  messageId?: string,
  toUser: string,
  type: string,
  data?: NotificationData,
  dateTime: FirebaseFirestore.FieldValue,
  read: boolean,
  notification: admin.messaging.Notification,
}

async function sendPushNotification(
  notification: admin.messaging.Notification,
  token: string,
  notificationCount: number,
  data?: any,
): Promise<string> {
  console.log(`Sending message: ${JSON.stringify(notification)} to ${token} where notifications = ${notificationCount}`);
  let messagePath = await admin
    .messaging()
    .send({
      notification: notification,
      token: token,
      data: {
        // A specific field needed for Android devices
        // See https://github.com/flutter/plugins/tree/master/packages/firebase_messaging
        // This `data` object will overwrite the top-level one so
        // we need to copy its data
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        ...data
      },
      apns: {
        payload: {
          aps: {
            badge: notificationCount
          }
        }
      },
    });
  // Get the message id for this push notification
  return path.basename(messagePath);
}

// Update the categories every time a question is added, updated, or removed
const updateCategories = functions.firestore.document("questions/{questionId}").onWrite(async (snap, context) => {
  let allQuestions = await db.collection('questions').get();
  let categoriesRef = db.collection('global').doc('categories');

  let testTypes: string[] = [];
  allQuestions.forEach((question) => {
    let code: string = question.data().testCode;
    if (testTypes.indexOf(code) === -1) {
      testTypes.push(code);
    }
  });

  // Perform one write to the db using a batch
  let batch = db.batch();
  let numQuestions = {};
  testTypes.forEach((testType) => {
    // Get only the questions for this testType
    let filtered = allQuestions.docs.filter((q) => q.data().testCode as string === testType);
    const numQuestionsPerCategory = filtered.reduce((acc, curr) => {
      let cats = Object.keys(curr.data().categoryWeights);
      for (let cat of cats) {
        if (Object.keys(acc).indexOf(cat) === -1) {
          acc[cat] = 1;
        } else {
          acc[cat]++;
        }
      }
      return acc;
    }, {});

    numQuestions[testType] = filtered.length;

    batch.update(categoriesRef, {
      [testType]: numQuestionsPerCategory,
    });
  });

  batch.update(categoriesRef, {
    numQuestions: numQuestions,
  });

  await batch.commit();
});

// Called whenever a user clicks "Add Friend"
// Will create a new friendRequest object for both users
// toUser = The user receiving the friend request
// fromUser = The user sending the friend request
const addFriend = functions.firestore
  .document("friendRequests/{requestId}")
  .onCreate(async (snap, context) => {
    try {
      // Set the friend request data in toUser
      const toUserId = snap.data().toUser;
      const fromUserId = snap.data().fromUser;

      // Get the name of the person it's from
      const fromUser = await db
        .collection("users")
        .doc(fromUserId)
        .get();
      const name = fromUser.data().displayName as string;

      // Get the notification token of the toUser
      const toUser = await db
        .collection("users")
        .doc(toUserId)
        .get();

      // Do not send if a device hasn't been configured.
      if (!toUser.data().lastUsedDeviceId) {
        console.log(`User ${toUserId} has not logged into a device yet.`);
        return;
      }

      // Get the device-specific token using the lastUsedDevice as the device to send it to
      const deviceId: string = toUser.data().lastUsedDeviceId as string;
      const device = await db.collection("users").doc(toUserId).collection('devices').doc(deviceId).get();
      const token: string = device.data().notificationToken as string;

      // Get or instantiate the notification count (for use in Apple push badges)
      var notificationCount: number = toUser.data().notificationCount as number;
      if (!notificationCount) {
        notificationCount = 0;
      }

      // Send the notification if user has push notifications registered
      notificationCount++;
      let notification: admin.messaging.Notification = {
        title: "Friend Request",
        body: `${name} wants to be your friend!`
      };
      let icon = fromUser.data().photoUrl as string;
      let data: NotificationData = {
        profile: fromUser.id,
        icon: `url:${icon}`,
      }
      let messageId;
      if (token) {
        messageId = await sendPushNotification(
          notification,
          token,
          notificationCount,
          data,
        );
      }
      // Create the notification in the database so we can listen
      let newNotification = db.collection('notifications').doc();
      await newNotification.set(<Notification>{
        id: newNotification.id,
        messageId: messageId ? messageId : null,
        toUser: toUserId,
        notification: notification,
        data: data,
        dateTime: admin.firestore.FieldValue.serverTimestamp(),
        type: NotificationType.NEW_FRIEND_REQUEST,
        read: false,
      });
      // Keep track of notification count in user document to save on queries
      // i.e. could do db.collection('notifications').where('toUser', '==', toUserId).where('read', '==', false)
      // to get notificationCount, but that would eat up a lot of reads.
      await toUser.ref.update(
        {
          notificationCount: notificationCount
        },
      );
    } catch (e) {
      console.log("Error adding friend:", e);
    }
  });

// Called whenever a user accepts a friend request
// Triggered when accepted or denied is changed to `true`
// fromUser = The person who sent the friend request
// toUser = The person accepting the friend request
const acceptFriendRequest = functions.firestore
  .document("/friendRequests/{requestId}")
  .onUpdate(async (change, context) => {
    try {
      // Check to see what has changed. If either accepted or denied changed,
      // then proceed appropriately.
      const accepted =
        !change.before.data().accepted && change.after.data().accepted;
      const denied = change.after.data().denied;

      const toUserId = change.before.data().toUser;
      const fromUserId = change.before.data().fromUser;

      if (accepted) {
        await db.runTransaction(async (tx) => {
          const toUserRef = db.collection('users').doc(toUserId);
          const fromUserRef = db.collection('users').doc(fromUserId);

          const friendshipAlreadyExistsToUser: boolean = (await tx.get(toUserRef.collection('friends').doc(context.params.requestId))).exists;
          const friendshipAlreadyExistsFromUser: boolean = (await tx.get(fromUserRef.collection('friends').doc(context.params.requestId))).exists;

          if (friendshipAlreadyExistsFromUser && friendshipAlreadyExistsToUser) {
            return;
          }

          const toUser = await tx.get(toUserRef);
          const fromUser = await tx.get(fromUserRef);

          // Configure to send them a push notification
          // alerting them that the friend request has
          // been accepted
          if (!fromUser.data().lastUsedDeviceId) {
            console.log(`User ${fromUser.id} has not enabled notifications yet.`);
            return;
          }

          // Get the user's last used device and associated token
          const deviceId: string = fromUser.data().lastUsedDeviceId as string;
          const device = await tx.get(fromUserRef.collection('devices').doc(deviceId));
          const token: string = device.data().notificationToken as string;

          // Get or instantiate the notification count (for use in displaying badge number)
          var notificationCount: number = fromUser.data().notificationCount as number;
          if (!notificationCount) {
            notificationCount = 0;
          }

          const displayName = toUser.data().displayName as string;

          notificationCount++;
          let notification: admin.messaging.Notification = {
            title: "Friend Request",
            body: `${displayName} accepted your friend request!`
          };
          let icon = toUser.data().photoUrl as string;
          let data: NotificationData = {
            profile: toUser.id,
            icon: `url:${icon}`,
          };
          let messageId;
          if (token) {
            messageId = await sendPushNotification(
              notification,
              token,
              notificationCount,
              data,
            );
          }

          let newNotification = db.collection('notifications').doc();
          await tx.set(newNotification, <Notification>{
            id: newNotification.id,
            messageId: messageId ? messageId : null,
            toUser: fromUserId,
            notification: notification,
            data: data,
            dateTime: admin.firestore.FieldValue.serverTimestamp(),
            type: NotificationType.NEW_FRIEND,
            read: false,
          });
          await tx.update(fromUserRef, {
            notificationCount: notificationCount,
          });

          const newFriendshipTime = admin.firestore.FieldValue.serverTimestamp();
          if (!friendshipAlreadyExistsToUser) {
            await tx.create(toUserRef.collection('friends').doc(context.params.requestId), {
              friend: fromUserId,
              dateTime: newFriendshipTime,
            });
          }
          if (!friendshipAlreadyExistsFromUser) {
            await tx.create(fromUserRef.collection('friends').doc(context.params.requestId), {
              friend: toUserId,
              dateTime: newFriendshipTime,
            });
          }

          await tx.delete(change.after.ref);
        });
      } else if (denied) {
        // Do nothing...
        console.log('User denied the friend request...');
      }
    } catch (e) {
      console.log("Error accepting friend request: ", e);
    }
  });

// Is triggered when a new mindset is created
// Sets the weight and ranking to default values
const setMindsetWeights = functions.firestore
  .document("mindsets/{mindsetId}")
  .onCreate((snap, context) => {
    return snap.ref.set({ weight: 1.0, ranking: 0 }, { merge: true });
  });

// DANGEROUS right now
// Can be triggered to reset all the mindeset rankings and weights
const resetWeightsAndRankings = functions.firestore
  .document("mindsets/reset")
  .onCreate(async (snap, context) => {
    var mindsets = await db.collection("mindsets").get();
    for (const mindset of mindsets.docs) {
      await mindset.ref.update({ weight: 1.0 / mindsets.size, ranking: 0 });
    }
    await snap.ref.delete();
  });

// Called every time a user submits their top mindsets
const recordTopMindsets = functions.https
  .onRequest(async (req, resp) => {
    let idToken: string = req.body.idToken as string;

    try {
      // Will throw error if not valid
      await admin.auth().verifyIdToken(idToken);
    } catch (e) {
      resp.status(401);
      resp.send("Unauthorized token request.");
      return null;
    }

    const mindsetRef = db.collection("mindsets");

    try {
      // Run as a transaction because the weights and rankings will
      // be affected during the transaction
      await db.runTransaction(async transaction => {
        const topMindsets = req.body.topMindsets as string[]; // array of Mindset ids
        const mindsets = await transaction.get(mindsetRef);

        // Aggregate the total ranking because a mindset weight
        // is = mindeet ranking / total ranking.
        const totalWeight = mindsets.docs.reduce((acc, curr) => {
          // Check if the current mindset was included
          // in their top mindset choices. If it is
          // incremenet the ranking. If it isn't, return
          // the current ranking
          if (topMindsets.indexOf(curr.id) !== -1) {
            return acc + curr.data().ranking + 1;
          } else {
            return acc + curr.data().ranking;
          }
        }, 0); // end reduce

        // For each mindset, update with the new ranking and weight
        for (var index = 0; index < mindsets.docs.length; index++) {
          var mindset = mindsets.docs[index];
          // If the mindset was included in the top mindsets,
          // set the new ranking and weight
          if (topMindsets.indexOf(mindset.id) !== -1) {
            const ranking = mindset.data().ranking;
            await transaction.update(
              mindset.ref,
              {
                ranking: ranking + 1,
                weight: (ranking + 1) / totalWeight
              }
            );
          }
          // Otherwise, just set the new weight
          else {
            const ranking = mindset.data().ranking;
            await transaction.update(
              mindset.ref,
              {
                weight: ranking / totalWeight
              }
            );
          }
        }
      });
    } catch (err) {
      console.log('Error occurred recording top mindsets: ', err);
      resp.status(500);
      resp.send(err);
    }

    resp.status(200);
    resp.send('Success');
  });

// On self-score received
// Same as onSurveyReceived, but listens for new self-scores
// instead, and calculates the mindset weights from that.
// Does not send notification or deal with surveys.
const calculateSelfScore = async (snap, userId) => {
  try {
    if (!snap.data().self) {
      return;
    }
    // Get all mindsets & their weights
    const mindsetsRef = db.collection('mindsets');
    const userRef = db.collection('users').doc(userId);

    await db.runTransaction(async (tx) => {
      const mindsets = await tx.get(mindsetsRef);
      const mindsetScores = {
        ...snap.data().mindsetWeighted,
      };

      // For each mindset, get all the survey responses for it
      // Aggregate the total and divide by the total number of surveys
      // Then multiply by the weight and add to the total score
      mindsets.forEach(mindset => {
        let mindsetScore = 0;
        let mindsetTotalWeight = 0;
        const mindsetCategoryWeights = mindset.data().categoryWeights;
        const userScores = snap.data().categoryWeighted;
        for (const category of Object.keys(mindsetCategoryWeights)) {
          const categoryScore = userScores[category];
          // If the score is null or 0, do not include
          if (!categoryScore) {
            continue;
          }
          const categoryWeight = mindsetCategoryWeights[category];

          // Get the directionality of the category's weight
          if (Math.sign(categoryWeight) === 1.0) {
            mindsetScore += categoryScore * categoryWeight;
          } else {
            mindsetScore += (6 - categoryScore) * categoryWeight;
          }
          mindsetTotalWeight += Math.abs(categoryWeight);
        }
        if (!mindsetTotalWeight) {
          return;
        }
        mindsetScores[mindset.data().name] = mindsetScore / mindsetTotalWeight;
      });

      const score = mindsets.docs.reduce((acc, curr) => {
        const mindsetScore = mindsetScores[curr.data().name];
        const mindsetWeight = curr.data().weight;
        if (!mindsetScore || !mindsetWeight) {
          return acc;
        }
        return acc + (mindsetScore * mindsetWeight);
      }, 0);

      tx.update(
        snap.ref,
        {
          ...snap.data(),
          mindsetWeighted: mindsetScores,
          score: score,
        }
      );
    });
  } catch (err) {
    console.error('Error calculating mindset scores: ', err);
  }
}

// Called every time a survey is submitted
// toUser - The user being sent the survey
// context.params.userId - The user sending the survey
const onSurveyReceived = functions.firestore
  .document("surveys/{surveyId}")
  .onCreate(async (snap, context) => {
    try {
      const surveyComplete = snap.data().completed;
      if (!surveyComplete) {
        return;
      }

      const userId = snap.data().toUser;

      // Get all the surveys for this user
      var surveys = await db
        .collection("surveys")
        .where('toUser', '==', userId)
        .orderBy('dateTime', 'desc')
        .get();

      // Ensure they have over 5 surveys before calculating a score
      const numSurveys = surveys.docs.length;
      if (numSurveys < 5) {
        return;
      }

      // Get all mindsets & their weights
      const mindsetsRef = db.collection('mindsets');
      const userRef = db.collection('users').doc(userId);
      const user = await userRef.get();
      const latestScores = userRef.collection('scores').doc(surveys.docs[0].id);
      const scores = await latestScores.get();
      // Get the last used device info
      const deviceId: string = user.data().lastUsedDeviceId as string;
      const deviceRef = db.collection("users").doc(user.id).collection('devices').doc(deviceId);
      const device = await deviceRef.get();

      await db.runTransaction(async (tx) => {
        const mindsets = await tx.get(mindsetsRef);
        const mindsetScores = {
          ...scores.data().mindsetWeighted,
        };

        // For each mindset, get all the survey responses for it
        // Aggregate the total and divide by the total number of surveys
        // Then multiply by the weight and add to the total score
        mindsets.forEach(mindset => {
          let mindsetScore = 0;
          let mindsetTotalWeight = 0;
          const mindsetCategoryWeights = mindset.data().categoryWeights;
          const userScores = scores.data().categoryWeighted;
          for (const category of Object.keys(mindsetCategoryWeights)) {
            const categoryScore = userScores[category];
            // If the score is null or 0, do not include
            if (!categoryScore) {
              continue;
            }
            const categoryWeight = mindsetCategoryWeights[category];

            // Get the directionality of the category's weight
            if (Math.sign(categoryWeight) === 1.0) {
              mindsetScore += categoryScore * categoryWeight;
            } else {
              mindsetScore += (6 - categoryScore) * categoryWeight;
            }
            mindsetTotalWeight += Math.abs(categoryWeight);
          }
          if (!mindsetTotalWeight) {
            return;
          }
          mindsetScores[mindset.data().name] = mindsetScore / mindsetTotalWeight;
        });

        const score = mindsets.docs.reduce((acc, curr) => {
          const mindsetScore = mindsetScores[curr.data().name];
          const mindsetWeight = curr.data().weight;
          if (!mindsetScore || !mindsetWeight) {
            return acc;
          }
          return acc + (mindsetScore * mindsetWeight);
        }, 0);

        // Set the new score for the user
        tx.update(
          userRef,
          {
            score: score
          }
        );

        tx.update(
          latestScores,
          {
            ...scores.data(),
            mindsetWeighted: mindsetScores,
            score: score,
          }
        );

        let notificationCount: number = user.data().notificationCount as number;

        if (!notificationCount) {
          notificationCount = 0;
        }

        // Send them a notification
        let notificationsRef = db.collection('notifications');
        notificationCount++;
        let notification: admin.messaging.Notification = {
          title: "New Survey",
          body: "You've received a new survey!"
        };
        let data: NotificationData = {
          route: '/app/profile/scores',
          icon: 'icon:multiline_chart',
        };

        let messageId;
        if (device.exists) {
          try {
            const token: string = device.data().notificationToken as string;
            if (token) {
              messageId = await sendPushNotification(
                notification,
                token,
                notificationCount,
                data,
              );
            }
          } catch (err) {
            console.error('Error sending notification: ', err);
          }
        }

        const newNotification = notificationsRef.doc();
        tx.create(
          newNotification,
          <Notification>{
            id: newNotification.id,
            messageId: messageId ? messageId : null,
            toUser: userId,
            notification: notification,
            data: data,
            dateTime: admin.firestore.FieldValue.serverTimestamp(),
            type: NotificationType.NEW_SURVEY,
            read: false,
          }
        );
        tx.update(
          userRef,
          {
            notificationCount: notificationCount
          }
        );
      });
    } catch (e) {
      console.error('Error occurred in onSurveyReceived: ', e);
    }
  });


// Delete all references to the user when user account is deleted
const onUserDelete = functions.auth.user().onDelete(async (user, context) => {
  const uid = user.uid;
  const userRef = db.collection('users').doc(uid);
  const collections = await userRef.getCollections();

  // Firestore transactions require all reads to be executed before all writes.
  await db.runTransaction(async (tx) => {
    let refs = [];
    for (let collection of collections) {
      let snap = await tx.get(collection);
      refs.push(...snap.docs.map((doc) => doc.ref));
    }

    const friendships = await tx.get(userRef.collection('friends'));
    const friendRequestsSent = await tx.get(db.collection('friendRequests').where('fromUser', '==', uid));
    const friendRequestsReceived = await tx.get(db.collection('friendRequests').where('toUser', '==', uid));
    const notifications = await tx.get(db.collection('notifications').where('toUser', '==', uid));

    for (let request of friendRequestsSent.docs) {
      refs.push(request.ref);
    }

    for (let request of friendRequestsReceived.docs) {
      refs.push(request.ref);
    }

    for (let notification of notifications.docs) {
      refs.push(notification.ref);
    }

    // Delete all the friendships for both users
    friendships.forEach((friendship) => {
      const friendId = friendship.data().friend;
      tx.delete(db.collection('users').doc(friendId).collection('friends').doc(friendship.id));
    });

    // Delete all documents in all subcollections
    refs.forEach(ref => tx.delete(ref));
    // Finally, delete the user
    tx.delete(userRef);
  });
});

interface ProfilePicture {
  name: string,
  timeCreated: string,
}

const getProfilePictures = functions.https.onRequest(async (req, resp) => {
  let idToken: string = req.body.idToken as string;

  try {
    // Will throw error if not valid
    await admin.auth().verifyIdToken(idToken);
  } catch (e) {
    resp.status(401);
    resp.send("Unauthorized token request.");
    return null;
  }

  let storage = admin.storage();
  let uid: string = req.body.uid;

  let files = await storage.bucket().getFiles({
    prefix: `${uid}/profilePicture/`,
  });

  let photos: ProfilePicture[] = [];
  files["0"].forEach((file) => {
    let metadata = file.metadata;
    let name: string = metadata["name"];
    // null if no match
    if (name.match(new RegExp('/thumb_'))) {
      console.log('Not a thumb: ', name);
      return;
    }
    let timeCreated = metadata["timeCreated"];
    photos.push({
      name: name,
      timeCreated: timeCreated,
    });
  });

  photos.sort((a, b) => {
    // Newest photos come first
    if (a.timeCreated < b.timeCreated) {
      return -1;
    } else {
      return 1;
    }
  });

  resp.status(200);
  resp.send(JSON.stringify(photos));
});

const profileImageUpload = async object => {
  const fileBucket: string = object.bucket;
  const filePath: string = object.name;
  const extension: string = path.extname(filePath);

  let contentType: string;
  switch (extension) {
    case ".jpg":
    case ".jpeg":
      contentType = "image/jpeg";
      break;
    case ".png":
      contentType = "image/png";
      break;
    case ".gif":
      contentType = "image/gif";
      break;
    case ".bmp":
      contentType = "image/bmp";
      break;
    default:
      contentType = object.contentType;
      break;
  }

  if (!contentType.startsWith("image/")) {
    console.log("This file is not an image.");
    return;
  }

  const fileName = path.basename(filePath);
  if (fileName.startsWith("thumb_")) {
    console.log("Already a thumbnail.");
    return;
  }

  const bucket = storage.bucket(fileBucket);

  // Update the storage type on the main image.
  await bucket.file(object.name).setMetadata({
    contentType: contentType,
  });

  // Download file from bucket
  const tempFilePath = path.join(os.tmpdir(), fileName);
  const metadata = {
    contentType: contentType
  };
  var thumbFilePath;

  await bucket.file(filePath).download({
    destination: tempFilePath
  });

  console.log("Image downloaded locally to", tempFilePath);
  await spawn("convert", [
    tempFilePath,
    "-thumbnail",
    "200x200^",
    "-gravity",
    "center",
    "-extent",
    "200x200",
    tempFilePath
  ]);

  console.log("Thumbnail created at", tempFilePath);
  const thumbFileName = `thumb_${fileName}`;
  thumbFilePath = path.join(path.dirname(filePath), thumbFileName);
  // Upload the thumbnail
  await bucket.upload(tempFilePath, {
    destination: thumbFilePath,
    metadata: metadata
  });

  await bucket.file(filePath).makePublic();
  await bucket.file(thumbFilePath).makePublic();

  // Make sure we're uploading to the correct storage bucket
  // Right now a flag exists in both databases to distinguish
  // between the test and regular DB
  const isTest = await db.collection('global').doc('isTest').get();
  const isTestBool = isTest.data().isTest as boolean;
  const urlPrefix = isTestBool ? 'https://storage.googleapis.com/hmflutter-test.appspot.com/' : 'https://storage.googleapis.com/hmflutter.appspot.com/';

  const userId = path.dirname(filePath).split("/")[0];
  const userRef = db.collection('users').doc(userId);
  const userData = (await userRef.get()).data();
  const thumbnailUrl = `${urlPrefix}${thumbFilePath}`;
  const originalUrl = `${urlPrefix}${filePath}`;

  let oldPhotoUrls: string[] = userData.profilePictures as string[];
  let newPhotoUrls: string[];

  // If there is no current array of profile pictures
  if (!oldPhotoUrls) {
    let photoUrl: string = userData.photoUrl;
    // But there is a link for photoUrl
    if (photoUrl) {
      // This will be the thumbnail url. Get the url for the original
      let oldThumbnailName: string = path.basename(photoUrl);
      if (oldThumbnailName.startsWith('thumb_')) {
        oldThumbnailName = oldThumbnailName.substring('thumb_'.length);
      }
      let oldOriginalStoragePath: string = `${userId}/profilePicture/${oldThumbnailName}`;
      // Make sure the original is public
      await bucket.file(oldOriginalStoragePath).makePublic();
      let oldOriginalUrl: string = `${urlPrefix}${oldOriginalStoragePath}`;
      newPhotoUrls = [originalUrl, oldOriginalUrl];
    }
    // There is no array nor link for photoUrl
    else {
      newPhotoUrls = [originalUrl];
    }
  }
  // Otherwise, add the new url to the array
  else {
    newPhotoUrls = [originalUrl, ...oldPhotoUrls];
  }

  // Update user information
  await admin.auth().updateUser(userId, {
    photoURL: thumbnailUrl,
  });

  await db
    .collection("users")
    .doc(userId)
    .update(
      {
        profilePictures: newPhotoUrls,
        photoUrl: thumbnailUrl,
      }
    );

  await fs.unlinkSync(tempFilePath);
}

// TODO: Finish identity verification
const identityVerificationUpload = async object => {
  const fileBucket = object.bucket;
}

// Called every time a profile picture is uploaded
// 1) Converts the image to a thumbnail,
// 2) Uploads it to the storage bucket, and
// 3) Sets the user's photo url
const onImageUpload = functions.storage
  .object()
  .onFinalize(async object => {
    // If not a profile picture, return
    if (object.name.indexOf('profilePicture') !== -1) {
      return await profileImageUpload(object);
    } else if (object.name.indexOf('verification') !== -1) {
      return await identityVerificationUpload(object);
    } else {
      console.log("Cannot determine file's purpose. Aborting.");
      return;
    }
  });

const findFriends = functions.https.onRequest(async (req, resp) => {
  let idToken = req.body.idToken as string;

  try {
    await admin.auth().verifyIdToken(idToken);
  } catch {
    resp.status(401);
    resp.send("Unauthorized token request.");
    return;
  }

  let numbers = req.body.numbers as string[];
  let uid = req.body.uid as string;

  numbers = numbers.map((number) => {
    // Get all the numbers in the string
    // i.e. (480) 720-2332 ==> 4807202332
    let regexd = number.match(/\d/g).join('');

    // Get the last 10 digits.
    if (regexd.length > 10) {
      if (regexd[0] !== '1') {
        console.error(`Bad number: ${regexd}`);
        return null;
      }
      return regexd.substr(regexd.length - 10);
    }
    return regexd;
  }).filter((num) => num != null);

  let collection = await db.collection('users').get();

  var findFriendsArr = [];
  collection.docs.forEach((doc) => {
    // Don't return the own user's profile
    if (doc.id === uid) {
      return;
    }

    let number: string = doc.data().phoneNumber;
    if (number) {
      number = number.match(/\d/g).join('');

      // Get the last 10 digits for numbers prefixed with 1
      if (number.length > 10) {
        if (number[0] !== '1') {
          console.error(`Bad number: ${number}`);
          throw 'Non-US numbers are not allowed!';
        }
        number = number.substr(number.length - 10);
      }

      if (numbers.indexOf(number) !== -1) {
        findFriendsArr.push(doc.id);
      }
    }
  });

  resp.status(200);
  resp.send(JSON.stringify(findFriendsArr));
});

// Request object should be in form:
// {
//  idToken: "blahblah",
//  testCode: "MACHIV",
//  length: 20, // must be greater than or equal to numCategories
//  forType: 'self' || 'personal' || 'professional'
// }
const getQuiz = functions.https.onRequest(async (req, resp) => {
  let idToken: string = req.body.idToken as string;

  try {
    // Will throw error if not valid
    await admin.auth().verifyIdToken(idToken);
  } catch (e) {
    resp.status(401);
    resp.send("Unauthorized token request.");
    return null;
  }

  // Id token is valid. Build and return the survey.
  let questionSet: string = req.body.questionSet;
  let testType: string = req.body.testType as string;
  let questions: FirebaseFirestore.DocumentData[] = [];
  try {
    switch (questionSet) {
      case "MACHIV":
        questions = await quiz.mach.get(db, testType);
        break;
      case "NPI":
        questions = await quiz.npi.get(db, testType);
        break;
      case "OHBDS":
        questions = await quiz.ohbds.get(db, testType);
        break;
      case "IPIP":
        questions = await quiz.ipip.get(db, testType);
        break;
      default:
        resp.status(400);
        resp.send("Bad request. questionSet not included in request.");
        return null;
    }
  } catch (e) {
    resp.status(500);
    resp.send(`Unknown error occured: ${e}}`);
    return null;
  }

  resp.status(200);
  resp.send(JSON.stringify({
    questions: questions,
  }));
});

const submitQuiz = functions.https.onRequest(async (req, resp) => {
  // Check to make sure request is valid with Auth token
  let idToken: string = req.body.idToken as string;
  let uid: string;

  try {
    // Will throw error if not valid
    let verified = await admin.auth().verifyIdToken(idToken);
    uid = verified.uid;
  } catch (e) {
    resp.status(401);
    resp.send("Unauthorized token request.");
  }

  const surveyInfo: quiz.SurveyInfo = req.body.surveyInfo as quiz.SurveyInfo;
  let forUser: string = req.body.forUser as string;
  const isSelfAssessment: boolean = req.body.isSelfAssessment as boolean;
  let answers: Array<quiz.Answer> = req.body.answers as Array<quiz.Answer>;

  console.log(`User ${uid} is submitting quiz for ${forUser}`);

  if (!surveyInfo || !answers) {
    console.error('questionSet and answers must be non-null.');
    resp.status(500);
    resp.send('surveyInfo and answers must be non-null.');
  }

  if (!isSelfAssessment) {
    const userExists = (await db.collection('users').doc(forUser).get()).exists;
    if (!userExists) {
      console.log('User not found in DB: ', forUser);
      resp.status(500);
      resp.send('User not found in DB');
    }
  } else {
    forUser = uid;
  }

  try {
    await quiz.submit(surveyInfo, db, uid, forUser, answers);

    // Calculate question set scores for these three sets
    // MACHIV, OHBDS, NPI,
    // To compare against data from openpsychometrics.org
    if (isSelfAssessment) {
      const query = await db.collection('users').doc(uid).collection('scores').where('self', '==', true).orderBy('dateTime', 'desc').limit(1).get();
      const currentScores = query.docs[0];

      let score: number;
      switch (surveyInfo.questionSet) {
        case "MACHIV":
          score = quiz.mach.score(answers);
          break;
        case "OHBDS":
          score = quiz.ohbds.score(answers);
          break;
        case "NPI":
          score = quiz.npi.score(answers);
          break;
        default:
          await calculateSelfScore(currentScores, uid);
          resp.status(200);
          resp.send(true);
          return;
      }

      let questionSetWeighted = {
        ...currentScores.data().questionSetWeighted,
        [surveyInfo.questionSet]: score,
      };
      await currentScores.ref.update({
        questionSetWeighted: questionSetWeighted,
      });
    }

    resp.status(200);
    resp.send(true);
  } catch (e) {
    console.log('Error occurred: ', e);
    resp.status(500);
    resp.send(e.toString());
    return;
  }
});

interface Friend {
  id: string,
  displayName: string,
  photoUrl: string,
  dateTime: Date,
}

const getUsersFriendList = functions.https.onRequest(async (req, resp) => {
  let idToken: string = req.body.idToken as string;

  try {
    await admin.auth().verifyIdToken(idToken);
  } catch (e) {
    resp.status(401);
    resp.send('Unauthorized token request');
    return null;
  }

  try {
    let uid: string = req.body.uid as string;

    let list = await db.collection('users').doc(uid).collection('friends').orderBy('dateTime').get();

    let friendArr: Friend[] = [];
    for (let doc of list.docs) {
      let friendId = doc.data().friend;
      let friendDoc = await db.collection('users').doc(friendId).get();
      friendArr.push(<Friend>{
        id: friendDoc.id,
        displayName: friendDoc.data().displayName,
        photoUrl: friendDoc.data().photoUrl,
        dateTime: doc.data().dateTime,
      });
    }

    resp.status(200);
    resp.send(JSON.stringify(friendArr));
  } catch (e) {
    console.log(`Unknown error occurred: ${e}`);
    resp.status(500);
    resp.send(e);
  }
});

const isPhoneVerified = functions.https.onRequest(async (req, resp) => {
  let idToken: string = req.body.idToken as string;
  let uid: string;

  try {
    // Will throw error if not valid
    let verified = await admin.auth().verifyIdToken(idToken);
    uid = verified.uid;
  } catch (e) {
    resp.status(401);
    resp.send("Unauthorized token request.");
    return null;
  }

  let user = await admin.auth().getUser(uid);

  resp.status(200);
  resp.send(user.phoneNumber != null);
});

export { setMindsetWeights, onSurveyReceived, recordTopMindsets, onImageUpload, addFriend, acceptFriendRequest, resetWeightsAndRankings, findFriends, onUserDelete, getQuiz, submitQuiz, isPhoneVerified, updateCategories, getUsersFriendList, getProfilePictures };

