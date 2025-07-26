import 'package:flutter_test/flutter_test.dart';
import 'package:smilesage/models/brushing_log.dart';

// Copied from home_screen.dart/tips_screen.dart for test purposes
typedef StreakCalculator = int Function(List<BrushingLog> logs);

int calculateStreak(List<BrushingLog> logs) {
  if (logs.isEmpty) return 0;
  logs.sort((a, b) => b.date.compareTo(a.date));
  int streak = 1;
  DateTime prev = logs.first.date;
  for (int i = 1; i < logs.length; i++) {
    final diff = prev.difference(logs[i].date).inDays;
    if (diff == 1) {
      streak++;
      prev = logs[i].date;
    } else if (diff > 1) {
      break;
    }
  }
  return streak;
}

void printLogAnalysis(String testName, List<BrushingLog> logs, int result) {
  print('--- $testName ---');
  print('Input logs:');
  for (var log in logs) {
    print('  - ${log.date.toIso8601String()}');
  }
  print('Calculated streak: $result');
  print('-------------------');
}

void main() {
  group('Streak Calculation', () {
    test('Empty logs returns 0', () {
      final logs = <BrushingLog>[];
      final result = calculateStreak(logs);
      printLogAnalysis('Empty logs returns 0', logs, result);
      expect(result, 0);
    });

    test('Single log returns streak of 1', () {
      final logs = [BrushingLog(date: DateTime(2024, 6, 1))];
      final result = calculateStreak(logs);
      printLogAnalysis('Single log returns streak of 1', logs, result);
      expect(result, 1);
    });

    test('Consecutive days increments streak', () {
      final logs = [
        BrushingLog(date: DateTime(2024, 6, 3)),
        BrushingLog(date: DateTime(2024, 6, 2)),
        BrushingLog(date: DateTime(2024, 6, 1)),
      ];
      final result = calculateStreak(logs);
      printLogAnalysis('Consecutive days increments streak', logs, result);
      expect(result, 3);
    });

    test('Non-consecutive days resets streak at gap', () {
      final logs = [
        BrushingLog(date: DateTime(2024, 6, 5)),
        BrushingLog(date: DateTime(2024, 6, 3)), // gap here
        BrushingLog(date: DateTime(2024, 6, 2)),
      ];
      final result = calculateStreak(logs);
      printLogAnalysis(
          'Non-consecutive days resets streak at gap', logs, result);
      expect(result, 1);
    });

    test('Multiple gaps, only most recent streak is counted', () {
      final logs = [
        BrushingLog(date: DateTime(2024, 6, 10)),
        BrushingLog(date: DateTime(2024, 6, 9)),
        BrushingLog(date: DateTime(2024, 6, 7)), // gap here
        BrushingLog(date: DateTime(2024, 6, 6)),
      ];
      final result = calculateStreak(logs);
      printLogAnalysis(
          'Multiple gaps, only most recent streak is counted', logs, result);
      expect(result, 2);
    });

    test('Same-day logs do not increment streak', () {
      final logs = [
        BrushingLog(date: DateTime(2024, 6, 5, 8)),
        BrushingLog(date: DateTime(2024, 6, 5, 20)),
        BrushingLog(date: DateTime(2024, 6, 4)),
      ];
      final result = calculateStreak(logs);
      printLogAnalysis('Same-day logs do not increment streak', logs, result);
      expect(result, 2);
    });
  });
}
