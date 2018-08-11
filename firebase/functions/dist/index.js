"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const child_process_promise_1 = require("child-process-promise");
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const fs = require("fs");
const os = require("os");
const path = require("path");
const quiz = require("./quiz");
admin.initializeApp();
var db = admin.firestore();
var storage = admin.storage();
let NotificationType = {
    NEW_FRIEND_REQUEST: 'NEW_FRIEND_REQUEST',
    NEW_FRIEND: 'NEW_FRIEND',
    NEW_SURVEY: 'NEW_SURVEY',
};
function sendPushNotification(notification, token, notificationCount, data) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log(`Sending message: ${JSON.stringify(notification)} to ${token} where notifications = ${notificationCount}`);
        let messagePath = yield admin
            .messaging()
            .send({
            notification: notification,
            token: token,
            data: Object.assign({ 
                // A specific field needed for Android devices
                // See https://github.com/flutter/plugins/tree/master/packages/firebase_messaging
                // This `data` object will overwrite the top-level one so
                // we need to copy its data
                click_action: "FLUTTER_NOTIFICATION_CLICK" }, data),
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
    });
}
// Update the categories every time a question is added, updated, or removed
const updateCategories = functions.firestore.document("questions/{questionId}").onWrite((snap, context) => __awaiter(this, void 0, void 0, function* () {
    let allQuestions = yield db.collection('questions').get();
    let categoriesRef = db.collection('global').doc('categories');
    let testTypes = [];
    allQuestions.forEach((question) => {
        let code = question.data().testCode;
        if (testTypes.indexOf(code) === -1) {
            testTypes.push(code);
        }
    });
    // Perform one write to the db using a batch
    let batch = db.batch();
    let numQuestions = {};
    testTypes.forEach((testType) => {
        // Get only the questions for this testType
        let filtered = allQuestions.docs.filter((q) => q.data().testCode === testType);
        const numQuestionsPerCategory = filtered.reduce((acc, curr) => {
            let cats = Object.keys(curr.data().categoryWeights);
            for (let cat of cats) {
                if (Object.keys(acc).indexOf(cat) === -1) {
                    acc[cat] = 1;
                }
                else {
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
    yield batch.commit();
}));
exports.updateCategories = updateCategories;
// Called whenever a user clicks "Add Friend"
// Will create a new friendRequest object for both users
// toUser = The user receiving the friend request
// fromUser = The user sending the friend request
const addFriend = functions.firestore
    .document("friendRequests/{requestId}")
    .onCreate((snap, context) => __awaiter(this, void 0, void 0, function* () {
    try {
        // Set the friend request data in toUser
        const toUserId = snap.data().toUser;
        const fromUserId = snap.data().fromUser;
        // Get the name of the person it's from
        const fromUser = yield db
            .collection("users")
            .doc(fromUserId)
            .get();
        const name = fromUser.data().displayName;
        // Get the notification token of the toUser
        const toUser = yield db
            .collection("users")
            .doc(toUserId)
            .get();
        // Do not send if a device hasn't been configured.
        if (!toUser.data().lastUsedDeviceId) {
            console.log(`User ${toUserId} has not logged into a device yet.`);
            return;
        }
        // Get the device-specific token using the lastUsedDevice as the device to send it to
        const deviceId = toUser.data().lastUsedDeviceId;
        const device = yield db.collection("users").doc(toUserId).collection('devices').doc(deviceId).get();
        const token = device.data().notificationToken;
        // Get or instantiate the notification count (for use in Apple push badges)
        var notificationCount = toUser.data().notificationCount;
        if (!notificationCount) {
            notificationCount = 0;
        }
        // Send the notification if user has push notifications registered
        notificationCount++;
        let notification = {
            title: "Friend Request",
            body: `${name} wants to be your friend!`
        };
        let icon = fromUser.data().photoUrl;
        let data = {
            profile: fromUser.id,
            icon: `url:${icon}`,
        };
        let messageId;
        if (token) {
            messageId = yield sendPushNotification(notification, token, notificationCount, data);
        }
        // Create the notification in the database so we can listen
        let newNotification = db.collection('notifications').doc();
        yield newNotification.set({
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
        yield toUser.ref.update({
            notificationCount: notificationCount
        });
    }
    catch (e) {
        console.log("Error adding friend:", e);
    }
}));
exports.addFriend = addFriend;
// Called whenever a user accepts a friend request
// Triggered when accepted or denied is changed to `true`
// fromUser = The person who sent the friend request
// toUser = The person accepting the friend request
const acceptFriendRequest = functions.firestore
    .document("/friendRequests/{requestId}")
    .onUpdate((change, context) => __awaiter(this, void 0, void 0, function* () {
    try {
        // Check to see what has changed. If either accepted or denied changed,
        // then proceed appropriately.
        const accepted = !change.before.data().accepted && change.after.data().accepted;
        const denied = change.after.data().denied;
        const toUserId = change.before.data().toUser;
        const fromUserId = change.before.data().fromUser;
        if (accepted) {
            yield db.runTransaction((tx) => __awaiter(this, void 0, void 0, function* () {
                const toUserRef = db.collection('users').doc(toUserId);
                const fromUserRef = db.collection('users').doc(fromUserId);
                const friendshipAlreadyExistsToUser = (yield tx.get(toUserRef.collection('friends').doc(context.params.requestId))).exists;
                const friendshipAlreadyExistsFromUser = (yield tx.get(fromUserRef.collection('friends').doc(context.params.requestId))).exists;
                if (friendshipAlreadyExistsFromUser && friendshipAlreadyExistsToUser) {
                    return;
                }
                const toUser = yield tx.get(toUserRef);
                const fromUser = yield tx.get(fromUserRef);
                // Configure to send them a push notification
                // alerting them that the friend request has
                // been accepted
                if (!fromUser.data().lastUsedDeviceId) {
                    console.log(`User ${fromUser.id} has not enabled notifications yet.`);
                    return;
                }
                // Get the user's last used device and associated token
                const deviceId = fromUser.data().lastUsedDeviceId;
                const device = yield tx.get(fromUserRef.collection('devices').doc(deviceId));
                const token = device.data().notificationToken;
                // Get or instantiate the notification count (for use in displaying badge number)
                var notificationCount = fromUser.data().notificationCount;
                if (!notificationCount) {
                    notificationCount = 0;
                }
                const displayName = toUser.data().displayName;
                notificationCount++;
                let notification = {
                    title: "Friend Request",
                    body: `${displayName} accepted your friend request!`
                };
                let icon = toUser.data().photoUrl;
                let data = {
                    profile: toUser.id,
                    icon: `url:${icon}`,
                };
                let messageId;
                if (token) {
                    messageId = yield sendPushNotification(notification, token, notificationCount, data);
                }
                let newNotification = db.collection('notifications').doc();
                yield tx.set(newNotification, {
                    id: newNotification.id,
                    messageId: messageId ? messageId : null,
                    toUser: fromUserId,
                    notification: notification,
                    data: data,
                    dateTime: admin.firestore.FieldValue.serverTimestamp(),
                    type: NotificationType.NEW_FRIEND,
                    read: false,
                });
                yield tx.update(fromUserRef, {
                    notificationCount: notificationCount,
                });
                const newFriendshipTime = admin.firestore.FieldValue.serverTimestamp();
                if (!friendshipAlreadyExistsToUser) {
                    yield tx.create(toUserRef.collection('friends').doc(context.params.requestId), {
                        friend: fromUserId,
                        dateTime: newFriendshipTime,
                    });
                }
                if (!friendshipAlreadyExistsFromUser) {
                    yield tx.create(fromUserRef.collection('friends').doc(context.params.requestId), {
                        friend: toUserId,
                        dateTime: newFriendshipTime,
                    });
                }
                yield tx.delete(change.after.ref);
            }));
        }
        else if (denied) {
            // Do nothing...
            console.log('User denied the friend request...');
        }
    }
    catch (e) {
        console.log("Error accepting friend request: ", e);
    }
}));
exports.acceptFriendRequest = acceptFriendRequest;
// Is triggered when a new mindset is created
// Sets the weight and ranking to default values
const setMindsetWeights = functions.firestore
    .document("mindsets/{mindsetId}")
    .onCreate((snap, context) => {
    return snap.ref.set({ weight: 1.0, ranking: 0 }, { merge: true });
});
exports.setMindsetWeights = setMindsetWeights;
// DANGEROUS right now
// Can be triggered to reset all the mindeset rankings and weights
const resetWeightsAndRankings = functions.firestore
    .document("mindsets/reset")
    .onCreate((snap, context) => __awaiter(this, void 0, void 0, function* () {
    var mindsets = yield db.collection("mindsets").get();
    for (const mindset of mindsets.docs) {
        yield mindset.ref.update({ weight: 1.0 / mindsets.size, ranking: 0 });
    }
    yield snap.ref.delete();
}));
exports.resetWeightsAndRankings = resetWeightsAndRankings;
// Called every time a user submits their top mindsets
const recordTopMindsets = functions.https
    .onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    try {
        // Will throw error if not valid
        yield admin.auth().verifyIdToken(idToken);
    }
    catch (e) {
        resp.status(401);
        resp.send("Unauthorized token request.");
        return null;
    }
    const mindsetRef = db.collection("mindsets");
    try {
        // Run as a transaction because the weights and rankings will
        // be affected during the transaction
        yield db.runTransaction((transaction) => __awaiter(this, void 0, void 0, function* () {
            const topMindsets = req.body.topMindsets; // array of Mindset ids
            const mindsets = yield transaction.get(mindsetRef);
            // Aggregate the total ranking because a mindset weight
            // is = mindeet ranking / total ranking.
            const totalWeight = mindsets.docs.reduce((acc, curr) => {
                // Check if the current mindset was included
                // in their top mindset choices. If it is
                // incremenet the ranking. If it isn't, return
                // the current ranking
                if (topMindsets.indexOf(curr.id) !== -1) {
                    return acc + curr.data().ranking + 1;
                }
                else {
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
                    yield transaction.update(mindset.ref, {
                        ranking: ranking + 1,
                        weight: (ranking + 1) / totalWeight
                    });
                }
                else {
                    const ranking = mindset.data().ranking;
                    yield transaction.update(mindset.ref, {
                        weight: ranking / totalWeight
                    });
                }
            }
        }));
    }
    catch (err) {
        console.log('Error occurred recording top mindsets: ', err);
        resp.status(500);
        resp.send(err);
    }
    resp.status(200);
    resp.send('Success');
}));
exports.recordTopMindsets = recordTopMindsets;
// On self-score received
// Same as onSurveyReceived, but listens for new self-scores
// instead, and calculates the mindset weights from that.
// Does not send notification or deal with surveys.
const calculateSelfScore = (snap, userId) => __awaiter(this, void 0, void 0, function* () {
    try {
        if (!snap.data().self) {
            return;
        }
        // Get all mindsets & their weights
        const mindsetsRef = db.collection('mindsets');
        const userRef = db.collection('users').doc(userId);
        yield db.runTransaction((tx) => __awaiter(this, void 0, void 0, function* () {
            const mindsets = yield tx.get(mindsetsRef);
            const mindsetScores = Object.assign({}, snap.data().mindsetWeighted);
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
                    }
                    else {
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
            tx.update(snap.ref, Object.assign({}, snap.data(), { mindsetWeighted: mindsetScores, score: score }));
        }));
    }
    catch (err) {
        console.error('Error calculating mindset scores: ', err);
    }
});
// Called every time a survey is submitted
// toUser - The user being sent the survey
// context.params.userId - The user sending the survey
const onSurveyReceived = functions.firestore
    .document("surveys/{surveyId}")
    .onCreate((snap, context) => __awaiter(this, void 0, void 0, function* () {
    try {
        const surveyComplete = snap.data().completed;
        if (!surveyComplete) {
            return;
        }
        const userId = snap.data().toUser;
        // Get all the surveys for this user
        var surveys = yield db
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
        const user = yield userRef.get();
        const latestScores = userRef.collection('scores').doc(surveys.docs[0].id);
        const scores = yield latestScores.get();
        // Get the last used device info
        const deviceId = user.data().lastUsedDeviceId;
        const deviceRef = db.collection("users").doc(user.id).collection('devices').doc(deviceId);
        const device = yield deviceRef.get();
        yield db.runTransaction((tx) => __awaiter(this, void 0, void 0, function* () {
            const mindsets = yield tx.get(mindsetsRef);
            const mindsetScores = Object.assign({}, scores.data().mindsetWeighted);
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
                    }
                    else {
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
            tx.update(userRef, {
                score: score
            });
            tx.update(latestScores, Object.assign({}, scores.data(), { mindsetWeighted: mindsetScores, score: score }));
            let notificationCount = user.data().notificationCount;
            if (!notificationCount) {
                notificationCount = 0;
            }
            // Send them a notification
            let notificationsRef = db.collection('notifications');
            notificationCount++;
            let notification = {
                title: "New Survey",
                body: "You've received a new survey!"
            };
            let data = {
                route: '/app/profile/scores',
                icon: 'icon:multiline_chart',
            };
            let messageId;
            if (device.exists) {
                try {
                    const token = device.data().notificationToken;
                    if (token) {
                        messageId = yield sendPushNotification(notification, token, notificationCount, data);
                    }
                }
                catch (err) {
                    console.error('Error sending notification: ', err);
                }
            }
            const newNotification = notificationsRef.doc();
            tx.create(newNotification, {
                id: newNotification.id,
                messageId: messageId ? messageId : null,
                toUser: userId,
                notification: notification,
                data: data,
                dateTime: admin.firestore.FieldValue.serverTimestamp(),
                type: NotificationType.NEW_SURVEY,
                read: false,
            });
            tx.update(userRef, {
                notificationCount: notificationCount
            });
        }));
    }
    catch (e) {
        console.error('Error occurred in onSurveyReceived: ', e);
    }
}));
exports.onSurveyReceived = onSurveyReceived;
// Delete all references to the user when user account is deleted
const onUserDelete = functions.auth.user().onDelete((user, context) => __awaiter(this, void 0, void 0, function* () {
    const uid = user.uid;
    const userRef = db.collection('users').doc(uid);
    const collections = yield userRef.getCollections();
    // Firestore transactions require all reads to be executed before all writes.
    yield db.runTransaction((tx) => __awaiter(this, void 0, void 0, function* () {
        let refs = [];
        for (let collection of collections) {
            let snap = yield tx.get(collection);
            refs.push(...snap.docs.map((doc) => doc.ref));
        }
        const friendships = yield tx.get(userRef.collection('friends'));
        const friendRequestsSent = yield tx.get(db.collection('friendRequests').where('fromUser', '==', uid));
        const friendRequestsReceived = yield tx.get(db.collection('friendRequests').where('toUser', '==', uid));
        const notifications = yield tx.get(db.collection('notifications').where('toUser', '==', uid));
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
    }));
}));
exports.onUserDelete = onUserDelete;
const getProfilePictures = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    try {
        // Will throw error if not valid
        yield admin.auth().verifyIdToken(idToken);
    }
    catch (e) {
        resp.status(401);
        resp.send("Unauthorized token request.");
        return null;
    }
    let storage = admin.storage();
    let uid = req.body.uid;
    let files = yield storage.bucket().getFiles({
        prefix: `${uid}/profilePicture/`,
    });
    let photos = [];
    files["0"].forEach((file) => {
        let metadata = file.metadata;
        let name = metadata["name"];
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
        }
        else {
            return 1;
        }
    });
    resp.status(200);
    resp.send(JSON.stringify(photos));
}));
exports.getProfilePictures = getProfilePictures;
const profileImageUpload = (object) => __awaiter(this, void 0, void 0, function* () {
    const fileBucket = object.bucket;
    const filePath = object.name;
    const extension = path.extname(filePath);
    let contentType;
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
    yield bucket.file(object.name).setMetadata({
        contentType: contentType,
    });
    // Download file from bucket
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const metadata = {
        contentType: contentType
    };
    var thumbFilePath;
    yield bucket.file(filePath).download({
        destination: tempFilePath
    });
    console.log("Image downloaded locally to", tempFilePath);
    yield child_process_promise_1.spawn("convert", [
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
    yield bucket.upload(tempFilePath, {
        destination: thumbFilePath,
        metadata: metadata
    });
    yield bucket.file(filePath).makePublic();
    yield bucket.file(thumbFilePath).makePublic();
    // Make sure we're uploading to the correct storage bucket
    // Right now a flag exists in both databases to distinguish
    // between the test and regular DB
    const isTest = yield db.collection('global').doc('isTest').get();
    const isTestBool = isTest.data().isTest;
    const urlPrefix = isTestBool ? 'https://storage.googleapis.com/hmflutter-test.appspot.com/' : 'https://storage.googleapis.com/hmflutter.appspot.com/';
    const userId = path.dirname(filePath).split("/")[0];
    const userRef = db.collection('users').doc(userId);
    const userData = (yield userRef.get()).data();
    const thumbnailUrl = `${urlPrefix}${thumbFilePath}`;
    const originalUrl = `${urlPrefix}${filePath}`;
    let oldPhotoUrls = userData.profilePictures;
    let newPhotoUrls;
    // If there is no current array of profile pictures
    if (!oldPhotoUrls) {
        let photoUrl = userData.photoUrl;
        // But there is a link for photoUrl
        if (photoUrl) {
            // This will be the thumbnail url. Get the url for the original
            let oldThumbnailName = path.basename(photoUrl);
            if (oldThumbnailName.startsWith('thumb_')) {
                oldThumbnailName = oldThumbnailName.substring('thumb_'.length);
            }
            let oldOriginalStoragePath = `${userId}/profilePicture/${oldThumbnailName}`;
            // Make sure the original is public
            yield bucket.file(oldOriginalStoragePath).makePublic();
            let oldOriginalUrl = `${urlPrefix}${oldOriginalStoragePath}`;
            newPhotoUrls = [originalUrl, oldOriginalUrl];
        }
        else {
            newPhotoUrls = [originalUrl];
        }
    }
    else {
        newPhotoUrls = [originalUrl, ...oldPhotoUrls];
    }
    // Update user information
    yield admin.auth().updateUser(userId, {
        photoURL: thumbnailUrl,
    });
    yield db
        .collection("users")
        .doc(userId)
        .update({
        profilePictures: newPhotoUrls,
        photoUrl: thumbnailUrl,
    });
    yield fs.unlinkSync(tempFilePath);
});
// TODO: Finish identity verification
const identityVerificationUpload = (object) => __awaiter(this, void 0, void 0, function* () {
    const fileBucket = object.bucket;
});
// Called every time a profile picture is uploaded
// 1) Converts the image to a thumbnail,
// 2) Uploads it to the storage bucket, and
// 3) Sets the user's photo url
const onImageUpload = functions.storage
    .object()
    .onFinalize((object) => __awaiter(this, void 0, void 0, function* () {
    // If not a profile picture, return
    if (object.name.indexOf('profilePicture') !== -1) {
        return yield profileImageUpload(object);
    }
    else if (object.name.indexOf('verification') !== -1) {
        return yield identityVerificationUpload(object);
    }
    else {
        console.log("Cannot determine file's purpose. Aborting.");
        return;
    }
}));
exports.onImageUpload = onImageUpload;
const findFriends = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    try {
        yield admin.auth().verifyIdToken(idToken);
    }
    catch (_a) {
        resp.status(401);
        resp.send("Unauthorized token request.");
        return;
    }
    let numbers = req.body.numbers;
    let uid = req.body.uid;
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
    let collection = yield db.collection('users').get();
    var findFriendsArr = [];
    collection.docs.forEach((doc) => {
        // Don't return the own user's profile
        if (doc.id === uid) {
            return;
        }
        let number = doc.data().phoneNumber;
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
}));
exports.findFriends = findFriends;
// Request object should be in form:
// {
//  idToken: "blahblah",
//  testCode: "MACHIV",
//  length: 20, // must be greater than or equal to numCategories
//  forType: 'self' || 'personal' || 'professional'
// }
const getQuiz = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    try {
        // Will throw error if not valid
        yield admin.auth().verifyIdToken(idToken);
    }
    catch (e) {
        resp.status(401);
        resp.send("Unauthorized token request.");
        return null;
    }
    // Id token is valid. Build and return the survey.
    let questionSet = req.body.questionSet;
    let testType = req.body.testType;
    let questions = [];
    try {
        switch (questionSet) {
            case "MACHIV":
                questions = yield quiz.mach.get(db, testType);
                break;
            case "NPI":
                questions = yield quiz.npi.get(db, testType);
                break;
            case "OHBDS":
                questions = yield quiz.ohbds.get(db, testType);
                break;
            case "IPIP":
                questions = yield quiz.ipip.get(db, testType);
                break;
            default:
                resp.status(400);
                resp.send("Bad request. questionSet not included in request.");
                return null;
        }
    }
    catch (e) {
        resp.status(500);
        resp.send(`Unknown error occured: ${e}}`);
        return null;
    }
    resp.status(200);
    resp.send(JSON.stringify({
        questions: questions,
    }));
}));
exports.getQuiz = getQuiz;
const submitQuiz = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    // Check to make sure request is valid with Auth token
    let idToken = req.body.idToken;
    let uid;
    try {
        // Will throw error if not valid
        let verified = yield admin.auth().verifyIdToken(idToken);
        uid = verified.uid;
    }
    catch (e) {
        resp.status(401);
        resp.send("Unauthorized token request.");
    }
    const surveyInfo = req.body.surveyInfo;
    let forUser = req.body.forUser;
    const isSelfAssessment = req.body.isSelfAssessment;
    let answers = req.body.answers;
    console.log(`User ${uid} is submitting quiz for ${forUser}`);
    if (!surveyInfo || !answers) {
        console.error('questionSet and answers must be non-null.');
        resp.status(500);
        resp.send('surveyInfo and answers must be non-null.');
    }
    if (!isSelfAssessment) {
        const userExists = (yield db.collection('users').doc(forUser).get()).exists;
        if (!userExists) {
            console.log('User not found in DB: ', forUser);
            resp.status(500);
            resp.send('User not found in DB');
        }
    }
    else {
        forUser = uid;
    }
    try {
        yield quiz.submit(surveyInfo, db, uid, forUser, answers);
        // Calculate question set scores for these three sets
        // MACHIV, OHBDS, NPI,
        // To compare against data from openpsychometrics.org
        if (isSelfAssessment) {
            const query = yield db.collection('users').doc(uid).collection('scores').where('self', '==', true).orderBy('dateTime', 'desc').limit(1).get();
            const currentScores = query.docs[0];
            let score;
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
                    yield calculateSelfScore(currentScores, uid);
                    resp.status(200);
                    resp.send(true);
                    return;
            }
            let questionSetWeighted = Object.assign({}, currentScores.data().questionSetWeighted, { [surveyInfo.questionSet]: score });
            yield currentScores.ref.update({
                questionSetWeighted: questionSetWeighted,
            });
        }
        resp.status(200);
        resp.send(true);
    }
    catch (e) {
        console.log('Error occurred: ', e);
        resp.status(500);
        resp.send(e.toString());
        return;
    }
}));
exports.submitQuiz = submitQuiz;
const getUsersFriendList = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    try {
        yield admin.auth().verifyIdToken(idToken);
    }
    catch (e) {
        resp.status(401);
        resp.send('Unauthorized token request');
        return null;
    }
    try {
        let uid = req.body.uid;
        let list = yield db.collection('users').doc(uid).collection('friends').orderBy('dateTime').get();
        let friendArr = [];
        for (let doc of list.docs) {
            let friendId = doc.data().friend;
            let friendDoc = yield db.collection('users').doc(friendId).get();
            friendArr.push({
                id: friendDoc.id,
                displayName: friendDoc.data().displayName,
                photoUrl: friendDoc.data().photoUrl,
                dateTime: doc.data().dateTime,
            });
        }
        resp.status(200);
        resp.send(JSON.stringify(friendArr));
    }
    catch (e) {
        console.log(`Unknown error occurred: ${e}`);
        resp.status(500);
        resp.send(e);
    }
}));
exports.getUsersFriendList = getUsersFriendList;
const isPhoneVerified = functions.https.onRequest((req, resp) => __awaiter(this, void 0, void 0, function* () {
    let idToken = req.body.idToken;
    let uid;
    try {
        // Will throw error if not valid
        let verified = yield admin.auth().verifyIdToken(idToken);
        uid = verified.uid;
    }
    catch (e) {
        resp.status(401);
        resp.send("Unauthorized token request.");
        return null;
    }
    let user = yield admin.auth().getUser(uid);
    resp.status(200);
    resp.send(user.phoneNumber != null);
}));
exports.isPhoneVerified = isPhoneVerified;
//# sourceMappingURL=index.js.map