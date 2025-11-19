# Plan de Test pour HoopsLeague

Ce document détaille la stratégie de test pour l'application HoopsLeague, afin d'assurer sa qualité et sa stabilité avant le déploiement.

## 1. Tests Unitaires

**Objectif :** Vérifier que les plus petites unités de code (fonctions, méthodes) fonctionnent correctement de manière isolée.

| Test Case                  | Description                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Logique Métier**         |                                                                                                         |
| Calculs de cotes/gains     | Valider que les fonctions de calcul retournent des résultats précis.                                    |
| Validateurs de formulaire  | S'assurer que les validateurs pour l'email, le mot de passe, etc., rejettent les entrées invalides.       |
| Manipulation de dates      | Confirmer que la logique de gestion des fuseaux horaires et des dates de match est correcte.            |
| **Services**               |                                                                                                         |
| `CacheService`             | Vérifier que les données sont correctement stockées, récupérées et invalidées du cache local (Hive).   |
| Interactions Supabase      | Utiliser des *mocks* pour simuler les appels à l'API Supabase et tester la gestion des succès et des erreurs. |

## 2. Tests de Widgets

**Objectif :** S'assurer que les widgets de l'interface utilisateur s'affichent correctement et réagissent comme prévu aux interactions de l'utilisateur.

| Test Case                  | Description                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Écrans d'Authentification** |                                                                                                         |
| `sign_in_page` / `sign_up_page` | Vérifier que les champs de texte, les boutons et les messages d'erreur s'affichent correctement.         |
| **Écrans Principaux**        |                                                                                                         |
| `home_page`, `games_page`  | Confirmer que les listes de matchs et les informations principales se chargent et s'affichent.            |
| `leagues_page`, `ranking_page` | Valider l'affichage correct des listes de ligues et des classements.                                     |
| `graph_page`               | S'assurer que les graphiques (`fl_chart`) s'affichent avec les bonnes données.                            |
| **Composants Réutilisables** |                                                                                                         |
| Cartes de match, boutons   | Tester l'affichage et le comportement de chaque composant réutilisable de manière isolée.               |

## 3. Tests d'Intégration

**Objectif :** Vérifier que plusieurs composants de l'application fonctionnent ensemble de manière cohérente.

| Test Case                  | Description                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Flux d'Authentification** | Simuler le parcours complet : inscription, connexion, déconnexion, et changement de mot de passe.         |
| **Flux de Paris**          | Simuler le processus de sélection d'un match, de placement d'un pari, et de mise à jour du solde de points. |
| **Navigation**             | S'assurer que la navigation entre les écrans via les boutons et les liens fonctionne correctement.      |

## 4. Tests End-to-End (E2E)

**Objectif :** Simuler des parcours utilisateur complets pour valider l'ensemble de l'application, du frontend au backend.

| Scénario                   | Description                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **Parcours Utilisateur Principal** | 1. L'utilisateur ouvre l'application. <br> 2. Il se connecte. <br> 3. Il navigue vers la page des matchs. <br> 4. Il sélectionne un match. <br> 5. Il place un pari. <br> 6. Il vérifie son historique de paris. <br> 7. Il se déconnecte. |

## 5. Tests Manuels et Assurance Qualité (QA)

**Objectif :** Couvrir les aspects qui sont difficiles à automatiser et évaluer l'expérience utilisateur globale.

| Catégorie                  | Description                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------- |
| **UI/UX et Responsivité**  | Vérifier manuellement l'affichage et l'ergonomie sur différentes tailles d'écran (mobile, tablette) et sur des appareils physiques (iOS et Android). |
| **Localisation (i18n)**      | S'assurer que les traductions en français et en anglais sont correctes et complètes.                      |
| **Performance**            | Mesurer les temps de chargement, la fluidité des animations, et l'utilisation de la batterie.             |
| **Sécurité**               | Vérifier que les clés d'API sont bien chargées depuis le `.env` et non exposées, et que les communications sont en HTTPS. |
| **Connectivité**           | Tester le comportement de l'application en mode hors-ligne, avec une connexion lente (3G) ou instable.    |
### Tests manuels :
ajouter un match au bucket
retirer un match du bucket
ajouter plusieurs matchs, retirer 1+ matchs
ajouter tous les paris au bucket
retirer tous les paris du bucket
récupérer son bonus quotidien
valider plusieurs paris
tester pour aller sur chaque page du menu, et depuis ces pages aller sur chaque autre
créer un compte avec des mauvaise puis bonnes info
connexion avec mauvaises et bonnes infos
tester la page de première connexion avec toutes les configurations
tester la déonnexion
tester la reconnexion avec différents comptes
créer une ligue
rejoindre plusieurs ligues
tester les fonctionnalités pour gérer mon compte : vider la cache, changer mdp/user, la langue le format de cote
tester ecrire nptq dans les montants de paris 
taille max pseudo
rafraichir les données
remonter un bug
tester ce qu'il se passe hors ligne : handle l'exception au demarrage hors ligne
demarrer en ligne switcher hors ligne 
demarrer hors ligne switcher en ligne 