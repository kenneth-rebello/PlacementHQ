const  admin  = require('firebase-admin');
const functions = require('firebase-functions');


admin.initializeApp();
exports.notifFunc = functions.database.ref("/collegeData/{collegeId}/notices/{noticeId}").onCreate((snapshot, context) => {
    const notice = snapshot.val();
    const colId = 'college_'+context.params.collegeId;
    console.log(colId);
    return admin.messaging().sendToTopic(
        colId, {
            notification: {
                title: notice.companyName, 
                body: notice.notice, 
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
            }
        }
    );
});


exports.driveFunc = functions.database.ref("/collegeData/{collegeId}/drives/{driveId}").onCreate((snapshot, context) => {
    const drive = snapshot.val();
    const colId = 'college_'+context.params.collegeId;
    return admin.messaging().sendToTopic(
        colId, 
        {
            notification: {
                title: drive.companyName, 
                body: "A new placement drive has been added", 
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
            }
        }
    );
});

exports.offerFunc = functions.database.ref("/collegeData/{collegeId}/offers/{year}/{offerId}").onCreate((snapshot, context) => {
    const offer = snapshot.val();
    const userId = 'user'+offer.userId;
    console.log(userId);
    return admin.messaging().sendToTopic(
        userId, 
        {
            notification: {
                title: offer.companyName, 
                body: "Congratulations! You have been selected.", 
                clickAction: "FLUTTER_NOTIFICATION_CLICK",
            }
        }
    );
});