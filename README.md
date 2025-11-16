# HoopsLeague 🏀

**HoopsLeague** est une application mobile de paris sportifs dédiée à la NBA, développée avec Flutter. Elle permet aux utilisateurs de créer un compte, de recevoir des points quotidiens, et de parier sur les matchs à venir.

## ✨ Fonctionnalités

- **Authentification des utilisateurs** : Inscription, connexion et gestion de compte sécurisées via Supabase.
- **Système de points** : Chaque utilisateur reçoit un solde de départ et des points quotidiens pour parier.
- **Liste des matchs** : Affiche les matchs NBA à venir avec leurs cotes.
- **Prise de paris** : Les utilisateurs peuvent placer des paris simples ou combinés sur les équipes de leur choix.
- **Historique des paris** : Suivi des paris passés, avec indication des gains et des pertes.
- **Classement** : Un classement des meilleurs parieurs basé sur leur solde de points.
- **Personnalisation** : Prise en charge de plusieurs langues (français, anglais) et formats de cotes (européen, américain, britannique).
- **Dashboard personnel** : Un graphique pour suivre l'évolution de son solde de points dans le temps.

## 🛠️ Technologies Utilisées

- **Framework** : [Flutter](https://flutter.dev/)
- **Backend** : [Supabase](https://supabase.io/) (Authentification, base de données en temps réel)
- **Gestion d'état** : [Provider](https://pub.dev/packages/provider)
- **Base de données locale** : [Hive](https://pub.dev/packages/hive)
- **Graphiques** : [fl_chart](https://pub.dev/packages/fl_chart)
- **Internationalisation** : [flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html)

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir les outils suivants installés sur votre machine :

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.9.2 ou supérieure)
- Un éditeur de code comme [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio).

## 🚀 Installation

Suivez ces étapes pour faire fonctionner le projet en local :

1.  **Clonez le dépôt** :
    ```bash
    git clone https://github.com/votre-utilisateur/hoopsleague.git
    cd hoopsleague
    ```

2.  **Installez les dépendances** :
    ```bash
    flutter pub get
    ```

## 🔐 Configuration de Supabase

L'application utilise Supabase pour son backend. Vous devez configurer vos propres clés d'API pour vous connecter.

1.  **Créez un fichier `.env`** :
    À la racine du projet, créez un fichier nommé `.env` dans le dossier `assets`.

2.  **Ajoutez vos clés Supabase** :
    Ouvrez le fichier `assets/.env` et ajoutez-y vos informations de projet Supabase :
    ```
    SUPABASE_URL=https://VOTRE_URL_SUPABASE.supabase.co
    SUPABASE_ANON_KEY=VOTRE_CLE_ANON_SUPABASE
    ```

3.  **Lancez l'application** :
    Vous pouvez maintenant lancer l'application sur un émulateur ou un appareil physique :
    ```bash
    flutter run
    ```
