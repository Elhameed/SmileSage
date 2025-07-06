# Location-Based Clinic Finder Feature Setup

This document provides step-by-step instructions to set up the location-based dental clinic finder feature in SmileSage.

## Overview

The location feature allows users to:
- Get their current location using GPS
- Find nearby dental clinics using Google Places API
- View clinic details including ratings, contact info, and services
- Get directions to clinics
- Search and filter clinics

## Prerequisites

1. **Google Cloud Console Account**
   - Create a Google Cloud project
   - Enable Google Places API and Google Maps API
   - Generate API keys

2. **Flutter Development Environment**
   - Flutter SDK installed
   - Android Studio / VS Code with Flutter extensions

## Step 1: Google Cloud Console Setup

### 1.1 Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Note your Project ID

### 1.2 Enable Required APIs
Enable the following APIs in your Google Cloud project:
- **Places API** - For finding nearby dental clinics
- **Maps SDK for Android** - For map functionality
- **Geocoding API** - For address conversion (optional)

### 1.3 Generate API Keys
1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key
4. **Important**: Restrict the API key to your app's package name and the enabled APIs

## Step 2: Update API Keys in Code

### 2.1 Update Clinic Service
Replace `YOUR_GOOGLE_PLACES_API_KEY` in `lib/services/clinic_service.dart`:

```dart
static const String _apiKey = 'YOUR_ACTUAL_GOOGLE_PLACES_API_KEY';
```

### 2.2 Update Android Manifest
Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_GOOGLE_MAPS_API_KEY" />
```

## Step 3: iOS Configuration (if developing for iOS)

### 3.1 Update Info.plist
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to find nearby dental clinics.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location to find nearby dental clinics.</string>
```

### 3.2 Add Google Maps API Key for iOS
Add to `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Step 4: Install Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^10.1.0          # Location services
  google_maps_flutter: ^2.5.3   # Google Maps integration
  geocoding: ^2.1.1            # Address geocoding
  url_launcher: ^6.2.1         # Open URLs (maps, phone, website)
```

Run the following command to install dependencies:
```bash
flutter pub get
```

## Step 5: Permissions Setup

### 5.1 Android Permissions
The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### 5.2 Runtime Permissions
The app will request location permissions at runtime when needed.

## Step 6: Testing the Feature

### 6.1 Test Location Services
1. Run the app on a physical device (GPS works better than emulator)
2. Navigate to the Clinics screen
3. Grant location permissions when prompted
4. Verify that nearby clinics are loaded

### 6.2 Test Mock Data
If the Google Places API is not configured, the app will fall back to mock data for testing.

### 6.3 Test Clinic Details
1. Tap on a clinic in the list
2. Verify that the clinic detail screen shows all information
3. Test the "Get Directions" and "Book Appointment" buttons

## Step 7: Customization Options

### 7.1 Search Radius
Modify the search radius in `lib/services/clinic_service.dart`:

```dart
static Future<List<Clinic>> getNearbyClinics({
  double? latitude,
  double? longitude,
  int radius = 5000, // Change this value (in meters)
}) async {
```

### 7.2 Clinic Types
Modify the search query in the same file:

```dart
'&type=dentist'
'&keyword=dental%20clinic'
```

### 7.3 UI Customization
- Colors are defined in the screen files
- Icons and images can be customized in the assets folder
- Text and labels can be modified for localization

## Troubleshooting

### Common Issues

1. **"No clinics found" error**
   - Check if Google Places API is enabled
   - Verify API key is correct and has proper restrictions
   - Check internet connection

2. **Location permission denied**
   - Ensure location permissions are granted in device settings
   - Check if location services are enabled on the device

3. **Maps not loading**
   - Verify Google Maps API key is correct
   - Check if Maps SDK for Android is enabled

4. **API quota exceeded**
   - Check Google Cloud Console for API usage
   - Consider implementing caching for clinic data

### Debug Mode
Enable debug logging by adding print statements in the service files:

```dart
print('Fetching clinics for location: $latitude, $longitude');
print('API Response: ${response.body}');
```

## Security Considerations

1. **API Key Security**
   - Never commit API keys to version control
   - Use environment variables or secure storage
   - Restrict API keys to specific apps and APIs

2. **Location Privacy**
   - Only request location when needed
   - Inform users about location usage
   - Implement proper data handling

## Future Enhancements

Potential improvements for the location feature:

1. **Caching**
   - Cache clinic data locally
   - Implement offline mode

2. **Advanced Search**
   - Filter by services offered
   - Filter by insurance accepted
   - Filter by appointment availability

3. **Real-time Updates**
   - Push notifications for new clinics
   - Real-time appointment availability

4. **Integration**
   - Direct appointment booking
   - Integration with clinic management systems
   - Payment processing

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Google Cloud Console documentation
3. Check Flutter and plugin documentation
4. Create an issue in the project repository 