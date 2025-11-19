import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoopsleague/services/cache_service.dart';

void main() {
  // Initialiser Hive pour les tests
  setUpAll(() async {
    await Hive.initFlutter();
  });

  // Nettoyer après chaque test
  tearDown(() async {
    await CacheService.clearCache();
  });

  group('CacheService', () {
    const testUid = 'test-user-123';

    test('saveUserPoints should save points with timestamp', () async {
      final now = DateTime(2024, 1, 15, 12, 0);
      const points = 1500.0;

      await CacheService.saveUserPoints(testUid, points, now);

      final history = await CacheService.loadPointsHistory(testUid);
      expect(history.length, 1);
      expect(history[0]['points'], 1500.0);
      expect(history[0]['date'], now);
    });

    test('saveUserPoints should append to existing history', () async {
      final now1 = DateTime(2024, 1, 15, 12, 0);
      final now2 = DateTime(2024, 1, 16, 12, 0);

      await CacheService.saveUserPoints(testUid, 1000.0, now1);
      await CacheService.saveUserPoints(testUid, 1200.0, now2);

      final history = await CacheService.loadPointsHistory(testUid);
      expect(history.length, 2);
      expect(history[0]['points'], 1000.0);
      expect(history[1]['points'], 1200.0);
    });

    test('saveUserPoints should round points to 2 decimals', () async {
      final now = DateTime(2024, 1, 15, 12, 0);
      const points = 1234.56789;

      await CacheService.saveUserPoints(testUid, points, now);

      final history = await CacheService.loadPointsHistory(testUid);
      expect(history[0]['points'], 1234.57);
    });

    test('loadPointsHistory should return empty list for new user', () async {
      final history = await CacheService.loadPointsHistory('new-user');
      expect(history, isEmpty);
    });

    test('loadPointsHistory should return all saved points', () async {
      final now1 = DateTime(2024, 1, 15, 12, 0);
      final now2 = DateTime(2024, 1, 16, 12, 0);
      final now3 = DateTime(2024, 1, 17, 12, 0);

      await CacheService.saveUserPoints(testUid, 1000.0, now1);
      await CacheService.saveUserPoints(testUid, 1100.0, now2);
      await CacheService.saveUserPoints(testUid, 1250.0, now3);

      final history = await CacheService.loadPointsHistory(testUid);
      expect(history.length, 3);
      expect(history[0]['points'], 1000.0);
      expect(history[1]['points'], 1100.0);
      expect(history[2]['points'], 1250.0);
    });

    test('loadLastPoints should return last saved points', () async {
      final now1 = DateTime(2024, 1, 15, 12, 0);
      final now2 = DateTime(2024, 1, 16, 12, 0);

      await CacheService.saveUserPoints(testUid, 1000.0, now1);
      await CacheService.saveUserPoints(testUid, 1500.0, now2);

      final lastPoints = await CacheService.loadLastPoints(testUid);
      expect(lastPoints, 1500.0);
    });

    test('loadLastPoints should return 0.0 for new user', () async {
      final lastPoints = await CacheService.loadLastPoints('new-user');
      expect(lastPoints, 0.0);
    });

    test('clearUserCache should clear specific user cache', () async {
      final now = DateTime(2024, 1, 15, 12, 0);

      await CacheService.saveUserPoints(testUid, 1000.0, now);
      await CacheService.saveUserPoints('other-user', 2000.0, now);

      await CacheService.clearUserCache(testUid);

      final history = await CacheService.loadPointsHistory(testUid);
      final otherHistory = await CacheService.loadPointsHistory('other-user');

      expect(history, isEmpty);
      expect(otherHistory.length, 1);
    });

    test('clearCache should delete entire cache', () async {
      final now = DateTime(2024, 1, 15, 12, 0);

      await CacheService.saveUserPoints(testUid, 1000.0, now);
      await CacheService.saveUserPoints('other-user', 2000.0, now);

      await CacheService.clearCache();

      final history = await CacheService.loadPointsHistory(testUid);
      final otherHistory = await CacheService.loadPointsHistory('other-user');

      expect(history, isEmpty);
      expect(otherHistory, isEmpty);
    });
  });
}
