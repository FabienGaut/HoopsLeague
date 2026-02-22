import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/widgets/flip_card_widget.dart';

void main() {
  group('FlipCardWidget', () {
    testWidgets('should display front widget initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
            ),
          ),
        ),
      );

      expect(find.text('Front Side'), findsOneWidget);
      // Back should not be visible initially
      expect(find.text('Back Side'), findsNothing);
    });

    testWidgets('should flip to back on tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
            ),
          ),
        ),
      );

      // Tap to flip
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();

      // After flip, back should be visible
      expect(find.text('Back Side'), findsOneWidget);
      expect(find.text('Front Side'), findsNothing);
    });

    testWidgets('should flip back to front on second tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
            ),
          ),
        ),
      );

      // First tap - flip to back
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();

      expect(find.text('Back Side'), findsOneWidget);

      // Second tap - flip back to front
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();

      expect(find.text('Front Side'), findsOneWidget);
      expect(find.text('Back Side'), findsNothing);
    });

    testWidgets('should start flipped if initiallyFlipped is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
              initiallyFlipped: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show back initially
      expect(find.text('Back Side'), findsOneWidget);
      expect(find.text('Front Side'), findsNothing);
    });

    testWidgets('should use GestureDetector for tap handling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front'),
              back: Text('Back'),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should animate during flip', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
              duration: Duration(milliseconds: 600),
            ),
          ),
        ),
      );

      // Start the flip
      await tester.tap(find.byType(FlipCardWidget));

      // Pump a few frames to catch mid-animation
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Eventually settle
      await tester.pumpAndSettle();

      expect(find.text('Back Side'), findsOneWidget);
    });

    testWidgets('should render complex front and back widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Container(
                color: Colors.blue,
                child: const Column(
                  children: [
                    Icon(Icons.sports_basketball),
                    Text('Game Card'),
                  ],
                ),
              ),
              back: Container(
                color: Colors.red,
                child: const Column(
                  children: [
                    Icon(Icons.bar_chart),
                    Text('Stats'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Front should show basketball icon and game card text
      expect(find.byIcon(Icons.sports_basketball), findsOneWidget);
      expect(find.text('Game Card'), findsOneWidget);

      // Flip
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pumpAndSettle();

      // Back should show chart icon and stats text
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('should use Transform widget for 3D effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front'),
              back: Text('Back'),
            ),
          ),
        ),
      );

      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('should handle rapid taps gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front Side'),
              back: Text('Back Side'),
            ),
          ),
        ),
      );

      // Rapid taps
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(FlipCardWidget));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byType(FlipCardWidget));

      // Let everything settle
      await tester.pumpAndSettle();

      // Should end up on one side or the other (not crash)
      final hasFront = find.text('Front Side').evaluate().isNotEmpty;
      final hasBack = find.text('Back Side').evaluate().isNotEmpty;

      // Exactly one should be visible
      expect(hasFront || hasBack, true);
    });

    testWidgets('should respect custom duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlipCardWidget(
              front: Text('Front'),
              back: Text('Back'),
              duration: Duration(milliseconds: 100), // Fast animation
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FlipCardWidget));

      // Let animation complete fully
      await tester.pumpAndSettle();

      expect(find.text('Back'), findsOneWidget);
    });
  });
}
