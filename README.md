# SmileSage

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Screenshots & Demo](#screenshots--demo)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [ML Model](#ml-model)
- [PDF Reports](#pdf-reports)
- [Clinic Finder](#clinic-finder)
- [Contributing](#contributing)
- [License](#license)

## Overview
SmileSage is a cross-platform mobile app for dental condition detection. The app uses a FastAPI backend to serve a Keras ML model for inference. The Flutter frontend communicates with this backend to analyze images and provide results, including Grad-CAM overlays and PDF reports.

## Features
- Dental condition detection via FastAPI backend (Keras model)
- PDF report generation
- Clinic finder (Google Places API)
- Chatbot for dental advice
- User authentication (Firebase)
- Cross-platform: Android, iOS, Web, Desktop

## Screenshots & Demo
- Figma designs: [Figma Link](https://www.figma.com/design/zK4xtV89YRYwQUseJtCVgv/SmileSage?node-id=0-1&t=oy8Da0cbpruAY5lP-1)
- Video demo: [Google Drive Link](https://drive.google.com/drive/folders/1vt88e0ddrjj6eGWbW1HMtUExru-6lh0H?usp=sharing)
- Screenshots: See `docs/figma_mockups/`

## Getting Started

### Prerequisites
- Flutter SDK
- Python 3.x (for ML model training)
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

#### 4. Environment Variables
Copy `.env.example` to `.env` and fill in your API keys.

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
├── .env.example              # Example env file
├── README.md                 # Main project readme
├── LICENSE
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

## Backend API (dental_api/)
SmileSage relies on a FastAPI backend (in `dental_api/`) for all ML inference. The backend serves a trained Keras model and exposes REST endpoints for predictions. The Flutter app sends images to this backend and receives predictions and Grad-CAM overlays in response.

- **Endpoints:**
  - `/predict` (POST): Accepts an image, returns predicted condition, confidence, all class probabilities, and a Grad-CAM overlay.
  - `/` (GET): Health check.
- **Model:** Export your trained model from the notebook as `.keras` and place it in `dental_api/`.
- **Run locally:**
  ```sh
  cd dental_api
  pip install -r requirements.txt
  uvicorn main:app --reload
  ```
- **Run with Docker:**
  ```sh
  cd dental_api
  docker build -t smilesage-api .
  docker run -p 8000:8000 smilesage-api
  ```
- **Update model:** Replace the `.keras` file in `dental_api/` and restart the API.

See `dental_api/README.md` for full details.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License
MIT (or your chosen license)
