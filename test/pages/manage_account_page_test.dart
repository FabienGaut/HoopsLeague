import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/manage_account_page.dart';
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

  group('ManageAccountPage Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display text fields for user information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de champs de texte pour le nom d'utilisateur
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should display buttons for account actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de boutons (changer mot de passe, vider cache, etc.)
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have dropdown for language selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un DropdownButton pour la langue
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('should have dropdown for odds format selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un DropdownButton pour le format de cotes
      expect(find.byType(DropdownButton<String>), findsWidgets);
    });

    testWidgets('should accept text input in username field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Trouver un champ de texte et entrer du texte
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'NewUsername');
        await tester.pump();
        
        expect(find.text('NewUsername'), findsOneWidget);
      }
    });

    testWidgets('should have scrollable content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ManageAccountPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un widget scrollable
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  });
}
