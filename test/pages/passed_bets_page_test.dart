import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/pages/passed_bets.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PassedBetsPage (MyBetsPage) Widget Tests', () {
    const testUid = 'test-user-123';

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );
      await tester.pump();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const MyBetsPage(uid: testUid),
        ),
      );
      await tester.pump();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}

