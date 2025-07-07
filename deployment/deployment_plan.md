# Deployment Plan for SmileSage

This document outlines the end-to-end deployment strategy for the SmileSage application, covering the FastAPI backend (ML inference), Flutter mobile frontend, CI/CD pipelines, model versioning, monitoring, and security.

---

## 1. Backend Hosting (FastAPI)

### 1.1 Platform
- **Google Cloud Run** or **AWS ECS/Fargate**: Deploy the FastAPI backend as a Docker container for scalable, serverless inference.
- **Alternative**: Any VM or container service supporting Docker (e.g., Azure, DigitalOcean).

### 1.2 Services
- **Inference API**: FastAPI app serving a trained Keras model. Handles image uploads, returns predictions and Grad-CAM overlays.
- **Health Check**: `/` endpoint for uptime monitoring.

### 1.3 Deployment Steps
- Build Docker image:
  ```sh
  docker build -t smilesage-api ./dental_api
  ```
- Push to container registry (e.g., Google Artifact Registry, Docker Hub).
- Deploy to Cloud Run or chosen platform, exposing port 8000.
- Set environment variables/secrets for API keys as needed.

---

## 2. CI/CD Pipeline

### 2.1 GitHub Actions Workflows
- **`ci.yml`** (on push/PR):
  1. Checkout code
  2. Lint & test:
     - Flutter: `flutter analyze` & `flutter test`
     - Python: `flake8` & `pytest` (for backend)
  3. Build Docker image for backend
  4. Optionally deploy to staging environment

- **`release.yml`** (manual/production):
  - Build and push Docker image
  - Deploy to production Cloud Run/ECS
  - Build and upload Flutter app to Play Store/TestFlight (using Fastlane)

---

## 3. Mobile App Distribution

### 3.1 Android
- Build APK/AAB (`flutter build apk` / `flutter build appbundle`)
- Distribute via Google Play Console (Internal Testing, Beta, Production)

### 3.2 iOS
- Build with Xcode or CI
- Distribute via TestFlight and App Store Connect

---

## 4. Model Versioning & Updates

- **Model Storage**: Store the latest `.keras` model in the `dental_api/` directory before building the Docker image.
- **Versioning**: Tag Docker images/releases with model version (e.g., `smilesage-api:v1.2-model2024-05-01`).
- **Update Process**: Train/export new model → replace `.keras` file → rebuild and redeploy backend.

---

## 5. Monitoring & Logging

- **Cloud Logging**: Enable request/error logging in Cloud Run or chosen platform.
- **Sentry**: Integrate with Flutter app for crash/error reporting.
- **Uptime Checks**: Use cloud provider monitoring to alert on downtime or high error rates.

---

## 6. Security & Compliance

- **Authentication**: Use Firebase Auth or JWT for secure API access if needed.
- **Encryption**: Enforce HTTPS/TLS for all endpoints.
- **Secrets Management**: Store API keys and credentials in Google Secret Manager, AWS Secrets Manager, or GitHub Secrets.
- **CORS**: Restrict allowed origins in FastAPI middleware for production.

---

*This deployment plan ensures SmileSage is secure, scalable, and maintainable in production, leveraging modern cloud and CI/CD best practices.*  
