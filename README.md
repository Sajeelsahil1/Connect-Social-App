# Kinekt (Social Connect App) 📱

Kinekt is a full-stack, cross-platform social media application built in Flutter. It was developed as a comprehensive mobile app internship task for **DevelopersHub**, demonstrating a wide range of features from real-time social interactions to cloud media uploads.



---

## ✨ Features

* **Full Authentication:** User sign-up, login, and password reset using Firebase Authentication.
* **Real-Time Feed:** A main feed that shows posts from all users, updated in real-time.
* **User Follow System (New):**
    * **Follow/Unfollow** users to curate your network.
    * View real-time **Followers & Following counts** on user profiles.
* **Real-Time Chat:** A complete, one-on-one messaging system.
    * Start chats directly from any user's profile.
    * Send **text, images, and videos** seamlessly.
    * View all active conversations in a specialized "Messages" tab.
* **Create Posts:** Users can create rich posts with text and upload **images & videos** directly to Cloudinary.
* **Full CRUD Control:** Users have full control to edit or delete their own posts.
* **Interactive Engagement:**
    * **Like/Unlike** posts instantly.
    * **Comment** system to discuss posts.
* **In-App Notifications:** An "Activity" screen showing alerts for new likes and comments, complete with unread badges.
* **User Profiles:**
    * Customizable profiles with profile pictures, names, and bios.
    * Toggle between **List View & Grid View** for profile posts.
    * Smart profile logic: Shows "Edit Profile" for you, and "Follow/Message" for others.
* **User Search:** A dedicated search screen to find other users by name.
* **Settings & Themes:**
    * Toggle between **Light Mode & Dark Mode**.

---

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Authentication, Firestore, Storage)
* **Media Storage:** Cloudinary API
* **State Management:** Provider
* **Architecture:** MVC (Model-View-Controller) pattern with Service isolation

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
