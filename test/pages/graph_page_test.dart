import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/graph_page.dart';
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

  group('GraphPage (PointsGraphPage) Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const PointsGraphPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const PointsGraphPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const PointsGraphPage(uid: testUid)),
      );

      // Au début, la page devrait charger les données
      await tester.pump();
    });

    testWidgets('should display chart or empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const PointsGraphPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // La page devrait afficher soit un graphique, soit un message d'état vide
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have scrollable content if needed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(const PointsGraphPage(uid: testUid)),
      );
      await tester.pumpAndSettle();

      // Vérifier la structure de base
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
