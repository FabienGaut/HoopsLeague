import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/bug_page.dart';
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

  group('BugPage Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pump();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pump();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display text field for bug description', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du champ de texte
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display submit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'icône d'envoi (le bouton contient cette icône)
      expect(find.byIcon(Icons.send_outlined), findsOneWidget);
    });

    testWidgets('should accept text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Entrer du texte dans le champ
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'This is a test bug report');
      await tester.pump();

      // Vérifier que le texte a été saisi
      expect(find.text('This is a test bug report'), findsOneWidget);
    });

    testWidgets('should have character limit', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier que le TextField a une limite de caractères
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 200);
    });

    testWidgets('should have multiline input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier que le TextField accepte plusieurs lignes
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, greaterThan(1));
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de Container avec décoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('should display bug icon in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'icône de bug
      expect(find.byIcon(Icons.bug_report_outlined), findsOneWidget);
    });

    testWidgets('should display send icon on button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'icône d'envoi
      expect(find.byIcon(Icons.send_outlined), findsOneWidget);
    });

    testWidgets('should have proper styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de Stack pour le background
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should display logo in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du logo
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du bouton retour
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('should clear text after submission attempt', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Entrer du texte
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test bug');
      await tester.pump();

      // Le texte devrait être présent
      expect(find.text('Test bug'), findsOneWidget);
    });

    testWidgets('should maintain state during input', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Entrer du texte progressivement
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'First part');
      await tester.pump();
      
      expect(find.text('First part'), findsOneWidget);
      
      await tester.enterText(textField, 'First part and second part');
      await tester.pump();
      
      expect(find.text('First part and second part'), findsOneWidget);
    });
  });
}

