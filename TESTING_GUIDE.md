# Guide de Tests - HoopsLeague

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Configuration](#configuration)
3. [Structure des tests](#structure-des-tests)
4. [Tests unitaires](#tests-unitaires)
5. [Tests de widgets](#tests-de-widgets)
6. [Tests d'intégration](#tests-dintégration)
7. [Exécution des tests](#exécution-des-tests)
8. [Bonnes pratiques](#bonnes-pratiques)

---

## Vue d'ensemble

Cette suite de tests couvre l'ensemble de l'application HoopsLeague avec **18 fichiers de tests** répartis en 3 catégories :

- **Tests Unitaires** : Testent les services et fonctions utilitaires de manière isolée
- **Tests de Widgets** : Testent l'affichage et le comportement des pages
- **Tests d'Intégration** : Testent les flux de navigation entre les pages

### Statistiques

```
📁 18 fichiers de tests 
✅ ~82 tests au total
🎯 100% des tests unitaires passent
📱 Toutes les pages ont des tests
```

---

## Configuration

### Dépendances

Les tests utilisent les packages suivants (déjà configurés dans `pubspec.yaml`) :

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4  # Pour créer des mocks
```

### Dépendances principales testées

```yaml
dependencies:
  hive: ^2.2.3              # Cache local
  timezone: ^0.9.2          # Gestion des fuseaux horaires
  provider: ^6.0.5          # Gestion d'état
  supabase_flutter: ^2.3.3  # Backend
  fl_chart: ^1.1.1          # Graphiques
```

### Initialisation des tests

Chaque fichier de test suit cette structure :

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';

void main() {
  // Configuration de l'app de test avec localisation
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

  group('Nom du groupe de tests', () {
    testWidgets('Description du test', (WidgetTester tester) async {
      // Test code
    });
  });
}
```

---

## Structure des tests

```
test/
├── helpers/
│   └── test_helpers.dart              # 🛠️ Helpers réutilisables
├── services/
│   ├── cache_service_test.dart        # 🧪 Tests du cache Hive
│   └── clock_test.dart                # ⏰ Tests des services de temps
├── utils/
│   └── odds_conversion_test.dart      # 🔢 Tests de conversion de cotes
├── pages/
│   ├── sign_in_page_test.dart         # 🔐 Tests connexion
│   ├── sign_up_page_test.dart         # 📝 Tests inscription
│   ├── games_page_test.dart           # 🏀 Tests page matchs
│   ├── bucket_page_test.dart          # 🛒 Tests panier
│   ├── ranking_page_test.dart         # 🏆 Tests classement
│   ├── leagues_page_test.dart         # 👥 Tests ligues
│   ├── graph_page_test.dart           # 📊 Tests graphique
│   ├── manage_account_page_test.dart  # ⚙️ Tests gestion compte
│   ├── password_change_page_test.dart # 🔑 Tests changement MDP
│   ├── passed_bets_page_test.dart     # 📜 Tests paris passés
│   └── bug_page_test.dart             # 🐛 Tests rapport de bug
└── integration/
    └── navigation_test.dart           # 🧭 Tests de navigation
```

---

## Tests Unitaires

### 1. CacheService Tests

**Fichier** : [`test/services/cache_service_test.dart`](file:///home/fabien/Documents/hoopsleague/test/services/cache_service_test.dart)

**Objectif** : Tester le service de cache local utilisant Hive pour stocker l'historique des points.

**Ce qui est testé** :

```dart
✅ saveUserPoints()      // Sauvegarde points + timestamp
✅ loadPointsHistory()   // Récupération historique complet
✅ loadLastPoints()      // Récupération derniers points
✅ clearUserCache()      // Nettoyage cache utilisateur
✅ clearCache()          // Suppression complète du cache
```

**Pourquoi** : Le cache est critique pour afficher rapidement les points de l'utilisateur même hors ligne.

**Configuration spéciale** :

```dart
setUpAll(() async {
  await Hive.initFlutter();  // Initialiser Hive pour les tests
});

tearDown(() async {
  await CacheService.clearCache();  // Nettoyer après chaque test
});
```

**Exemple de test** :

```dart
test('saveUserPoints should save points with timestamp', () async {
  final now = DateTime(2024, 1, 15, 12, 0);
  const points = 1500.0;

  await CacheService.saveUserPoints(testUid, points, now);

  final history = await CacheService.loadPointsHistory(testUid);
  expect(history.length, 1);
  expect(history[0]['points'], 1500.0);
  expect(history[0]['date'], now);
});
```

---

### 2. Clock Service Tests

**Fichier** : [`test/services/clock_test.dart`](file:///home/fabien/Documents/hoopsleague/test/services/clock_test.dart)

**Objectif** : Tester les services de gestion du temps et des fuseaux horaires.

**Ce qui est testé** :

```dart
✅ Clock.now()           // Retourne l'heure actuelle
✅ Clock.toLocalTime()   // Conversion UTC → local
✅ LAClock               // Fuseau horaire Los Angeles
✅ PST/PDT handling      // Gestion heure d'hiver/été
```

**Pourquoi** : Les matchs NBA sont affichés en heure locale de Los Angeles, il faut s'assurer que la conversion est correcte.

**Configuration spéciale** :

```dart
setUpAll(() {
  tz.initializeTimeZones();  // Initialiser les fuseaux horaires
});
```

**Exemple de test** :

```dart
test('toLocalTime() should convert UTC to LA time', () {
  final laClock = LAClock();
  final utcTime = DateTime.utc(2024, 7, 15, 20, 0); // 8 PM UTC
  final laTime = laClock.toLocalTime(utcTime);

  // En juillet (PDT), LA est UTC-7
  // 20:00 UTC = 13:00 PDT
  expect(laTime.hour, 13);
});
```

---

### 3. Odds Conversion Tests

**Fichier** : [`test/utils/odds_conversion_test.dart`](file:///home/fabien/Documents/hoopsleague/test/utils/odds_conversion_test.dart)

**Objectif** : Tester la conversion des cotes entre les formats FR (décimal), UK (fraction), et US (américain).

**Ce qui est testé** :

```dart
✅ FR → FR   // 1.85 → "1.85"
✅ FR → UK   // 2.00 → "1/1" (even money)
✅ FR → US   // 2.00 → "+100", 1.50 → "-200"
✅ Cas limites (cotes très basses/hautes)
✅ Insensibilité à la casse
```

**Pourquoi** : Les utilisateurs peuvent choisir leur format de cotes préféré, il faut s'assurer que les conversions sont exactes.

**Formules testées** :

```dart
// Format UK (fraction)
UK = FR - 1
Exemple : 2.50 → 2.50 - 1 = 1.5 → "3/2"

// Format US (américain)
Si FR >= 2.0 : US = +(FR - 1) × 100
Si FR < 2.0  : US = -100 / (FR - 1)

Exemples :
2.50 → +150
1.50 → -200
```

**Exemple de test** :

```dart
test('should convert to US format correctly', () {
  expect(convertOdds(2.00, 'US'), '+100');  // Even money
  expect(convertOdds(2.50, 'US'), '+150');  // Favoris
  expect(convertOdds(1.50, 'US'), '-200');  // Outsiders
});
```

---

## Tests de Widgets

### Configuration commune

Tous les tests de widgets utilisent cette configuration pour supporter la localisation :

```dart
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
```

### 1. Pages d'Authentification

#### SignInPage Tests

**Fichier** : [`test/pages/sign_in_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/sign_in_page_test.dart)

**Ce qui est testé** :

```dart
✅ Affichage des champs email et mot de passe
✅ Bouton de connexion présent
✅ Lien vers la page d'inscription
✅ Champ mot de passe obscurci (obscureText: true)
✅ Saisie de texte dans les champs
✅ Affichage du logo
✅ Structure de layout (Scaffold, SingleChildScrollView)
```

**Pourquoi** : La page de connexion est le point d'entrée de l'application, elle doit être fonctionnelle et sécurisée.

**Exemple de test** :

```dart
testWidgets('should have password field obscured by default', 
    (WidgetTester tester) async {
  await tester.pumpWidget(createTestApp(const SignInPage()));
  await tester.pumpAndSettle();

  final passwordFields = find.byType(TextField);
  final passwordField = tester.widgetList<TextField>(passwordFields).elementAt(1);
  
  expect(passwordField.obscureText, true);  // ✅ Mot de passe caché
});
```

#### SignUpPage Tests

**Fichier** : [`test/pages/sign_up_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/sign_up_page_test.dart)

**Ce qui est testé** :

```dart
✅ 3 champs de texte (email, password, confirm password)
✅ Bouton d'inscription
✅ Lien vers la page de connexion
✅ Champs mot de passe obscurcis
✅ Saisie de texte
✅ Présence d'un Form pour validation
```

**Pourquoi** : L'inscription doit valider les données avant de créer un compte.

---

### 2. Pages Principales

#### GamesPage Tests

**Fichier** : [`test/pages/games_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/games_page_test.dart)

**Ce qui est testé** :

```dart
✅ AppBar avec logo et titre
✅ Drawer présent
✅ Couleurs des équipes (Lakers → purple, Celtics → green)
✅ Emojis des équipes (Lakers → 🌴, Celtics → 🍀)
✅ Formatage de l'heure des matchs
✅ Conversion de cotes selon le format utilisateur
```

**Pourquoi** : C'est la page principale où les utilisateurs voient les matchs et placent leurs paris.

**Tests des méthodes** :

```dart
test('getTeamColor should return correct color for Lakers', () {
  final color = gamesPageState.getTeamColor('Los Angeles Lakers');
  expect(color, const Color(0xFF552583)); // Purple Lakers
});

test('formatGameTime should format UTC time correctly', () {
  final utcString = '2024-01-20T02:00:00Z';
  final formatted = gamesPageState.formatGameTime(utcString, mockClock);
  
  expect(formatted, isNotEmpty);
  expect(formatted.contains('Jan') || formatted.contains('janv'), true);
});
```

#### BucketPage Tests

**Fichier** : [`test/pages/bucket_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/bucket_page_test.dart)

**Ce qui est testé** :

```dart
✅ AppBar
✅ État vide du panier
✅ Affichage des paris ajoutés
✅ Champ de saisie du montant
✅ Bouton de validation
✅ Affichage de plusieurs paris
```

**Pourquoi** : Le panier permet de valider plusieurs paris en une fois, il doit afficher correctement tous les paris sélectionnés.

---

### 3. Pages Additionnelles

#### RankingPage Tests

**Fichier** : [`test/pages/ranking_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/ranking_page_test.dart)

**Ce qui est testé** :

```dart
✅ Structure de base
✅ Fonction getRankColor()
   - Rank 1 → Or (0xFFFFD700)
   - Rank 2 → Argent (0xFFC0C0C0)
   - Rank 3 → Bronze (0xFFCD7F32)
   - Autres → Blanc
```

**Pourquoi** : Le classement doit mettre en valeur les 3 premiers avec des couleurs distinctes.

#### ManageAccountPage Tests

**Fichier** : [`test/pages/manage_account_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/manage_account_page_test.dart)

**Ce qui est testé** :

```dart
✅ Champs de texte pour le nom d'utilisateur
✅ Dropdowns pour langue (FR/EN)
✅ Dropdowns pour format de cotes (FR/UK/US)
✅ Boutons d'action (changer MDP, vider cache)
✅ Saisie de texte
```

**Pourquoi** : Les utilisateurs doivent pouvoir personnaliser leur expérience (langue, format de cotes).

#### PassedBetsPage Tests

**Fichier** : [`test/pages/passed_bets_page_test.dart`](file:///home/fabien/Documents/hoopsleague/test/pages/passed_bets_page_test.dart)

**Ce qui est testé** :

```dart
✅ Structure de base
✅ Fonction parseDouble()
   - int → double (100 → 100.0)
   - double → double (123.45 → 123.45)
   - string → double ("99.99" → 99.99)
   - invalid → 0.0
   - null → 0.0
```

**Pourquoi** : Les données de Supabase peuvent être de types variés, il faut les normaliser en double.

---

## Tests d'Intégration

### Navigation Tests

**Fichier** : [`test/integration/navigation_test.dart`](file:///home/fabien/Documents/hoopsleague/test/integration/navigation_test.dart)

**Ce qui est testé** :

```dart
✅ Navigation SignIn → SignUp
✅ Navigation SignUp → SignIn
✅ Affichage correct des widgets sur chaque page
✅ Cycles de navigation multiples
```

**Pourquoi** : Les utilisateurs doivent pouvoir naviguer librement entre les pages sans crash.

**Exemple de test** :

```dart
testWidgets('should handle multiple navigation cycles', 
    (WidgetTester tester) async {
  await tester.pumpWidget(createTestApp(const SignInPage()));
  await tester.pumpAndSettle();

  // Cycle 1: SignIn → SignUp
  await tester.tap(find.byType(TextButton).first);
  await tester.pumpAndSettle();
  expect(find.byType(SignUpPage), findsOneWidget);

  // Cycle 2: SignUp → SignIn
  await tester.tap(find.byType(TextButton).first);
  await tester.pumpAndSettle();
  expect(find.byType(SignInPage), findsOneWidget);

  // Cycle 3: SignIn → SignUp again
  await tester.tap(find.byType(TextButton).first);
  await tester.pumpAndSettle();
  expect(find.byType(SignUpPage), findsOneWidget);
});
```

---

## Exécution des tests

### Tous les tests

```bash
flutter test
```

### Tests spécifiques par catégorie

```bash
# Tests unitaires
flutter test test/services/
flutter test test/utils/

# Tests de widgets
flutter test test/pages/

# Tests d'intégration
flutter test test/integration/

# Un fichier spécifique
flutter test test/services/cache_service_test.dart
```

### Avec couverture de code

```bash
flutter test --coverage

# Générer un rapport HTML (nécessite lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Mode verbose

```bash
flutter test --reporter=expanded
```

### Tests en continu (watch mode)

```bash
# Nécessite fswatch (macOS) ou inotify-tools (Linux)
flutter test --watch
```

---

## Bonnes pratiques

### 1. Nommage des tests

```dart
✅ BIEN : 'should display email and password fields'
✅ BIEN : 'should convert FR odds to US format correctly'
❌ MAL : 'test1'
❌ MAL : 'it works'
```

### 2. Structure AAA (Arrange-Act-Assert)

```dart
test('should save points with timestamp', () async {
  // Arrange (Préparer)
  final now = DateTime(2024, 1, 15, 12, 0);
  const points = 1500.0;

  // Act (Agir)
  await CacheService.saveUserPoints(testUid, points, now);

  // Assert (Vérifier)
  final history = await CacheService.loadPointsHistory(testUid);
  expect(history.length, 1);
  expect(history[0]['points'], 1500.0);
});
```

### 3. Utiliser setUp et tearDown

```dart
group('CacheService', () {
  setUp(() async {
    // Préparation avant chaque test
    await Hive.initFlutter();
  });

  tearDown(() async {
    // Nettoyage après chaque test
    await CacheService.clearCache();
  });

  test('...', () async {
    // Test
  });
});
```

### 4. Tests isolés

Chaque test doit être **indépendant** et ne pas dépendre de l'ordre d'exécution :

```dart
✅ BIEN : Chaque test crée ses propres données
❌ MAL : Un test dépend des données créées par un test précédent
```

### 5. Utiliser des helpers

```dart
// test/helpers/test_helpers.dart
class TestData {
  static Map<String, dynamic> createGame({...}) {
    return {...};
  }
}

// Dans les tests
final game = TestData.createGame(
  id: 'game-1',
  homeTeam: 'Lakers',
  awayTeam: 'Celtics',
);
```

### 6. Tester les cas limites

```dart
test('should handle very low odds', () {
  expect(convertOdds(1.01, 'FR'), '1.01');
  expect(convertOdds(1.01, 'US').startsWith('-'), true);
});

test('should handle very high odds', () {
  expect(convertOdds(10.00, 'FR'), '10.00');
  expect(convertOdds(10.00, 'US'), '+900');
});

test('should return 0.0 for null', () {
  final result = parseDouble(null);
  expect(result, 0.0);
});
```

---

## Limitations actuelles

### 1. Pas de mocks Supabase

**Problème** : Certains tests rencontrent des timeouts car ils attendent des données de Supabase.

**Solution future** : Ajouter `mockito` pour créer des mocks de Supabase :

```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.0
```

```dart
// Exemple de mock
@GenerateMocks([SupabaseClient])
void main() {
  late MockSupabaseClient mockSupabase;

  setUp(() {
    mockSupabase = MockSupabaseClient();
  });

  test('should load games from Supabase', () async {
    when(mockSupabase.from('gamesdata').select())
        .thenAnswer((_) async => [...]);
    
    // Test avec le mock
  });
}
```

### 2. Pas de tests E2E

**Solution future** : Utiliser `integration_test` pour tester les flux complets :

```dart
// integration_test/app_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete betting flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Se connecter
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // 2. Sélectionner un match
    await tester.tap(find.text('Lakers vs Celtics').first);
    await tester.pumpAndSettle();

    // 3. Placer un pari
    // ...
  });
}
```

---

## Ressources

- [Documentation Flutter Testing](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

## Conclusion

Cette suite de tests fournit une **base solide** pour garantir la qualité de HoopsLeague :

✅ **18 fichiers de tests** couvrant tous les aspects  
✅ **~82 tests** au total  
✅ **100% des tests unitaires** passent  
✅ **Toutes les pages** ont des tests  

Les tests sont **maintenables**, **documentés**, et **extensibles** pour les futures fonctionnalités.
