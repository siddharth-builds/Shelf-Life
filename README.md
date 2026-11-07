# Shelf-Life

A Flutter app for tracking product expiry dates, managing inventory, and receiving timely reminders before items expire.

## About

Shelf-Life is designed to help individuals and small households stay ahead of expiring products by tracking what they have, when it expires, and when reminders should be sent. The app combines a simple dashboard with Firebase-powered authentication and storage so users can access their inventory across devices.

The project currently includes:

- secure Firebase authentication
- product inventory tracking
- expiry-aware dashboard
- local notifications and timezone-aware reminder scheduling
- clean Material 3 UI for mobile use

## Features

- Add, edit, and remove items
- Track expiry dates for food and household products
- View near-expiry and expired products from a central dashboard
- Receive timely local notifications before items expire
- Sign in with Firebase authentication
- Store user data in Firebase Firestore
- Responsive Material Design interface

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Firebase Firestore
- Google Sign-In
- Flutter Local Notifications
- Timezone handling for scheduled reminders

## Screens and App Flow

The app is structured around a simple flow:

1. Launch the app
2. Sign in or continue with an existing Firebase session
3. View the dashboard of tracked products
4. Add or manage expiry items
5. Receive notifications ahead of expiry dates

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio or VS Code with Flutter support
- Firebase project configured
- A connected Android/iOS device or emulator

### 1. Clone the repository

```bash
git clone https://github.com/siddharth-builds/Shelf-Life.git
cd Shelf-Life
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

This project uses Firebase services. You need to configure your own Firebase project and generate the platform configuration files.

For Flutter Firebase setup:

```bash
flutterfire configure
```

This will generate the required `firebase_options.dart` file and connect the app to your Firebase project.

Also ensure the following Firebase files are present for your platform:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

### 4. Run the app

```bash
flutter run
```

## Project Structure

```text
.
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── firebase_options.dart
├── android/
├── ios/
├── test/
├── pubspec.yaml
├── README.md
└── analysis_options.yaml
```

## App Name

The app is currently initialized as `Know Expiry` in the Flutter entry point, while the repository is named `Shelf-Life`.

## Notes

- The app uses `flutter_local_notifications` and timezone initialization in `main.dart` for reminders.
- Firebase initialization is required before app startup completes.
- For production release builds, configure signing, environment variables, and proper notification permissions on Android and iOS.

## Future Improvements

Planned improvements may include:

- barcode/scanner support for adding products faster
- category-based organization for groceries and household items
- push notification integration with backend scheduling
- analytics for expiry trends and inventory insights
- export/import for product data
- support for multiple user profiles or household sharing

## License

This project is currently unlicensed unless otherwise specified.

## Contributing

Contributions are welcome. If you want to improve the app, you can:

1. fork the repository
2. create a feature branch
3. make your changes
4. open a pull request

