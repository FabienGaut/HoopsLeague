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
            onBetsChanged: (_) {},
          ),
        ),
      );

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display empty state when no bets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: emptyBets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier qu'il n'y a pas de paris affichés
      // La page devrait afficher un message ou un état vide
    });

    testWidgets('should display bets when provided',
        (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 1.85,
          'start_time': '2024-01-20T02:00:00Z',
          'game_id': 'game-1',
        },
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: bets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que le pari est affiché
      expect(find.textContaining('Lakers'), findsWidgets);
    });

    testWidgets('should have a TextField for bet amount',
        (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 1.85,
          'start_time': '2024-01-20T02:00:00Z',
          'game_id': 'game-1',
        },
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: bets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier la présence d'un champ de saisie pour le montant
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should display validate button', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 1.85,
          'start_time': '2024-01-20T02:00:00Z',
          'game_id': 'game-1',
        },
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: bets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier la présence d'un bouton de validation
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should display multiple bets correctly',
        (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 1.85,
          'start_time': '2024-01-20T02:00:00Z',
          'game_id': 'game-1',
        },
        {
          'pickedTeam': 'Boston Celtics',
          'odd': 2.10,
          'start_time': '2024-01-20T03:00:00Z',
          'game_id': 'game-2',
        },
      ];

      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: bets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifier que les deux paris sont affichés
      expect(find.textContaining('Lakers'), findsWidgets);
      expect(find.textContaining('Celtics'), findsWidgets);
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: BucketPage(
            uid: testUid,
            bets: emptyBets,
            onBetsChanged: (_) {},
          ),
        ),
      );

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
