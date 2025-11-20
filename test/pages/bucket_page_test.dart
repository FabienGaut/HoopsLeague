import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/pages/bucket_page.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('BucketPage Widget Tests', () {
    const testUid = 'test-user-123';
    final emptyBets = <Map<String, dynamic>>[];

    testWidgets('should display AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: emptyBets,
          ),
        ),
      );

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: emptyBets,
          ),
        ),
      );

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
