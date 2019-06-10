const functions = require('firebase-functions');

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendDailyPoem = functions.https.onRequest((req , response) => {
    admin.firestore().collection('days').doc('current_day').get()
    .then(snapshot => {
        const current_day = snapshot.get('val')
        admin.firestore().collection('daily_poems').doc('day' + current_day).get()
        .then(s => {
            const poem_id = s.get('id')
            const body = s.get('body')
            admin.messaging().sendToTopic('daily' , {
                notification : {
                    title : 'Günün Şiiri',
                    body : body
                },
                data : {
                    click_action : 'FLUTTER_NOTIFICATION_CLICK',
                    type : 'poem',
                    poem_id : poem_id.toString()
                }
            }).then(res => {
                //message sended succesfully
                admin.firestore().collection('days').doc('current_day').set({
                    val : current_day + 1
                })
                response.redirect(303 , 'https://google.com')
                return
            }).catch(err => console.log(err))
            return
        })
        .catch(err => console.log(err))
        return
    })
    .catch(err => console.log(err))
})