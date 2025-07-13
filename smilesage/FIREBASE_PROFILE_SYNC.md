# Firebase Profile Synchronization

This document explains how user profile data is synchronized with Firebase Firestore in the SmileSage app.

## Overview

The app now syncs user profile data (name, age, profile picture, and preferences) with Firebase Firestore to ensure data persistence across devices and app sessions.

## Architecture

### ProfileService
Located at `lib/services/profile_service.dart`, this service handles all Firebase operations:

- **Profile Management**: Create, read, update user profiles
- **Image Storage**: Upload profile images to Firebase Storage
- **Preferences Sync**: Sync user preferences across devices
- **Authentication**: Integrates with Firebase Auth

### Data Structure

User profiles are stored in Firestore with the following structure:

```json
{
  "users": {
    "userId": {
      "displayName": "John Doe",
      "age": "25",
      "profileImageBase64": "base64_encoded_image",
      "preferences": {
        "dailyTips": true,
        "brushingReminders": false,
        "hasBraces": true
      },
      "lastUpdated": "timestamp"
    }
  }
}
```

## Features

### 1. Profile Data Sync
- **Name**: Updates both Firebase Auth and Firestore
- **Age**: Stored in Firestore
- **Profile Image**: Base64 encoded and stored in Firestore
- **Preferences**: All toggles sync to Firestore

### 2. Cross-Device Synchronization
- Profile data syncs across all user devices
- Preferences are consistent everywhere
- Profile images are accessible from any device

### 3. Offline Support
- Local SharedPreferences backup for offline functionality
- Graceful fallback when Firebase is unavailable
- Automatic sync when connection is restored

### 4. Error Handling
- Comprehensive error handling for network issues
- User-friendly error messages
- Fallback to local data when Firebase fails

## Implementation Details

### Profile Initialization
When a user first logs in, their profile is automatically initialized in Firebase:

```dart
await profileService.initializeProfile();
```

### Data Loading
Profile data is loaded from Firebase with local fallback:

```dart
final profile = await profileService.getProfile();
// Fallback to local data if Firebase fails
```

### Real-time Updates
All profile changes are immediately synced to Firebase:

```dart
await profileService.updateDisplayName(name);
await profileService.updateAge(age);
await profileService.updateProfileImage(base64Image);
await profileService.syncPreferences(preferences);
```

## Screens Integration

### Profile Screen
- Loads profile data from Firebase on init
- Saves all changes to Firebase
- Shows loading states during sync
- Handles errors gracefully

### Permissions Screen
- Syncs preference changes to Firebase
- Maintains local SharedPreferences for backward compatibility

### Reminders Screen
- Syncs notification preferences to Firebase
- Ensures consistency across devices

## Security

- All operations require user authentication
- Data is scoped to individual users
- Profile images are stored securely in Firebase Storage
- User data is protected by Firebase Security Rules

## Testing

To test the Firebase sync:

1. **Create a new account** and verify profile initialization
2. **Update profile data** and check Firebase console
3. **Test offline functionality** by disabling network
4. **Verify cross-device sync** by logging in on multiple devices
5. **Check error handling** by temporarily disabling Firebase

## Firebase Console Setup

Ensure your Firebase project has:

1. **Firestore Database** enabled
2. **Storage** enabled for profile images
3. **Authentication** configured
4. **Security Rules** set up properly

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues

1. **Profile not loading**: Check Firebase connection and authentication
2. **Images not uploading**: Verify Storage permissions and rules
3. **Preferences not syncing**: Check Firestore rules and network connection
4. **Slow performance**: Consider implementing caching strategies

### Debug Mode
Enable debug logging by adding print statements in ProfileService methods to track Firebase operations.

## Future Enhancements

- Real-time profile updates using Firestore listeners
- Profile image compression and optimization
- Advanced caching strategies
- Profile data export/import functionality
- Multi-language profile support 