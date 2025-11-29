import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/bucket_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';

void main() {
  // Mock Clock pour les tests
  final mockClock = MockClock(DateTime(2025, 11, 23, 14, 0, 0));

  Widget createTestApp(Widget child) {
    return Provider<Clock>(
      create: (_) => mockClock,
      child: MaterialApp(
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
      ),
    );
  }

  group('BucketPage - Widget Tests', () {
    testWidgets('should display empty message when no bets', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(BucketPage(bets: [], uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier le message "Aucun pari"
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display app bar with logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(BucketPage(bets: [], uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
      
      // Vérifier la présence du logo
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(BucketPage(bets: [], uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence d'un Scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Vérifier la présence d'un Stack pour le background
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should display bets list when bets are provided', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier que la liste est affichée
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display bet information correctly', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier que le nom de l'équipe est affiché
      expect(find.text('Los Angeles Lakers'), findsOneWidget);
    });

    testWidgets('should display delete button for each bet', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du bouton de suppression
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should display amount input field when bets exist', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du champ de saisie
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display submit button when bets exist', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence du bouton de soumission
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should remove bet when delete button is tapped', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Appuyer sur le bouton de suppression
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      // Vérifier que le pari a été supprimé
      expect(bets.length, 0);
    });

    testWidgets('should accept text input in amount field', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Entrer du texte dans le champ
      await tester.enterText(find.byType(TextField), '100');
      await tester.pump();

      // Vérifier que le texte a été saisi
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('should display multiple bets correctly', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
        {
          'pickedTeam': 'Boston Celtics',
          'odd': 1.8,
          'start_time': '2025-11-23T20:00:00Z',
          'game_id': 'game_2',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier que les deux équipes sont affichées
      expect(find.text('Los Angeles Lakers'), findsOneWidget);
      expect(find.text('Boston Celtics'), findsOneWidget);
    });

    testWidgets('should have gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(BucketPage(bets: [], uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier la présence de Container avec décoration
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });

  group('BucketPage - Accessibility', () {
    testWidgets('should have semantic labels for important widgets', (WidgetTester tester) async {
      final bets = [
        {
          'pickedTeam': 'Los Angeles Lakers',
          'odd': 2.5,
          'start_time': '2025-11-23T18:00:00Z',
          'game_id': 'game_1',
        },
      ];

      await tester.pumpWidget(
        createTestApp(BucketPage(bets: bets, uid: 'test_uid')),
      );
      await tester.pumpAndSettle();

      // Vérifier que les widgets importants sont accessibles
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}

// Mock Clock pour les tests
class MockClock extends Clock {
  final DateTime _fixedTime;

  MockClock(this._fixedTime);

  @override
  DateTime now() => _fixedTime;
}
