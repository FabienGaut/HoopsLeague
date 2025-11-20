import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/pages/games_page.dart';
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
      await tester.pump();
    });
  });
}
