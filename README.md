# SmileSage

## Table of Contents
- [Overview](#overview)
- [Who is this for?](#who-is-this-for)
- [Features](#features)
- [Screenshots & Demo](#screenshots--demo)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [ML Model](#ml-model)
- [PDF Reports](#pdf-reports)
- [Clinic Finder](#clinic-finder)
- [Testing](#testing)
- [Contributing](#contributing)

## Overview
SmileSage is a cross-platform mobile app for dental condition detection. The app uses a fine-tuned on-device ML model (EfficientNetB0, TFLite) to analyze dental images, generate reports, and help users find clinics and get dental advice.

## Who is this for?
SmileSage is designed for anyone interested in monitoring their dental health using their smartphone or desktop. It’s especially useful for:
- Individuals wanting quick, AI-powered dental checks
- Dental professionals seeking a demo of mobile ML for patient engagement
- Developers interested in Flutter, on-device ML, and healthcare apps

## Features
- Dental condition detection using on-device TFLite model
- PDF report generation for scan results
- Clinic finder (Google Places API)
- Chatbot for dental advice
- User authentication (Firebase)
- Cross-platform: Android, iOS, Web, Desktop

## Screenshots & Demo
- Figma designs: [Figma Link](https://www.figma.com/design/zK4xtV89YRYwQUseJtCVgv/SmileSage?node-id=0-1&t=oy8Da0cbpruAY5lP-1)
- Video demo: [Google Drive Link](https://drive.google.com/drive/folders/1vt88e0ddrjj6eGWbW1HMtUExru-6lh0H?usp=sharing)

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.x (for ML model training, optional)
- Firebase account (for auth)

### Setup

#### 1. Clone the repository
```sh
git clone https://github.com/Elhameed/SmileSage.git
cd SmileSage
```

#### 2. Flutter App
```sh
cd smilesage
flutter pub get
flutter run
```

#### 3. ML Model (Optional)
See [notebook/README.md](notebook/README.md) for model training and export instructions.

#### 4. API Keys & Configuration
- Set your Google Places API key in `lib/services/clinic_service.dart`.
- For Google Maps, update the API key in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift` as described in [smilesage/LOCATION_FEATURE_SETUP.md](smilesage/LOCATION_FEATURE_SETUP.md).

## Project Structure
```
SmileSage/
├── smilesage/                # Main Flutter app (Dart code, assets, platforms)
│   ├── lib/                  # Dart source code
│   │   ├── models/           # Data models
│   │   ├── services/         # Business logic, APIs
│   │   ├── screens/          # UI screens
│   │   ├── widgets/          # Reusable widgets
│   │   └── main.dart         # App entry point
│   ├── assets/               # Images, TFLite models
│   ├── test/                 # Dart tests
│   ├── android/ ios/ ...     # Platform code
│   └── pubspec.yaml          # Flutter dependencies
├── docs/                     # Documentation
├── notebook/                 # ML/modeling
├── deployment/               # Deployment plans
├── README.md                 # Main project readme
└── CONTRIBUTING.md
```

## ML Model
- Model: EfficientNetB0, fine-tuned for dental conditions.
- Format: TFLite (`assets/models/efficientnetb0_finetuned.tflite`)
- Training: See [notebook/SmileSage_dental_scanner_implementation.ipynb](notebook/SmileSage_dental_scanner_implementation.ipynb)

## PDF Reports
- Generates detailed scan reports with images, analysis, and tips.
- See [docs/pdf_feature_documentation.md](docs/pdf_feature_documentation.md)

## Clinic Finder
- Uses Google Places API to find nearby dental clinics.
- See [docs/clinic_finder.md](docs/clinic_finder.md)
- For setup, see [smilesage/LOCATION_FEATURE_SETUP.md](smilesage/LOCATION_FEATURE_SETUP.md)

## Testing
To run the Flutter tests:
```sh
cd smilesage
flutter test
```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
