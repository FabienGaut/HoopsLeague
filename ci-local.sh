#!/bin/bash

# 🚀 Pipeline CI Locale pour HoopsLeague
# Ce script exécute toutes les étapes de la CI en local avant de pusher

set -e  # Arrête le script en cas d'erreur

echo "🔍 Vérification du répertoire..."
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

echo ""
echo "📦 Installation des dépendances..."
flutter pub get

echo ""
echo "🔍 Analyse du code..."
flutter analyze

echo ""
echo "🧪 Exécution des tests..."
flutter test --coverage

echo ""
echo "🏗️  Build Web (Release)..."
flutter build web --release --base-href "/" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:-$(grep SUPABASE_URL assets/.env.local 2>/dev/null | cut -d= -f2)}" \
  --dart-define=PUBLISHABLE_KEY="${PUBLISHABLE_KEY:-$(grep PUBLISHABLE_KEY assets/.env.local 2>/dev/null | cut -d= -f2)}"

echo ""
echo "✅ Toutes les vérifications sont passées!"
echo ""

# Vérifie s'il y a des changements à commiter
if [[ -n $(git status -s) ]]; then
    echo "⚠️  Il y a des changements non commités."
    read -p "Voulez-vous les commiter et pusher sur Git? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Message de commit: " commit_msg
        git add .
        git commit -m "$commit_msg"

        echo ""
        echo "📤 Push vers Git..."
        git push
        echo "✅ Push terminé!"
        echo ""
        echo "🚀 Le workflow GitHub Actions va maintenant déployer sur Vercel Production"
    else
        echo ""
        echo "⏸️  Commit annulé. Build disponible dans ./build/web"
    fi
else
    echo "✅ Aucun changement à commiter."
    echo ""
    read -p "Voulez-vous pusher quand même pour déclencher le déploiement? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "📤 Push vers Git..."
        git push
        echo "✅ Push terminé!"
        echo ""
        echo "🚀 Le workflow GitHub Actions va maintenant déployer sur Vercel Production"
    fi
fi

echo ""
echo "🎉 Pipeline CI locale terminée!"
