# Deployment Plan for SmileSage

This document outlines the end-to-end deployment strategy for the SmileSage application, covering backend services, CI/CD pipelines, mobile app distribution, model versioning, monitoring, and security.

---

## 1. Backend Hosting

### 1.1 Platform
- **Google Cloud Run**: Containerized API services (Flask/FastAPI) for scalable inference and user data endpoints.  
- **Firebase Functions** (optional): Lightweight serverless functions for simple endpoints.

### 1.2 Services
- **Inference API**: Python service running TFLite interpreter to process image uploads and return predictions.  
- **User Data API**: Node.js/Express (or Firebase Firestore) for managing user profiles, scan history, and analytics.

---

## 2. CI/CD Pipeline

### 2.1 GitHub Actions Workflows
- **`ci.yml`** (runs on push to `main` and PRs):
  1. **Checkout** code.  
  2. **Lint & Test**:
     - Flutter `flutter analyze` & `flutter test`  
     - Python `flake8` & `pytest`  
  3. **Build**:
     - Flutter web build (`flutter build web`)  
  4. **Deploy**:
     - Upload Flutter web to Firebase Hosting  
     - Deploy/update Cloud Run services

- **`release.yml`** (manual trigger for production):
  - Same steps, targeting production Firebase and Cloud Run.

---

## 3. Mobile App Distribution

### 3.1 Android
- Automate APK build (`flutter build apk`) via GitHub Actions  
- Publish to **Google Play Internal Testing** track using `fastlane supply`

---

## 4. Model Versioning & Updates

1. **Storage**: Host `.tflite` models in **Firebase Storage** or **GitHub Releases**  
2. **Version Check**: On app launch, fetch a JSON manifest of the current model version. If newer, download in background and replace local asset.  
3. **Rollback**: Retain the previous model until the new one passes a quick local validation (>1% accuracy improvement).

---

## 5. Monitoring & Logging

- **Cloud Logging (Stackdriver)** for API requests, errors, and latency  
- **Sentry** in Flutter for crash reporting and performance monitoring  
- **Uptime Checks**: Cloud Monitoring alerts on 5xx errors or latency spikes

---

## 6. Security & Compliance

- **Authentication**: Use **Firebase Auth** or **JWT** for secure API access  
- **Encryption**: Enforce HTTPS/TLS on all endpoints; data at rest encrypted by default  
- **Secrets Management**: Store credentials in **Google Secret Manager** or GitHub Secrets

---

*This deployment plan ensures SmileSage is secure, scalable, and maintainable in production.*  
