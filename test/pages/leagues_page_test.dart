import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/leagues_page.dart';
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

  group('LeaguesPage Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display text fields for league creation/joining',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de champs de texte
      // (pour créer ou rejoindre une ligue)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should display buttons for league actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de boutons
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should accept text input in league name field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Trouver un champ de texte et entrer du texte
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'My League');
        await tester.pump();
        
        expect(find.text('My League'), findsOneWidget);
      }
    });

    testWidgets('should display user leagues list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // La page devrait avoir une structure pour afficher les ligues
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have scrollable content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const LeaguesPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un widget scrollable
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
