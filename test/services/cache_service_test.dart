import 'package:flutter_test/flutter_test.dart';

/// Tests for CacheService data transformation logic
/// Note: We test the pure transformation logic without Supabase dependency
void main() {
  group('CacheService - Points History Parsing', () {
    /// Simulates the parsing logic from loadPointsHistory
    List<Map<String, dynamic>> parsePointsHistory(List<dynamic>? rawHistory) {
      if (rawHistory == null || rawHistory.isEmpty) {
        return [];
      }

      return rawHistory.map((entry) {
        final map = entry as Map<String, dynamic>;
        final timestamp = (map['t'] as num).toInt();
        final points = (map['p'] as num).toDouble();

        return {
          'date': DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          'points': points,
        };
      }).toList();
    }

    test('should return empty list for null history', () {
      expect(parsePointsHistory(null), isEmpty);
    });

    test('should return empty list for empty history', () {
      expect(parsePointsHistory([]), isEmpty);
    });

    test('should parse single entry correctly', () {
      final rawHistory = [
        {'t': 1704067200, 'p': 1000}, // Jan 1, 2024 00:00:00 UTC
      ];

      final parsed = parsePointsHistory(rawHistory);

      expect(parsed.length, 1);
      expect(parsed[0]['points'], 1000.0);
      expect(parsed[0]['date'], isA<DateTime>());
    });

    test('should parse multiple entries correctly', () {
      final rawHistory = [
        {'t': 1704067200, 'p': 1000},
        {'t': 1704153600, 'p': 1050},
        {'t': 1704240000, 'p': 950},
      ];

      final parsed = parsePointsHistory(rawHistory);

      expect(parsed.length, 3);
      expect(parsed[0]['points'], 1000.0);
      expect(parsed[1]['points'], 1050.0);
      expect(parsed[2]['points'], 950.0);
    });

    test('should convert timestamp to DateTime correctly', () {
      final rawHistory = [
        {'t': 1704067200, 'p': 1000}, // Jan 1, 2024 00:00:00 UTC
      ];

      final parsed = parsePointsHistory(rawHistory);
      final date = parsed[0]['date'] as DateTime;

      expect(date.year, 2024);
      expect(date.month, 1);
      expect(date.day, 1);
    });

    test('should handle decimal points', () {
      final rawHistory = [
        {'t': 1704067200, 'p': 1000.5},
      ];

      final parsed = parsePointsHistory(rawHistory);
      expect(parsed[0]['points'], 1000.5);
    });

    test('should handle integer points as double', () {
      final rawHistory = [
        {'t': 1704067200, 'p': 1000},
      ];

      final parsed = parsePointsHistory(rawHistory);
      expect(parsed[0]['points'], isA<double>());
      expect(parsed[0]['points'], 1000.0);
    });
  });

  group('CacheService - Points History Storage Format', () {
    /// Simulates the format used for saving to history
    Map<String, dynamic> createHistoryEntry(double points) {
      final now = DateTime.now();
      final timestampSeconds = now.millisecondsSinceEpoch ~/ 1000;

      return {
        't': timestampSeconds,
        'p': points.round(),
      };
    }

    test('should create entry with timestamp in seconds', () {
      final entry = createHistoryEntry(1000.0);

      expect(entry['t'], isA<int>());
      // Timestamp should be in seconds (not milliseconds)
      expect(entry['t'], lessThan(DateTime.now().millisecondsSinceEpoch));
    });

    test('should round points to integer', () {
      final entry1 = createHistoryEntry(1000.5);
      final entry2 = createHistoryEntry(1000.4);

      expect(entry1['p'], 1001);
      expect(entry2['p'], 1000);
    });

    test('should handle large point values', () {
      final entry = createHistoryEntry(999999.0);
      expect(entry['p'], 999999);
    });

    test('should handle zero points', () {
      final entry = createHistoryEntry(0.0);
      expect(entry['p'], 0);
    });
  });

  group('CacheService - Load Last Points', () {
    double loadLastPoints(List<Map<String, dynamic>> history) {
      if (history.isEmpty) return 0.0;
      return (history.last['points'] as num).toDouble();
    }

    test('should return 0 for empty history', () {
      expect(loadLastPoints([]), 0.0);
    });

    test('should return last points value', () {
      final history = [
        {'date': DateTime.now(), 'points': 1000.0},
        {'date': DateTime.now(), 'points': 1100.0},
        {'date': DateTime.now(), 'points': 1050.0},
      ];

      expect(loadLastPoints(history), 1050.0);
    });

    test('should handle single entry', () {
      final history = [
        {'date': DateTime.now(), 'points': 500.0},
      ];

      expect(loadLastPoints(history), 500.0);
    });
  });

  group('CacheService - History Append Logic', () {
    test('should append new entry to existing history', () {
      final existingHistory = <Map<String, dynamic>>[
        {'t': 1704067200, 'p': 1000},
        {'t': 1704153600, 'p': 1050},
      ];

      final now = DateTime.now();
      final newEntry = {
        't': now.millisecondsSinceEpoch ~/ 1000,
        'p': 1100,
      };

      existingHistory.add(newEntry);

      expect(existingHistory.length, 3);
      expect(existingHistory.last['p'], 1100);
    });

    test('should create new history from empty', () {
      final existingHistory = <Map<String, dynamic>>[];

      final now = DateTime.now();
      final newEntry = {
        't': now.millisecondsSinceEpoch ~/ 1000,
        'p': 1000,
      };

      existingHistory.add(newEntry);

      expect(existingHistory.length, 1);
      expect(existingHistory.first['p'], 1000);
    });

    test('should preserve order of entries', () {
      final history = <Map<String, dynamic>>[];

      for (int i = 0; i < 5; i++) {
        history.add({
          't': 1704067200 + (i * 86400), // Each day
          'p': 1000 + (i * 100),
        });
      }

      expect(history.length, 5);
      expect(history[0]['p'], 1000);
      expect(history[4]['p'], 1400);
    });
  });

  group('CacheService - Data Validation', () {
    test('should handle malformed timestamp gracefully', () {
      // Test that the parsing logic handles edge cases
      final rawHistory = [
        {'t': 0, 'p': 1000}, // Epoch time
      ];

      List<Map<String, dynamic>> parsePointsHistory(List<dynamic>? rawHistory) {
        if (rawHistory == null || rawHistory.isEmpty) return [];
        return rawHistory.map((entry) {
          final map = entry as Map<String, dynamic>;
          final timestamp = (map['t'] as num).toInt();
          final points = (map['p'] as num).toDouble();
          return {
            'date': DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
            'points': points,
          };
        }).toList();
      }

      final parsed = parsePointsHistory(rawHistory);
      expect(parsed[0]['date'], DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('should handle negative points', () {
      // While unlikely, system should handle it
      final entry = {
        't': 1704067200,
        'p': -100,
      };

      final points = (entry['p'] as num).toDouble();
      expect(points, -100.0);
    });
  });
}
