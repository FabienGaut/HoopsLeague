import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/home_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';

void main() {
  testWidgets('HomePage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        home: const HomePage(),
      ),
    );

    await tester.pumpAndSettle();

    // Vérifie qu’un texte connu est présent
    expect(find.text("Let's see if you know ball."), findsOneWidget);
  });
}
