import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/pages/games_page.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('GamesPage Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with logo and title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GamesPage(uid: testUid),
        ),
      );

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Vérifier le titre
      expect(find.text('HoopsLeague'), findsOneWidget);
    });

    testWidgets('should have a drawer', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GamesPage(uid: testUid),
        ),
      );

      // Vérifier la présence d'un Drawer
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GamesPage(uid: testUid),
        ),
      );

      // Au début, la page devrait charger les données
      // On peut vérifier la présence d'un CircularProgressIndicator
      // ou d'un état de chargement
      await tester.pump();
    });

    group('Team colors and emojis', () {
      late _GamesPageState gamesPageState;

      setUp(() {
        // Créer une instance de l'état pour tester les méthodes
        final gamesPage = GamesPage(uid: testUid);
        gamesPageState = gamesPage.createState();
      });

      test('getTeamColor should return correct color for Lakers', () {
        final color = gamesPageState.getTeamColor('Los Angeles Lakers');
        expect(color, const Color(0xFF552583)); // Purple Lakers
      });

      test('getTeamColor should return correct color for Celtics', () {
        final color = gamesPageState.getTeamColor('Boston Celtics');
        expect(color, const Color(0xFF007A33)); // Green Celtics
      });

      test('getTeamEmoji should return correct emoji for Lakers', () {
        final emoji = gamesPageState.getTeamEmoji('Los Angeles Lakers');
        expect(emoji, '🌴');
      });

      test('getTeamEmoji should return correct emoji for Celtics', () {
        final emoji = gamesPageState.getTeamEmoji('Boston Celtics');
        expect(emoji, '🍀');
      });

      test('getTeamEmoji should return basketball emoji for unknown team', () {
        final emoji = gamesPageState.getTeamEmoji('Unknown Team');
        expect(emoji, '🏀');
      });
    });

    group('formatGameTime', () {
      late _GamesPageState gamesPageState;
      late MockClock mockClock;

      setUp(() {
        final gamesPage = GamesPage(uid: testUid);
        gamesPageState = gamesPage.createState();
        mockClock = MockClock(time: DateTime.utc(2024, 1, 15, 12, 0));
      });

      test('should format UTC time correctly', () {
        final utcString = '2024-01-20T02:00:00Z';
        final formatted = gamesPageState.formatGameTime(utcString, mockClock);

        // Vérifier que le format contient au moins une date
        expect(formatted, isNotEmpty);
        expect(formatted.contains('Jan') || formatted.contains('janv'), true);
      });

      test('should return original string on parse error', () {
        const invalidString = 'invalid-date';
        final formatted = gamesPageState.formatGameTime(invalidString, mockClock);

        expect(formatted, invalidString);
      });
    });

    group('convertOdds', () {
      late _GamesPageState gamesPageState;

      setUp(() {
        final gamesPage = GamesPage(uid: testUid);
        gamesPageState = gamesPage.createState();
      });

      test('should convert to FR format correctly', () {
        expect(gamesPageState.convertOdds(1.85, 'FR'), '1.85');
        expect(gamesPageState.convertOdds(2.50, 'FR'), '2.50');
      });

      test('should convert to UK format correctly', () {
        final result = gamesPageState.convertOdds(2.00, 'UK');
        expect(result, '1/1'); // Even money
      });

      test('should convert to US format correctly', () {
        expect(gamesPageState.convertOdds(2.00, 'US'), '+100');
        expect(gamesPageState.convertOdds(1.50, 'US'), '-200');
      });
    });
  });
}
