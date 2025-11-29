#  Audit de Cybersécurité - HoopsLeague

**Date de l'audit :** 2025-11-16
**Version de l'application :** 1.0.0+1

## 1. Introduction

Cet audit a pour objectif d'évaluer la sécurité de l'application mobile **HoopsLeague** et de son backend Supabase. L'analyse identifie les vulnérabilités potentielles et fournit des recommandations concrètes pour renforcer la posture de sécurité de l'application avant son déploiement.

## 2. Résumé des Résultats et Priorités

L'application utilise une stack technologique moderne avec Flutter et Supabase, ce qui offre de bonnes bases de sécurité. Cependant, plusieurs vulnérabilités critiques ont été identifiées. Si elles ne sont pas corrigées, elles pourraient permettre à un attaquant de manipuler les données, d'accéder aux informations d'autres utilisateurs et de compromettre l'intégrité du système de points.

**Niveau de risque global : ÉLEVÉ**

**Actions prioritaires :**
1.  **Activer la Row Level Security (RLS) sur TOUTES les tables Supabase.** C'est la mesure la plus critique à mettre en place.
2.  **Déplacer la logique métier sensible côté serveur.** La logique de gestion des points doit être exécutée côté serveur via des Edge Functions pour empêcher la triche.
3.  **Protéger les clés d'API.** Les secrets ne doivent pas être stockés dans le dossier `assets`.

---

## 3. Analyse Détaillée

### 🚨 Vulnérabilité Critique : Logique Métier Côté Client

-   **Observation :** Actuellement, la logique de mise à jour des points d'un utilisateur après un pari est gérée directement par l'application Flutter (`bucket_page.dart`, `games_page.dart`). L'application calcule le nouveau solde de points et envoie la commande de mise à jour à Supabase.
-   **Risque :** Un attaquant peut facilement décompiler l'application, modifier le code pour s'attribuer des points (par exemple, en envoyant une mise à jour `{'points': 999999}`), et recompiler l'application. La logique de pari et de gain est ainsi contournable.
-   **Recommandation (Priorité Haute) :**
    -   Déplacez toute la logique qui modifie des données sensibles (comme les points) vers des **Supabase Edge Functions**.
    -   Créez une fonction `placeBet` côté serveur qui prend en entrée l'ID de l'utilisateur et les détails du pari. Cette fonction doit :
        1.  Vérifier côté serveur si l'utilisateur a assez de points.
        2.  Débiter les points de manière atomique.
        3.  Enregistrer le pari.
    -   L'application Flutter ne fera plus qu'appeler cette fonction sécurisée (`supabase.functions.invoke('placeBet', ...)`).

### 🔐 Sécurité du Backend (Supabase)

-   **Observation :** Le code interagit directement avec les tables Supabase depuis le client. Sans configuration de sécurité appropriée, n'importe quel utilisateur pourrait lire, modifier ou supprimer les données des autres.
-   **Risque :** Un utilisateur pourrait modifier ses propres points, lire les paris des autres, ou même modifier le statut d'un autre utilisateur (par exemple, le bannir).
-   **Recommandation (Priorité Critique) :**
    -   **Activez la Row Level Security (RLS) sur toutes les tables**, en particulier `usersdata` et `bets`.
    -   **Exemples de règles RLS à implémenter :**
        -   **Table `usersdata` :**
            -   Un utilisateur ne peut voir que sa propre ligne : `(auth.uid() = id)`
            -   Un utilisateur ne peut mettre à jour que certaines de ses propres informations (comme `user_name` ou `language`), mais PAS ses points : `(auth.uid() = id)`
        -   **Table `bets` :**
            -   Un utilisateur ne peut voir que ses propres paris : `(auth.uid() = user_id)`
            -   Un utilisateur peut créer des paris pour lui-même : `(auth.uid() = user_id)`
            -   Personne ne doit pouvoir mettre à jour un pari une fois qu'il est placé.

### 🔑 Sécurité Côté Client (Application Flutter)

-   **Observation :** Les clés Supabase (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) sont stockées dans `assets/.env`. Les fichiers présents dans le dossier `assets` sont inclus dans le package de l'application (APK ou IPA) et peuvent être extraits.
-   **Risque :** Bien que la clé `ANON_KEY` soit publiquement visible par nature, la stocker dans les assets est une mauvaise pratique. Si une clé plus sensible y était ajoutée par erreur, elle serait compromise.
-   **Recommandation (Priorité Moyenne) :**
    -   Utilisez les variables d'environnement au moment de la compilation avec `--dart-define`.
    -   Compilez votre application avec la commande :
        ```bash
        flutter run --dart-define="SUPABASE_URL=VOTRE_URL" --dart-define="SUPABASE_ANON_KEY=VOTRE_CLE"
        ```
    -   Cela injecte les clés dans le code compilé, ce qui est plus sécurisé que de les laisser dans un fichier texte brut dans les assets.

-   **Observation :** L'application utilise Hive pour le cache local. Ce cache n'est pas chiffré.
-   **Risque :** Un attaquant avec un accès physique à l'appareil pourrait lire le cache et potentiellement manipuler l'historique des points affiché.
-   **Recommandation (Priorité Basse) :**
    -   Si des données plus sensibles sont stockées à l'avenir, envisagez d'utiliser `EncryptedHive` ou `flutter_secure_storage`. Pour l'instant, le risque est faible car le cache n'est utilisé que pour l'affichage et la vérité est côté serveur.

-   **Observation :** Le code de l'application n'est pas obfusqué.
-   **Risque :** Il est plus facile pour un attaquant de décompiler l'application et de comprendre sa logique (reverse engineering) pour trouver des failles.
-   **Recommandation (Priorité Moyenne) :**
    -   Pour les builds de production, compilez l'application avec l'option d'obfuscation :
        ```bash
        flutter build apk --obfuscate --split-debug-info=./debug-info
        ```

### 📦 Sécurité des Dépendances

-   **Observation :** Le projet utilise plusieurs dépendances open-source.
-   **Risque :** Une dépendance pourrait contenir une vulnérabilité connue.
-   **Recommandation (Bonne pratique) :**
    -   Utilisez régulièrement `flutter pub outdated` pour identifier les dépendances obsolètes.
    -   Intégrez un outil d'analyse de vulnérabilités comme **Dependabot** (disponible gratuitement sur GitHub) ou **Snyk** pour scanner automatiquement vos dépendances et vous alerter en cas de problème.

## 4. Plan d'Action Recommandé

1.  **(Critique)** Activez immédiatement la RLS sur vos tables `usersdata` et `bets` avec des politiques strictes.
2.  **(Haute)** Refactorisez la logique de pari et de mise à jour des points pour qu'elle s'exécute dans des Supabase Edge Functions.
3.  **(Moyenne)** Modifiez votre processus de build pour utiliser `--dart-define` pour les clés d'API au lieu de `assets/.env`.
4.  **(Moyenne)** Utilisez l'obfuscation lors de la compilation des versions de production de votre application.
5.  **(Basse)** Mettez en place un scan automatique des dépendances (ex: Dependabot).
