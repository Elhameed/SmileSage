# Firestore Security Rules for Leaderboard Feature

## Problem
The leaderboard feature is getting a "permission-denied" error because the current Firestore security rules don't allow access to the `leaderboard` collection.

## Solution
Update your Firestore security rules to include permissions for the leaderboard collection.

## Required Firestore Rules

Add these rules to your `firestore.rules` file in the Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Existing user rules
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // NEW: Leaderboard rules
    match /leaderboard/{document} {
      // Allow authenticated users to read the global leaderboard
      allow read: if request.auth != null;
      
      // Allow authenticated users to write to the global leaderboard
      // This allows users to update their own entries
      allow write: if request.auth != null;
    }
  }
}
```

## Alternative: More Restrictive Rules

If you want more restrictive rules that only allow users to update their own entries:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Existing user rules
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Leaderboard rules with more restrictions
    match /leaderboard/{document} {
      // Allow all authenticated users to read the leaderboard
      allow read: if request.auth != null;
      
      // Allow users to write only if they're updating their own entry
      allow write: if request.auth != null && 
        (resource == null || 
         resource.data.entries[request.auth.uid] != null ||
         request.resource.data.entries[request.auth.uid] != null);
    }
  }
}
```

## How to Update Firestore Rules

### Option 1: Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database** → **Rules**
4. Replace the existing rules with the ones above
5. Click **Publish**

### Option 2: Firebase CLI
1. Create a `firestore.rules` file in your project root
2. Add the rules above to the file
3. Deploy using Firebase CLI:
   ```bash
   firebase deploy --only firestore:rules
   ```

## Testing the Rules

After updating the rules, test the leaderboard feature:

1. **Restart the app** to ensure it picks up the new rules
2. **Navigate to the leaderboard** from the home screen
3. **Mark yourself as brushed** in the tips screen
4. **Check if the leaderboard updates** correctly

## Troubleshooting

### If you still get permission errors:

1. **Check Authentication**: Ensure the user is properly authenticated
2. **Verify Rules**: Make sure the rules are published and active
3. **Clear Cache**: Restart the app completely
4. **Check Firebase Project**: Ensure you're using the correct Firebase project

### Common Issues:

1. **Rules not published**: Make sure to click "Publish" in Firebase Console
2. **Wrong project**: Verify you're in the correct Firebase project
3. **Authentication issues**: Check if the user is properly logged in
4. **Cached rules**: Firebase sometimes caches rules, restart the app

## Security Considerations

The leaderboard rules allow:
- ✅ **Read access** for all authenticated users (to view leaderboard)
- ✅ **Write access** for all authenticated users (to update their entries)
- ❌ **No access** for unauthenticated users

This is appropriate for a leaderboard feature where:
- All users should be able to see the rankings
- Users should be able to update their own entries
- Only authenticated users can participate

## Monitoring

After deploying the rules, monitor your Firestore usage:
1. Check **Firestore Database** → **Usage** for any unusual activity
2. Monitor **Authentication** → **Users** for new sign-ups
3. Review **Firestore Database** → **Data** to see leaderboard entries

## Next Steps

Once the rules are updated:
1. Test the leaderboard functionality
2. Monitor for any security issues
3. Consider implementing more restrictive rules if needed
4. Add analytics to track leaderboard usage 