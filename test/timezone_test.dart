import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 1. Créer un MockClock
class MockClock extends Clock {
  @override
  DateTime now() => DateTime.utc(2024, 7, 20, 10, 30); // 10:30 UTC
}

// 3. Créer un widget de test qui affiche l'heure
class TimeDisplayWidget extends StatelessWidget {
  const TimeDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final clock = Provider.of<Clock>(context);
    final now = clock.now();
    final formattedTime = DateFormat('HH:mm').format(now.toLocal());

    return Text(formattedTime);
  }
}

void main() {
  // Initialiser Flutter pour les tests de widget
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TimeDisplayWidget shows correct time in a mocked timezone', (WidgetTester tester) async {
    // 2. Initialiser et définir un fuseau horaire
    tz.initializeTimeZones();
    final location = tz.getLocation('America/Los_Angeles'); // UTC-7
    tz.setLocalLocation(location);

    // L'heure UTC est 10:30. À Los Angeles (UTC-7), il devrait être 03:30.
    const expectedTime = '03:30';

    await tester.pumpWidget(
      MaterialApp(
        home: Provider<Clock>(
          create: (_) => MockClock(),
          child: const TimeDisplayWidget(),
        ),
      ),
    );

    // Vérifier que le widget affiche bien 03:30
    expect(find.text(expectedTime), findsOneWidget);
  });
}
