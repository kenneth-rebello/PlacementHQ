const  admin  = require('firebase-admin');
const functions = require('firebase-functions');


admin.initializeApp();
exports.notifFunc = functions.database.ref("/collegeData/{collegeId}/notices/{noticeId}").onCreate((snapshot, context) => {
    const notice = snapshot.val();
    snapshot.key
    const colId = context.params.collegeId;
    return admin.messaging().sendToTopic('notices_'+colId, {notification: 
        {
            title: notice.companyName, 
            body: notice.notice, 
            clickAction: "FLUTTER_NOTIFICATION_CLICK",
            badge: "!",
        }
    });
});