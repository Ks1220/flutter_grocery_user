const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendFriendRequestNotification = functions.firestore.document("users/{userId}/friends/{friendId}").onCreate((snap, context) => {
    const doc = snap.data();
    const idTo = context.params.userId;
    const senderName = doc.name;
    const senderEmail = doc.email;

    if (doc.status != 0) {
        return null;
    }

    admin
        .firestore()
        .collection("users")
        .where(admin.firestore.FieldPath.documentId(), "==", idTo)
        .get()
        .then((querySnapshot) => {
            querySnapshot.forEach((userTo) => {
                if (userTo.data().pushToken) {
                    const payload = {
                        notification: {
                            title: "You have a new friend request",
                            body: `${senderName} (${senderEmail}})`,
                            badge: "1",
                            sound: "default",
                        },
                    };
                    admin
                        .messaging()
                        .sendToDevice(userTo.data().pushToken, payload)
                        .then((response) => {
                            console.log("Successfully sent notification:", response);
                        })
                        .catch((error) => {
                            console.log("Error sending message:", error);
                        });
                } else {
                    console.log("Can not find pushToken target user");
                }
            });
        })
        .catch((error) => {
            console.log("Error: ", error);
        });
    return null;
});
