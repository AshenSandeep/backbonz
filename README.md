# BackBonz

Brace wear tracking app for teenagers with scoliosis.

## Setup

1. Clone the repo
2. Create a `.env` file in the root with your Firebase credentials:
```
FIREBASE_API_KEY_ANDROID=your_key
FIREBASE_APP_ID_ANDROID=your_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_bucket
```
3. Run using:
```
run.bat
```

## Architecture
- **GetX** for state management and navigation
- **MVVM** pattern — screens → viewModels → services
- **Firebase Auth** for authentication
- **Cloud Firestore** for session storage