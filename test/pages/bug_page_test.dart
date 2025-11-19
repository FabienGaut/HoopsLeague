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
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display text field for bug description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un champ de texte pour la description
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display submit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un bouton d'envoi
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should accept text input in description field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Entrer du texte dans le champ de description
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'This is a bug report');
      await tester.pump();

      expect(find.text('This is a bug report'), findsOneWidget);
    });

    testWidgets('should have multiline text field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier que le champ de texte accepte plusieurs lignes
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, greaterThan(1));
    });

    testWidgets('should display logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'une image (logo)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have back button in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const BugPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un bouton retour
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });
  });
}
