const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/**
 * Triggers when a new comment is created.
 */
exports.onCommentCreated = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snapshot, context) => {
    // 1. Get the post data
    const postId = context.params.postId;
    const postDoc = await admin.firestore().collection("posts").doc(postId).get();
    if (!postDoc.exists) {
      return console.log("Post not found");
    }
    const post = postDoc.data();
    const postOwnerUid = post.uid;

    // 2. Get the commenter's data
    const comment = snapshot.data();
    const commenterUid = comment.uid;
    const commenterName = comment.name;

    // 3. Don't send a notification if you comment on your own post
    if (postOwnerUid === commenterUid) {
      return console.log("User commented on their own post. No notification.");
    }

    // 4. Get the post owner's tokens
    const userDoc = await admin.firestore().collection("users").doc(postOwnerUid).get();
    if (!userDoc.exists) {
      return console.log("Post owner not found");
    }
    const user = userDoc.data();
    const tokens = user.fcmTokens;
    if (!tokens || tokens.length === 0) {
      return console.log("Post owner has no tokens.");
    }

    // 5. Create the notification payload
    const payload = {
      notification: {
        title: `${commenterName} commented on your post`,
        body: comment.text,
        sound: "default",
      },
      data: {
        postId: postId,
        type: "comment",
      },
    };

    // 6. Send the notification
    return admin.messaging().sendToDevice(tokens, payload);
  });

/**
 * Triggers when a post is updated (e.g., liked).
 */
exports.onLikeUpdated = functions.firestore
  .document("posts/{postId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    const likesBefore = before.likes || [];
    const likesAfter = after.likes || [];

    // 1. Check if a *new* like was added (not removed)
    if (likesAfter.length <= likesBefore.length) {
      return console.log("A like was removed or no change. No notification.");
    }

    // 2. Find out who the new liker is
    const newLikerUid = likesAfter.find((uid) => !likesBefore.includes(uid));
    if (!newLikerUid) {
      return console.log("Could not determine new liker.");
    }

    // 3. Get the post owner's UID
    const postOwnerUid = after.uid;

    // 4. Don't send a notification if you like your own post
    if (postOwnerUid === newLikerUid) {
      return console.log("User liked their own post. No notification.");
    }

    // 5. Get the liker's name
    const likerDoc = await admin.firestore().collection("users").doc(newLikerUid).get();
    if (!likerDoc.exists) {
      return console.log("Liker user document not found.");
    }
    const likerName = likerDoc.data().name || "Someone";

    // 6. Get the post owner's tokens
    const ownerDoc = await admin.firestore().collection("users").doc(postOwnerUid).get();
    if (!ownerDoc.exists) {
      return console.log("Post owner not found.");
    }
    const tokens = ownerDoc.data().fcmTokens;
    if (!tokens || tokens.length === 0) {
      return console.log("Post owner has no tokens.");
    }

    // 7. Create the notification payload
    const payload = {
      notification: {
        title: `${likerName} liked your post`,
        body: after.postText || "Your media post",
        sound: "default",
      },
      data: {
        postId: context.params.postId,
        type: "like",
      },
    };

    // 8. Send the notification
    return admin.messaging().sendToDevice(tokens, payload);
  });