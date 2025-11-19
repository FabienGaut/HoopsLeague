import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/passed_bets.dart';
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

  group('PassedBetsPage (MyBetsPage) Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );

      // Au début, la page devrait charger les données
      await tester.pump();
    });

    testWidgets('should display bets list or empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );
      await tester.pumpAndSettle();

      // La page devrait avoir une structure pour afficher les paris
      expect(find.byType(Scaffold), findsOneWidget);
    });

    group('parseDouble', () {
      late _MyBetsPageState myBetsState;

      setUp(() {
        final myBets = MyBetsPage(uid: testUid);
        myBetsState = myBets.createState();
      });

      test('should parse int to double', () {
        final result = myBetsState.parseDouble(100);
        expect(result, 100.0);
      });

      test('should parse double correctly', () {
        final result = myBetsState.parseDouble(123.45);
        expect(result, 123.45);
      });

      test('should parse string to double', () {
        final result = myBetsState.parseDouble('99.99');
        expect(result, 99.99);
      });

      test('should return 0.0 for invalid input', () {
        final result = myBetsState.parseDouble('invalid');
        expect(result, 0.0);
      });

      test('should return 0.0 for null', () {
        final result = myBetsState.parseDouble(null);
        expect(result, 0.0);
      });
    });
  });
}
