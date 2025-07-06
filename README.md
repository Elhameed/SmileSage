# SmileSage

## Description
A mobile application that detects six oral conditions (Calculus, Caries, Gingivitis, Hypodontia, Mouth Ulcer, Tooth Discoloration) and Healthy Teeth using an on-device TensorFlow Lite model. The app also features a user-friendly Flutter front-end guided by Figma designs.

## Github Repository
https://github.com/Elhameed/SmileSage.git

## Setup & Installation
### 1. <b>1. ML Environment</b>
1. Clone the repo:
```sh
git clone https://github.com/elhameed/smilesage.git
cd smilesage/ml_model
```

2. Create a Python virtual environment:
```sh
python3 -m venv venv
source venv/bin/activate
```

3. Install dependencies:
```sh
pip install -r requirements.txt
```

4. Mount Google Drive and run preprocessing & training notebooks in Google Colab or locally.

### 2. <b>Flutter App</b>
1. Navigate to the Flutter folder:
```sh
cd smilesage
```

2. Get packages:
```sh
flutter pub get
```

3. Run on device or emulator: 
```sh
flutter run
```

## Designs
- Figma Mockups: see https://www.figma.com/design/zK4xtV89YRYwQUseJtCVgv/SmileSage?node-id=0-1&t=oy8Da0cbpruAY5lP-1 for home screen, scan workflow, chatbot interface etc.
- Screenshots: included under `docs/figma_mockups/`.

## Deployment Plan
Detailed plan available in `deployment/deployment_plan.md covering:

1. Hosting backend APIs (Firebase or custom server)

2. CI/CD for Flutter app (GitHub Actions → Test & Deploy to TestFlight/Play Store)

3. Automated model updates and TFLite asset versioning

## Features

### PDF Report Generation
The app includes a comprehensive PDF report generation feature that allows users to download detailed scan reports. Each PDF includes:

- **Scan Results**: Predicted condition and confidence level
- **Analysis**: Detailed explanation of the scan findings
- **Personalized Tips**: Customized dental care recommendations
- **Scan Images**: Both original and Grad-CAM heatmap overlay images
- **Professional Layout**: Clean, medical-grade report formatting

**How to use:**
1. Navigate to any scan detail screen
2. Tap the "Download PDF" button
3. Grant storage permissions when prompted
4. The PDF will be saved to your device's Downloads folder
5. Option to open the PDF directly from the app

**Technical Implementation:**
- Uses the `pdf` package for PDF generation
- Implements proper permission handling for file storage
- Supports both Android and iOS platforms
- Generates unique filenames with timestamps

## Video Demo
A 5–10 minute walkthrough demonstrating:

- Real-time disease detection workflow

- UI navigation between scan, chatbot, and history

- Viewing Figma design vs. live app

Video link: https://drive.google.com/drive/folders/1vt88e0ddrjj6eGWbW1HMtUExru-6lh0H?usp=sharing
