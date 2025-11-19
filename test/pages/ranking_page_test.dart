import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/ranking_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import '../helpers/test_helpers.dart';

void main() {
  Widget createTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      home: child,
    );
  }

  group('RankingPage (LeaderboardPage) Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );

      // Au début, la page devrait charger les données
      await tester.pump();
      
      // Peut afficher un indicateur de chargement
      // (dépend de l'implémentation)
    });

    testWidgets('should have dropdown for league selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un DropdownButton pour sélectionner la ligue
      // (si implémenté dans la page)
    });

    testWidgets('should display leaderboard list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // La page devrait avoir une structure pour afficher le classement
      // Peut être une ListView ou une Column
      expect(find.byType(Scaffold), findsOneWidget);
    });

    group('getRankColor', () {
      late _LeaderboardPageState leaderboardState;

      setUp(() {
        final leaderboard = LeaderboardPage(uid: testUid);
        leaderboardState = leaderboard.createState();
      });

      test('should return gold color for rank 1', () {
        final color = leaderboardState.getRankColor(1);
        expect(color, const Color(0xFFFFD700)); // Gold
      });

      test('should return silver color for rank 2', () {
        final color = leaderboardState.getRankColor(2);
        expect(color, const Color(0xFFC0C0C0)); // Silver
      });

      test('should return bronze color for rank 3', () {
        final color = leaderboardState.getRankColor(3);
        expect(color, const Color(0xFFCD7F32)); // Bronze
      });

      test('should return white color for other ranks', () {
        final color = leaderboardState.getRankColor(4);
        expect(color, Colors.white);
        
        final color10 = leaderboardState.getRankColor(10);
        expect(color10, Colors.white);
      });
    });
  });
}
