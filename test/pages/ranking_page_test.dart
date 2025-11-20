import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/ranking_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';

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
      await tester.pump();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaderboardPage(uid: testUid)),
      );
      await tester.pump();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

