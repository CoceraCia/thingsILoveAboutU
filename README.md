# Sanotes

![Swift](https://img.shields.io/badge/Swift-5.0-orange?logo=swift)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-yellow?logo=firebase)
![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)
![License](https://img.shields.io/badge/License-MIT-green)

A heartwarming iOS application designed to let users create and share personalized lists of things they appreciate about their loved ones. Built with a robust backend using Firebase Cloud Functions for secure and scalable data handling.

![Content](https://github.com/user-attachments/assets/e3ceba9a-81a1-4d42-95e3-06bb9333fe42)
![Simulator Screen Recording - iPhone 17 - 2026-02-18 at 19 52 57](https://github.com/user-attachments/assets/6ff896fa-6e52-43e5-ba6d-3477191cb15b)


## ✨ Features

- **Create & Personalize Lists**: Users can compile meaningful lists of appreciation.
- **Image Attachments**: Enhance your lists by attaching memorable photos to each item.
- **Secure Sharing**: Share your lists privately via unique generated IDs.
- **Smart Backend Processing**: Automated image handling and storage optimization.
- **Device-Based Security**: Built-in rate limiting to prevent abuse.

## 🛠 Tech Stack

### 📱 iOS App
- **Language**: Swift
- **UI Framework**: SwiftUI / UIKit
- **Architecture**: MVVM (Model-View-ViewModel) pattern recommended

### ☁️ Backend (Firebase)
The backend logic is powered by **Python Cloud Functions**, handling complex operations securely:

- **Cloud Firestore**: Real-time database for storing lists and metadata.
- **Cloud Storage**: Temporary storage for image processing.
- **Cloud Functions (Python)**:
  - `claim_note`: Securely retrieves and "claims" a shared note, preventing duplicate access.
  - `process_complete_upload`: Handles multi-threaded image uploads, enforces limits (max 10 lists per device), and cleans up temporary storage.

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- CocoaPods or Swift Package Manager
- Firebase CLI (for backend deployment)
- Python 3.11+

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/ThingsILoveAboutU.git
    cd ThingsILoveAboutU
    ```

2.  **iOS Setup**
    - Navigate to the `ThingsILoveAboutU` directory.
    - Open `ThingsILoveAboutU.xcodeproj` in Xcode.
    - Ensure you have your `GoogleService-Info.plist` added to the project root.

3.  **Backend Deployment** (Optional - if you want to deploy your own instance)
    ```bash
    cd functions
    python3.11 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    firebase deploy --only functions
    ```

## 📂 Project Structure

```
ThingsILoveAboutU/
├── ThingsILoveAboutU/       # iOS Source Code
│   ├── Models/
│   ├── Views/
│   └── ViewModels/
├── functions/               # Python Cloud Functions
│   ├── main.py              # Main backend logic
│   └── requirements.txt     # Python dependencies
└── firebase.json            # Firebase configuration
```

## 🛡 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---
Made with ❤️ by CoceraCia
