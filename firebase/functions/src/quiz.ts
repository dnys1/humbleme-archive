import * as admin from "firebase-admin";

const DEFAULT_SURVEY_LENGTH = 20;

interface SurveyTypes {
    self: boolean,
    personal: boolean,
    professional: boolean
}

interface Question {
    id: string,
    self: string,
    peer: string,
    surveyTypes: SurveyTypes,
    categoryWeights: any
}

interface Answer {
    question: Question,
    response: number
}

interface MiniAnswer {
    question: string,
    response: number,
}

interface Scores {
    id: String,
    categoryRaw: any,
    categoryTotals: any,
    categoryWeighted: any,
    mindsetWeighted: any,
    self: boolean,
    dateTime: Date,
    score: number,
}

interface SurveyInfo {
    questionSet: string,
    relationshipType: string,
    yearsKnown: number,
}

interface Survey {
    id: string,
    dateTime: FirebaseFirestore.FieldValue,
    toUser: string,
    fromUser: string,
    answers: any,
    completed: boolean,
    surveyInfo: SurveyInfo,
}

// From: https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
function shuffle(array) {
    var currentIndex = array.length, temporaryValue, randomIndex;

    // While there remain elements to shuffle...
    while (0 !== currentIndex) {

        // Pick a remaining element...
        randomIndex = Math.floor(Math.random() * currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = array[currentIndex];
        array[currentIndex] = array[randomIndex];
        array[randomIndex] = temporaryValue;
    }

    return array;
}

enum QuestionSet { IPIP, MACHIV, NPI, OHBDS }

const getQuestions = async (db: FirebaseFirestore.Firestore, forType: string, questionSet: QuestionSet) => {
    const queryString = QuestionSet[questionSet];
    const docs = await db.collection('questions').where('testCode', '==', queryString).get();
    let questions: FirebaseFirestore.DocumentData[] = [];
    docs.forEach((doc) => {
        if (doc.data().surveyTypes[forType] as boolean) {
            questions.push(doc.data());
        }
    });
    return shuffle(questions);
}

const mach = {
    get: async (db: FirebaseFirestore.Firestore, forType: string) => await getQuestions(db, forType, QuestionSet.MACHIV),
    score: (responses: Answer[]) => {
        const numQuestions = 20;
        let rawScore = responses.reduce((acc, curr) => {
            const weight = curr.question.categoryWeights['MACHIAVELLIAN'];
            const answer = curr.response;
            if (Math.sign(weight) === 1) {
                return acc + answer;
            } else {
                return acc + (6 - answer); // Converts 1-5 to 5-1
            }
        }, 0);
        return rawScore / numQuestions;
    }
}

const npi = {
    get: async (db: FirebaseFirestore.Firestore, forType: string) => await getQuestions(db, forType, QuestionSet.NPI),
    score: (responses: Answer[]) => {
        let numQuestions = 0;
        const rawScore = responses.reduce((acc, curr) => {
            numQuestions++;
            let maxWeight = 0;
            // Determine if the question is positively or negatively attributed.
            const categoryWeights: Object = curr.question.categoryWeights;
            for (const key of Object.keys(categoryWeights)) {
                const weight = categoryWeights[key];
                if (Math.abs(weight) > maxWeight) {
                    maxWeight = weight;
                }
            }
            const response = curr.response;
            if (Math.sign(maxWeight) === 1) {
                return acc + response;
            } else {
                return acc + (6 - response);
            }
        }, 0);
        return rawScore / numQuestions;
    }
}

const ohbds = {
    get: async (db: FirebaseFirestore.Firestore, forType: string) => await getQuestions(db, forType, QuestionSet.OHBDS),
    score: (responses: Answer[]) => {
        const numQuestions = 20;
        let rawScore = responses.reduce((acc, curr) => {
            const weight = curr.question.categoryWeights['LEFT_BRAINED'];
            const response = curr.response;
            if (Math.sign(weight) === 1) {
                return acc + response;
            } else {
                return acc + (6 - response);
            }
        }, 0);
        return rawScore / numQuestions;
    }
}

const ipip = {
    get: async (db: FirebaseFirestore.Firestore, forType: string) => await getQuestions(db, forType, QuestionSet.IPIP),
}

const submit = async (surveyInfo: SurveyInfo, db: FirebaseFirestore.Firestore, uid: string, forUser: string, answers: Answer[]) => {
    const questionWasSkipped: (number) => boolean = (response) => response === -1;

    await db.runTransaction(async (tx) => {
        const fromUserRef = db.collection('users').doc(uid);
        const toUserRef = db.collection('users').doc(forUser);
        const isSelfAssessment = uid === forUser;
        const scoresRef = toUserRef.collection('scores');
        const fromUser = await tx.get(fromUserRef);
        const toUser = await tx.get(toUserRef);
        const scoresSnap = await tx.get(scoresRef.where('self', '==', isSelfAssessment).orderBy('dateTime', 'desc').limit(1));

        // Create a new scores object so we can modify it
        let scores = <Scores>{
            ...(scoresSnap.docs[0].data())
        };

        // For each answer provided, compute the following for each category:
        // categoryRaw[category] += answers.response * question[category]weight
        // categoryTotals[category]++
        // categoryWeighted = categoryRaw / categoryTotals
        for (let i = 0; i < answers.length; i++) {
            const question = answers[i].question;
            const response = answers[i].response as number;

            if (questionWasSkipped(response)) {
                continue;
            }

            // Get the categories -> weights Map for this question
            const categoryWeights = question.categoryWeights;
            // Get the categories for this question
            const categories = Object.keys(categoryWeights);
            for (let j = 0; j < categories.length; j++) {
                const category = categories[j];
                const rawWeight = categoryWeights[category] as number;

                // Get the weight value for this category
                const weight = Math.abs(rawWeight);
                // Get the direction for the question
                const sign = Math.sign(rawWeight);
                scores.categoryTotals[category] += weight;
                if (sign === -1) {
                    scores.categoryRaw[category] += weight * (6 - response); // 1-5 --> 5-1
                } else {
                    scores.categoryRaw[category] += weight * response;
                }
            }
        }

        const allCategories = Object.keys(scores.categoryRaw);
        for (let k = 0; k < allCategories.length; k++) {
            const category = allCategories[k];
            // Only compute the score if total > 0 so we don't divide by 0.
            if (scores.categoryTotals[category] > 0) {
                scores.categoryWeighted[category] = scores.categoryRaw[category] / scores.categoryTotals[category];
            }
        }

        if (isSelfAssessment) {
            // Create a new selfAssessmentsTaken object and update
            // the status for this test type.
            const selfAssessmentsTaken = {
                ...(fromUser.data().selfAssessmentsTaken),
            };
            selfAssessmentsTaken[surveyInfo.questionSet] = true;

            // Update the user object in Firestore
            tx.update(fromUserRef, {
                selfAssessmentsTaken: selfAssessmentsTaken,
            });
        }

        // Add the new score to the scores subcollection
        const newScore = scoresRef.doc();
        tx.create(newScore, {
            ...scores,
            id: newScore.id,
            // Sets the timestamp as an actual object, instead of a number.
            dateTime: admin.firestore.FieldValue.serverTimestamp(),
            self: isSelfAssessment,
        });

        if (!isSelfAssessment) {
            const surveyRef = db.collection('surveys').doc(newScore.id);

            tx.set(surveyRef, <Survey>{
                id: surveyRef.id,
                dateTime: admin.firestore.FieldValue.serverTimestamp(),
                toUser: toUser.id,
                fromUser: fromUser.id,
                answers: answers.reduce((acc, curr) => ({ ...acc, [curr.question.id]: curr.response }), {}),
                completed: true,
                surveyInfo: surveyInfo,
            });

            tx.update(fromUserRef, {
                surveysGiven: fromUser.data().surveysGiven + 1,
            });

            tx.update(toUserRef, {
                surveysReceived: toUser.data().surveysReceived + 1,
            });
        }
    });
};

export { mach, npi, ohbds, ipip, Answer, QuestionSet, SurveyInfo, submit };

