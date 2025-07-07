# SmileSage Architecture

## Overview
SmileSage is a cross-platform mobile application built with Flutter, integrating on-device ML, cloud services, and a modular UI. The architecture is designed for scalability, maintainability, and ease of feature extension.

## Main Components
- **Flutter Frontend**: Handles all UI, navigation, and user interaction.
- **ML Inference (TFLite)**: On-device TensorFlow Lite model for dental condition detection.
- **Backend Services**: Firebase for authentication and cloud storage; Google Places API for clinic search.
- **PDF Generation**: In-app PDF creation for scan reports.
- **Local Storage**: SharedPreferences for scan history and user data.

## Data Flow
1. **User selects or captures an image**
2. **Image is preprocessed and passed to the TFLite model**
3. **Model returns prediction and confidence**
4. **Result is displayed and can be saved, shared, or exported as PDF**
5. **User can search for clinics using geolocation and Google Places API**
6. **Authentication and user data managed via Firebase**

## Technology Stack
- **Flutter/Dart**: Cross-platform UI
- **TensorFlow Lite**: On-device ML
- **Firebase**: Auth, storage
- **Google Places API**: Clinic search
- **PDF (Dart package)**: Report generation

## Diagram
_(Insert system architecture diagram here)_

---

For more details, see the codebase and feature-specific documentation in the `docs/` folder. 