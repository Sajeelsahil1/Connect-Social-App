# Kinekt (Social Connect App) 📱

Kinekt is a full-stack, cross-platform social media application built in Flutter. It was developed as a mobile app intern task, demonstrating a wide range of features from real-time chat and notifications to cloud media uploads.



---

## ✨ Features

* **Full Authentication:** User sign-up, login, and password reset using Firebase Authentication.
* **Real-Time Feed:** A main feed that shows posts from all users, updated in real-time.
* **Create Posts:** Users can create posts with text and upload **images & videos** directly to Cloudinary.
* **Edit & Delete Posts:** Users have full control to edit or delete their own posts.
* **Real-Time Chat:** A complete, one-on-one messaging system.
    * Start chats from any user's profile.
    * View all active conversations in a "Messages" list.
    * Send text, images, and videos in real-time.
* **In-App Notifications:** An "Activity" screen showing notifications for new likes and comments, with a badge for unread items.
* **Like & Comment System:** Like/unlike posts and view all comments on a separate screen.
* **User Profiles:**
    * View your own profile and other users' profiles.
    * Upload/edit your profile picture, name, and bio.
* **User Search:** A dedicated search screen to find other users by name.
* **Settings Screen:**
    * Toggle between **Light Mode & Dark Mode**.
    * Toggle between **List View & Grid View** for profile posts.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter
* **Backend & Database:** Firebase (Authentication, Firestore)
* **Media Storage:** Cloudinary
* **State Management:** Provider
* **Navigation:** Flutter Navigator (Bottom Nav Bar, Stack)

---

## 🚀 How to Run

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/SajeelSahil1/Connect-Social-App.git](https://github.com/SajeelSahil1/Connect-Social-App.git)
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Set up Firebase:**
    * Create a Firebase project.
    * Add your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files.
    * Enable **Authentication** (Email/Password) and **Firestore**.
    * Set up your [Firestore security rules](https://github.com/SajeelSahil1/Connect-Social-App/blob/main/firestore.rules).
4.  **Set up Cloudinary:**
    * Create a free Cloudinary account.
    * Create an "unsigned" upload preset.
    * Add your `YOUR_CLOUD_NAME` and `YOUR_UPLOAD_PRESET` in `lib/chat_service.dart`, `lib/create_post_screen.dart`, and `lib/edit_profile_screen.dart`.
5.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📥 Get the App

You can download the signed Android `.apk` for testing directly from the **[Releases](https://github.com/SajeelSahil1/Connect-Social-App/releases)** page.
