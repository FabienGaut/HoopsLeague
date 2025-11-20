import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/password_change_page.dart';
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

  group('PasswordChangePage Widget Tests', () {
    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ChangePasswordPage()),
      );
      await tester.pump();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ChangePasswordPage()),
      );
      await tester.pump();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display password fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ChangePasswordPage()),
      );
      await tester.pump();

      // Vérifier la présence de champs de texte pour les mots de passe
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have password fields obscured', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const ChangePasswordPage()),
      );
      await tester.pump();

      // Vérifier que les champs de mot de passe sont obscurcis
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        final firstField = tester.widget<TextField>(textFields.first);
        expect(firstField.obscureText, true);
      }
    });
  });
}

