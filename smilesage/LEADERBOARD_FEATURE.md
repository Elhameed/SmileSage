# Global Leaderboard Feature

## Overview

The Global Leaderboard feature allows users to compete with each other based on their daily brushing streaks. Users can see their ranking among all app users and track their progress over time.

## Features

### 1. **Global Ranking System**
- Users are ranked based on their current brushing streak
- Top 100 users are displayed on the leaderboard
- Real-time updates when users mark themselves as brushed

### 2. **User Profile Integration**
- Displays user's display name and profile image
- Shows current streak count
- Highlights the current user's position

### 3. **Beautiful UI**
- Special badges for top 3 positions (Gold, Silver, Bronze)
- Gradient cards for current user's position
- Pull-to-refresh functionality
- Responsive design matching app theme

### 4. **Privacy & Performance**
- Only users with streaks > 0 appear on leaderboard
- Automatic cleanup of inactive users
- Efficient Firestore queries with pagination

## Technical Implementation

### Data Structure

```dart
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int currentStreak;
  final String? profileImage;
  final DateTime lastUpdated;
  final int rank;
}
```

### Firestore Structure

```
leaderboard/
  global/
    entries: [
      {
        userId: "user123",
        displayName: "John Doe",
        currentStreak: 15,
        profileImage: "base64...",
        lastUpdated: "2024-01-01T00:00:00.000Z",
        rank: 5
      }
    ]
    lastUpdated: timestamp
```

### Key Components

1. **LeaderboardService** (`lib/services/leaderboard_service.dart`)
   - Manages all leaderboard operations
   - Updates user streaks in real-time
   - Handles ranking calculations
   - Provides user rank queries

2. **LeaderboardScreen** (`lib/screens/leaderboard_screen.dart`)
   - Displays the global leaderboard
   - Shows current user's position
   - Handles refresh and error states
   - Beautiful UI with animations

3. **Integration Points**
   - **Tips Screen**: Updates leaderboard when user marks as brushed
   - **Home Screen**: Syncs leaderboard on app load
   - **Navigation**: Accessible from home screen brushing card

## Usage

### For Users

1. **Access Leaderboard**: Tap "Global Leaderboard" button on home screen
2. **View Rankings**: See top 50 users with their streaks
3. **Check Position**: View your current rank in the highlighted card
4. **Refresh**: Pull down to refresh leaderboard data

### For Developers

1. **Update User Streak**:
```dart
await leaderboardService.updateUserStreak(
  streak: currentStreak,
  displayName: user.displayName,
  profileImage: profileImageBase64,
);
```

2. **Fetch Top Users**:
```dart
final topUsers = await leaderboardService.getTopUsers(limit: 50);
```

3. **Get User Rank**:
```dart
final userRank = await leaderboardService.getUserRank();
```

## Localization

The leaderboard supports all app languages:
- **English**: "Global Leaderboard", "Top Brushers"
- **French**: "Classement Mondial", "Meilleurs Brosseurs"
- **Swahili**: "Orodha ya Wataalamu Duniani", "Waboreshi Bora"
- **Kinyarwanda**: "Urutonde rw'Abantu ku Isi", "Abakoza Amenyo Benshi"

## Performance Considerations

1. **Limited Entries**: Only top 100 users stored to maintain performance
2. **Efficient Queries**: Single document read for leaderboard data
3. **Background Updates**: Leaderboard updates don't block UI
4. **Error Handling**: Graceful fallback if leaderboard is unavailable

## Future Enhancements

1. **Weekly/Monthly Leaderboards**: Different time periods
2. **Achievement Badges**: Special badges for top positions
3. **Push Notifications**: Rank change notifications
4. **Social Features**: Share achievements on social media
5. **Regional Leaderboards**: Country/region-based rankings
6. **Privacy Toggle**: Allow users to opt out of leaderboard

## Testing

Run leaderboard tests:
```bash
flutter test test/leaderboard_test.dart
```

## Security

- Only authenticated users can update leaderboard
- User data is scoped to individual users
- Firestore security rules protect leaderboard data
- Profile images are optional and base64 encoded

## Troubleshooting

### Common Issues

1. **User not appearing on leaderboard**
   - Check if user has streak > 0
   - Verify user is authenticated
   - Check Firestore permissions

2. **Leaderboard not updating**
   - Verify internet connection
   - Check Firestore rules
   - Ensure user is logged in

3. **Performance issues**
   - Leaderboard limited to top 100 users
   - Consider implementing pagination for larger datasets
   - Cache leaderboard data locally

### Debug Mode

Enable debug logging in LeaderboardService to track operations:
```dart
print('Updating leaderboard for user: $userId, streak: $streak');
``` 