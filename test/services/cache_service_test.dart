import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoopsleague/services/cache_service.dart';
import 'dart:io';

void main() {
  group('CacheService', () {
    late Directory testDir;

    setUp(() async {
      // Créer un répertoire temporaire pour les tests
      testDir = await Directory.systemTemp.createTemp('hive_test_');
      Hive.init(testDir.path);
    });

    tearDown(() async {
      // Nettoyer après chaque test
      await Hive.close();
      if (await testDir.exists()) {
        await testDir.delete(recursive: true);
      }
    });

    group('saveUserPoints', () {
      test('should save user points with date', () async {
        const uid = 'test_user_1';
        const points = 100.0;
        final now = DateTime(2025, 11, 23, 10, 0, 0);

        await CacheService.saveUserPoints(uid, points, now);

        final history = await CacheService.loadPointsHistory(uid);
        expect(history.length, 1);
        expect(history[0]['points'], 100.0);
        expect(history[0]['date'], now);
      });

      test('should round points to 2 decimal places', () async {
        const uid = 'test_user_2';
        const points = 123.456789;
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, points, now);

        final history = await CacheService.loadPointsHistory(uid);
        expect(history[0]['points'], 123.46);
      });

      test('should append to existing history', () async {
        const uid = 'test_user_3';
        final now1 = DateTime(2025, 11, 23, 10, 0, 0);
        final now2 = DateTime(2025, 11, 23, 11, 0, 0);

        await CacheService.saveUserPoints(uid, 100.0, now1);
        await CacheService.saveUserPoints(uid, 150.0, now2);

        final history = await CacheService.loadPointsHistory(uid);
        expect(history.length, 2);
        expect(history[0]['points'], 100.0);
        expect(history[1]['points'], 150.0);
      });
    });

    group('loadPointsHistory', () {
      test('should return empty list for new user', () async {
        const uid = 'new_user';

        final history = await CacheService.loadPointsHistory(uid);

        expect(history, isEmpty);
      });

      test('should return complete history', () async {
        const uid = 'test_user_4';
        final now1 = DateTime(2025, 11, 23, 10, 0, 0);
        final now2 = DateTime(2025, 11, 23, 11, 0, 0);
        final now3 = DateTime(2025, 11, 23, 12, 0, 0);

        await CacheService.saveUserPoints(uid, 100.0, now1);
        await CacheService.saveUserPoints(uid, 150.0, now2);
        await CacheService.saveUserPoints(uid, 200.0, now3);

        final history = await CacheService.loadPointsHistory(uid);

        expect(history.length, 3);
        expect(history[0]['points'], 100.0);
        expect(history[0]['date'], now1);
        expect(history[1]['points'], 150.0);
        expect(history[1]['date'], now2);
        expect(history[2]['points'], 200.0);
        expect(history[2]['date'], now3);
      });

      test('should parse dates correctly', () async {
        const uid = 'test_user_5';
        final now = DateTime(2025, 11, 23, 14, 30, 45);

        await CacheService.saveUserPoints(uid, 100.0, now);

        final history = await CacheService.loadPointsHistory(uid);

        expect(history[0]['date'], isA<DateTime>());
        expect(history[0]['date'], now);
      });
    });

    group('loadLastPoints', () {
      test('should return 0.0 for new user', () async {
        const uid = 'new_user_2';

        final points = await CacheService.loadLastPoints(uid);

        expect(points, 0.0);
      });

      test('should return last points from history', () async {
        const uid = 'test_user_6';
        final now1 = DateTime.now();
        final now2 = DateTime.now().add(const Duration(hours: 1));

        await CacheService.saveUserPoints(uid, 100.0, now1);
        await CacheService.saveUserPoints(uid, 250.0, now2);

        final points = await CacheService.loadLastPoints(uid);

        expect(points, 250.0);
      });

      test('should return correct type (double)', () async {
        const uid = 'test_user_7';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, 100.0, now);

        final points = await CacheService.loadLastPoints(uid);

        expect(points, isA<double>());
      });
    });

    group('clearUserCache', () {
      test('should clear user cache', () async {
        const uid = 'test_user_8';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, 100.0, now);
        
        // Vérifier que les données existent
        var history = await CacheService.loadPointsHistory(uid);
        expect(history.length, 1);

        // Effacer le cache
        await CacheService.clearUserCache(uid);

        // Vérifier que le cache est vide
        history = await CacheService.loadPointsHistory(uid);
        expect(history, isEmpty);
      });

      test('should not affect other users', () async {
        const uid1 = 'test_user_9';
        const uid2 = 'test_user_10';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid1, 100.0, now);
        await CacheService.saveUserPoints(uid2, 200.0, now);

        await CacheService.clearUserCache(uid1);

        final history1 = await CacheService.loadPointsHistory(uid1);
        final history2 = await CacheService.loadPointsHistory(uid2);

        expect(history1, isEmpty);
        expect(history2.length, 1);
        expect(history2[0]['points'], 200.0);
      });
    });

    group('clearCache', () {
      test('should delete entire cache box', () async {
        const uid1 = 'test_user_11';
        const uid2 = 'test_user_12';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid1, 100.0, now);
        await CacheService.saveUserPoints(uid2, 200.0, now);

        await CacheService.clearCache();

        // Après clearCache, le box est supprimé
        // Les nouvelles lectures devraient retourner des listes vides
        final history1 = await CacheService.loadPointsHistory(uid1);
        final history2 = await CacheService.loadPointsHistory(uid2);

        expect(history1, isEmpty);
        expect(history2, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle zero points', () async {
        const uid = 'test_user_13';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, 0.0, now);

        final points = await CacheService.loadLastPoints(uid);
        expect(points, 0.0);
      });

      test('should handle negative points', () async {
        const uid = 'test_user_14';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, -50.0, now);

        final points = await CacheService.loadLastPoints(uid);
        expect(points, -50.0);
      });

      test('should handle very large points', () async {
        const uid = 'test_user_15';
        final now = DateTime.now();
        const largePoints = 999999.99;

        await CacheService.saveUserPoints(uid, largePoints, now);

        final points = await CacheService.loadLastPoints(uid);
        expect(points, largePoints);
      });

      test('should handle multiple decimal places correctly', () async {
        const uid = 'test_user_16';
        final now = DateTime.now();

        await CacheService.saveUserPoints(uid, 123.999, now);

        final points = await CacheService.loadLastPoints(uid);
        expect(points, 124.0); // Arrondi à 2 décimales
      });
    });
  });
}
