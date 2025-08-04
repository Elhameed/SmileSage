# SmileSage

> AI-Powered Dental Health Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.4.4+-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://developer.android.com/)

SmileSage is a comprehensive dental health app that combines AI-powered dental scanning with habit tracking and educational content to help users maintain optimal oral health.

## Features

### AI Dental Scanning
- Instant dental condition analysis using server-deployed ML models
- Support for both image and video scanning
- Detailed explanations and care recommendations
- Grad-CAM heatmap visualization

### Habit Tracking
- Daily brushing streak tracking with automatic reset logic
- Badge system with 6 achievement levels
- Global leaderboard for motivation
- Progress visualization and statistics

### Smart Features
- PDF report generation with scan results and progress
- Nearby dental clinic finder using Google Places API
- Multi-language support (English, French, Swahili, Kinyarwanda)
- Personalized daily dental care tips
- Reminder system for brushing and dental visits

### User Management
- Firebase authentication with email/password and Google Sign-In
- Cross-device profile synchronization
- Secure data storage and privacy protection

## Quick Start

### Prerequisites
- Flutter SDK (3.4.4+)
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Elhameed/SmileSage.git
   cd SmileSage/smilesage
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API keys**
   - Add Google Places API key in `lib/services/clinic_service.dart`
   - Configure Firebase in `android/app/google-services.json`

4. **Run the app**
   ```bash
   flutter run
   ```

## Screenshots

<div align="center">
  <img src="screenshots/5.jpg" width="200" alt="Home Screen">
  <img src="screenshots/1.jpg" width="200" alt="Scan Results">
  <img src="screenshots/2.jpg" width="200" alt="Clinic Finder">
  <img src="screenshots/3.jpg" width="200" alt="Badges">
</div>

## Architecture

```
smilesage/
├── lib/
│   ├── models/          # Data models (ScanResult, Clinic, etc.)
│   ├── services/        # Business logic & API integration
│   ├── screens/         # UI screens
│   ├── widgets/         # Reusable components
│   └── l10n/           # Localization files
├── assets/
│   ├── images/         # App icons and UI assets
│   └── videos/         # Guidance videos
└── test/               # Unit and widget tests
```

## Key Technologies

- **Frontend**: Flutter 3.4.4+, Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **ML**: Server-deployed TensorFlow models
- **APIs**: Google Places, Gemini AI
- **Localization**: Flutter Intl

## Download

- **Android APK**: [Download Latest Release](https://drive.google.com/file/d/1z5N-kJNws94nACIZfhEChgYB7Pn38MQq/view?usp=sharing)
- **Demo Video**: [Watch 5-minute demo](https://drive.google.com/file/d/1ZTGYR0KkW2u8SYHhCMDhg-otdvJAq9-K/view?usp=sharing)

## Documentation

- [Analysis & Review](docs/analysis_and_review.md) - Project outcomes and lessons learned
- [Clinic Finder Setup](smilesage/LOCATION_FEATURE_SETUP.md) - Google Places API configuration
- [Leaderboard Feature](smilesage/LEADERBOARD_FEATURE.md) - Global ranking system
- [Firebase Integration](smilesage/FIREBASE_PROFILE_SYNC.md) - User data synchronization

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Contact

- **Developer**: [a.ajani@alustudent.com](mailto:a.ajani@alustudent.com)
- **Supervisor**: Mr. Marvin Ogore

## Acknowledgments

- Flutter & Dart development teams
- Firebase for backend services
- Google Cloud Platform for ML deployment
- All contributors and testers who made this project possible

---

<div align="center">
  <strong>Made with ❤️ for better dental health</strong>
</div>
