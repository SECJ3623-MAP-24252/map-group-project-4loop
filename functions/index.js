const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const chatId = context.params.chatId;

    // The sender's ID is in the message
    const senderId = message.senderId;

    // Get the recipient's ID from the chatId
    // The chatId is assumed to be "userId1_userId2"
    const userIds = chatId.split("_");
    const recipientId = userIds.find((id) => id !== senderId);

    if (!recipientId) {
      console.log("Could not determine recipient ID.");
      return;
    }

    // Get the recipient's FCM token from their user document
    const recipientDoc = await admin
      .firestore()
      .collection("users")
      .doc(recipientId)
      .get();
    if (!recipientDoc.exists) {
      console.log(`Recipient document ${recipientId} does not exist.`);
      return;
    }
    const recipientData = recipientDoc.data();
    const fcmToken = recipientData.fcmToken;

    if (!fcmToken) {
      console.log(`Recipient ${recipientId} does not have an FCM token.`);
      return;
    }

    // Get sender's name for the notification
    const senderDoc = await admin
      .firestore()
      .collection("users")
      .doc(senderId)
      .get();
    if (!senderDoc.exists) {
      console.log(`Sender document ${senderId} does not exist.`);
      return;
    }
    const senderName = senderDoc.data().name || "Someone";

    // Construct the notification payload
    const payload = {
      notification: {
        title: `New message from ${senderName}`,
        body: message.message,
        sound: "default",
      },
      data: {
        chatId: chatId,
        senderId: senderId,
        // You can add more data here to handle navigation on tap
      },
    };

   // ...existing code...

// Send the notification
try {
  console.log(`Sending notification to token: ${fcmToken}`);
  await admin.messaging().sendToDevice(fcmToken, payload);
  console.log("Notification sent successfully.");
} catch (error) {
  console.error("Error sending notification:", error);
}

// Store notification in Firestore for the recipient (ALWAYS RUNS)
const notification = {
  title: `New message from ${senderName}`,
  body: message.message,
  timestamp: admin.firestore.FieldValue.serverTimestamp(),
  type: 'chat',
  data: {
    chatId: chatId,
    senderId: senderId,
    messageId: context.params.messageId,
  }
};

await admin.firestore()
  .collection('users')
  .doc(recipientId)
  .collection('notifications')
  .add(notification);
  }); 

  