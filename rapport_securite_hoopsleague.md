# Rapport de Sécurité - HoopsLeague
**Date :** 2026-02-21
**Projet :** hoopsleague.fr
**Stack :** Flutter Web + Supabase + Vercel
**Scope :** Code source, infrastructure web, configuration backend
**Autorisation :** Explicite du propriétaire

---

## Executive Summary

L'analyse de sécurité du projet HoopsLeague révèle **2 vulnérabilités critiques**, **4 vulnérabilités hautes** et **5 vulnérabilités moyennes**. La combinaison de la clé Supabase exposée publiquement et de l'absence de politiques RLS constitue le risque le plus grave : **toute personne connaissant l'URL du fichier `.env` peut potentiellement lire et modifier toutes les données de la base de données**.

---

## Tableau de Synthèse

| # | Vulnérabilité | Sévérité | OWASP | Statut |
|---|---------------|----------|-------|--------|
| 1 | Fichier `.env` bundlé et exposé dans le build Flutter Web | **CRITIQUE** | A05 | Actif |
| 2 | Absence de RLS (Row Level Security) dans la base Supabase | **CRITIQUE** | A01 | À vérifier |
| 3 | Horodatage des paris basé sur l'horloge client | **HAUTE** | A04 | Actif |
| 4 | DMARC p=none + SPF ~all — Email spoofing possible | **HAUTE** | A07 | Actif |
| 5 | Énumération d'emails via RPC `email_exists` | **HAUTE** | A07 | Actif |
| 6 | CAPTCHA non intégré dans les pages d'authentification | **HAUTE** | A07 | Actif |
| 7 | Clé Turnstile fallback = clé de test (toujours valide) | **MOYENNE** | A05 | Actif |
| 8 | Headers de sécurité HTTP manquants | **MOYENNE** | A05 | Actif |
| 9 | `mockito` en dépendance de production | **MOYENNE** | A06 | Actif |
| 10 | Pas de politique de divulgation (security.txt) | **FAIBLE** | - | Actif |
| 11 | Certificat RSA 2048 bits (recommandé : ECDSA ou 4096) | **INFO** | - | Actif |

---

## Analyse Détaillée

---

### [CRITIQUE #1] Clé Supabase exposée via `assets/assets/.env`

**Fichier concerné :** `pubspec.yaml` (ligne 37), `assets/.env`, `build/web/assets/assets/.env`

**Description :**
Le fichier `.env` contenant les credentials Supabase est déclaré explicitement comme **asset Flutter** dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/.env   # ← DANGER : bundlé dans le build web
```

Flutter Web copie tous les assets dans `build/web/assets/assets/`. Ce fichier est donc **accessible publiquement** à l'URL :
```
https://hoopsleague.fr/assets/assets/.env
```

**Contenu exposé :**
```env
PUBLISHABLE_KEY=sb_publishable_yXWHZZxz4llOn31KWfBBtA_-9h1ApWx
SUPABASE_URL=https://plfhxmgafliomlkhajms.supabase.co
```

**Impact :** Avec la clé `sb_publishable_` et l'URL Supabase, un attaquant peut :
- Interroger directement la REST API Supabase
- Lire toutes les tables si le RLS n'est pas configuré
- Manipuler les données utilisateurs, paris, classements

**Reproduction :**
```bash
curl https://hoopsleague.fr/assets/assets/.env
# Puis attaque directe :
curl -H "apikey: sb_publishable_yXWHZZxz4llOn31KWfBBtA_-9h1ApWx" \
     https://plfhxmgafliomlkhajms.supabase.co/rest/v1/usersdata
```

**Correction (priorité immédiate) :**

1. **Retirer `.env` des assets Flutter** dans `pubspec.yaml` :
```yaml
flutter:
  assets:
    # SUPPRIMER la ligne :  - assets/.env
    - assets/images/
    - assets/legal_docs/
```

2. **Utiliser les variables d'environnement Vercel** au lieu d'un fichier :
   - Aller dans Vercel Dashboard → Settings → Environment Variables
   - Ajouter `SUPABASE_URL` et `SUPABASE_ANON_KEY`

3. **Pour Flutter Web**, utiliser `dart-define` à la compilation :
```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://... \
  --dart-define=SUPABASE_ANON_KEY=...
```
```dart
// Dans main.dart :
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
```

4. **Immédiatement : révoquer et renouveler la clé Supabase** dans le dashboard.

5. **Ajouter une règle Vercel** pour bloquer l'accès aux `.env` :
```json
{
  "headers": [
    {
      "source": "/(.*\\.env.*)",
      "headers": [{"key": "X-Robots-Tag", "value": "noindex"}]
    }
  ],
  "redirects": [
    {
      "source": "/(.*\\.env.*)",
      "destination": "/404",
      "statusCode": 404
    }
  ]
}
```

---

### [CRITIQUE #2] Absence de Row Level Security (RLS) Supabase

**Fichier concerné :** `databaseBackup.sql`, configuration Supabase

**Description :**
Le backup SQL contient la définition de **7 tables** (`bets`, `betstests`, `bugs`, `gamesdata`, `gamesdatatest`, `leagues`, `usersdata`) mais **aucune politique RLS** n'est visible. En l'absence de RLS, Supabase autorise par défaut l'accès complet à toutes les tables via la clé anon.

Tables exposées :
- `usersdata` — données personnelles de tous les utilisateurs
- `bets` — historique de tous les paris (manipulation possible)
- `leagues` — toutes les ligues (manipulation possible)
- `bugs` — signalements de bugs internes

**Impact combiné avec #1 :**
Si RLS absent + clé exposée → **accès total en lecture/écriture à toute la base**.

**Correction :**
Pour chaque table, activer RLS et créer des politiques dans le dashboard Supabase :

```sql
-- Activer RLS sur toutes les tables
ALTER TABLE public.usersdata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.leagues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bugs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gamesdata ENABLE ROW LEVEL SECURITY;

-- Politique : un user ne peut voir/modifier que ses propres données
CREATE POLICY "user_own_data" ON public.usersdata
  FOR ALL USING (auth.uid() = id);

CREATE POLICY "user_own_bets" ON public.bets
  FOR ALL USING (auth.uid() = user_id);

-- gamesdata : lecture publique OK (matchs NBA), écriture admin seulement
CREATE POLICY "gamesdata_read" ON public.gamesdata
  FOR SELECT USING (true);
CREATE POLICY "gamesdata_write_admin" ON public.gamesdata
  FOR ALL USING (auth.jwt() ->> 'role' = 'admin');

-- leagues : accès conditionnel (membre ou propriétaire)
CREATE POLICY "league_members_access" ON public.leagues
  FOR SELECT USING (
    auth.uid()::text = ANY(users_id::text[])
  );
```

---

### [HAUTE #3] Horodatage des paris basé sur l'horloge client (manipulation de temps)

**Fichier concerné :** `lib/services/clock.dart`, `lib/pages/bucket_page.dart:154`

**Description :**
Le timestamp des paris est généré avec `DateTime.now()` (horloge du client) :

```dart
// clock.dart
class Clock {
  DateTime now() => DateTime.now();  // ← Horloge CLIENT, manipulable
}

// bucket_page.dart:154
final now = ctx.now();
// ...
'timestamp': now.toIso8601String(),  // ← Timestamp modifiable par l'utilisateur
```

Un utilisateur peut manipuler l'horloge de son appareil pour parier **sur des matchs déjà commencés ou terminés**, ce qui est une tromperie directe contre les autres joueurs.

Le fichier `SETUP_INSTRUCTIONS.md` mentionne l'ajout d'un trigger serveur comme "optionnel" — il ne semble pas avoir été implémenté.

**Impact :** Fraude au paris sportifs virtuels — un joueur peut connaître le résultat avant de parier.

**Correction :**
```dart
// Utiliser le timestamp serveur Supabase :
final serverTimestamp = await supabase.rpc('get_current_timestamp');
final now = DateTime.parse(serverTimestamp[0]['now']);

// ET côté serveur : trigger PostgreSQL
CREATE OR REPLACE FUNCTION validate_bet_timing()
RETURNS TRIGGER AS $$
DECLARE
  game_start timestamptz;
BEGIN
  SELECT start_time INTO game_start FROM gamesdata WHERE id = ANY(NEW.games_id::uuid[]);
  IF game_start <= NOW() THEN
    RAISE EXCEPTION 'Cannot bet on a game that has already started';
  END IF;
  NEW.timestamp = NOW(); -- Forcer le timestamp serveur
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER enforce_bet_timing
  BEFORE INSERT ON public.bets
  FOR EACH ROW EXECUTE FUNCTION validate_bet_timing();
```

---

### [HAUTE #4] Email Spoofing — DMARC p=none + SPF ~all

**Enregistrements DNS analysés :**
```
TXT: v=spf1 include:spf.improvmx.com include:resend.com ~all
TXT: v=DMARC1; p=none; fo=1; rua=mailto:dmarc@hoopsleague.fr
MX:  mx1.improvmx.com, mx2.improvmx.com
```

**Problèmes :**
- **SPF `~all`** (softfail) : les emails non autorisés sont acceptés mais marqués. Devrait être `-all` (hardfail).
- **DMARC `p=none`** : aucune action n'est prise sur les emails qui échouent la vérification. Devrait être au minimum `p=quarantine`.

**Impact :** Un attaquant peut envoyer des emails qui semblent provenir de `@hoopsleague.fr` (phishing, réinitialisation de mot de passe frauduleuse).

**Correction :**
```
# SPF - remplacer ~all par -all
v=spf1 include:spf.improvmx.com include:resend.com -all

# DMARC - passer à quarantine puis reject
v=DMARC1; p=quarantine; pct=100; fo=1; rua=mailto:dmarc@hoopsleague.fr

# Progression recommandée :
# 1. p=none (monitoring) ← déjà en place
# 2. p=quarantine; pct=10 (test progressif)
# 3. p=quarantine; pct=100
# 4. p=reject; pct=100 (protection maximale)
```

---

### [HAUTE #5] Énumération d'emails via RPC `email_exists`

**Fichier concerné :** `lib/pages/sign_up_page.dart:62`

**Description :**
```dart
final emailExists = await supabase.rpc(
  'email_exists',
  params: {'email_to_check': emailController.text.trim()},
);
if (emailExists == true) {
  setState(() { errorMessage = t.mailAlreadyUsed; });
}
```

Ce RPC expose un oracle d'énumération : un attaquant peut automatiser des requêtes pour savoir quels emails ont un compte HoopsLeague.

**Impact :** Permet des attaques ciblées de phishing, credential stuffing ou brute force.

**Correction :**
- Supprimer le RPC `email_exists` et laisser Supabase Auth gérer les doublons d'inscription nativement
- Afficher un message générique qui ne révèle pas si l'email existe :
```dart
// Au lieu de vérifier avant, tenter l'inscription et gérer l'erreur
try {
  final res = await supabase.auth.signUp(email: email, password: password);
  // ...
} on AuthException catch (e) {
  // Message générique - ne pas révéler si l'email existe
  setState(() { errorMessage = t.signUpError; });
}
```

---

### [HAUTE #6] CAPTCHA non intégré dans les pages d'authentification

**Fichier concerné :** `lib/widgets/captcha_widget.dart` (créé), `lib/pages/sign_in_page.dart` (absent), `lib/pages/sign_up_page.dart` (absent)

**Description :**
Un widget `CaptchaWidget` utilisant Cloudflare Turnstile a été développé mais **n'est intégré dans aucune page d'authentification**. Les formulaires de connexion et d'inscription sont donc vulnérables aux attaques automatisées.

**Impact :** Brute force sur les mots de passe, création massive de comptes faux, spam.

**Correction :**
Intégrer `CaptchaWidget` dans `sign_in_page.dart` et `sign_up_page.dart` :
```dart
// Dans le formulaire de connexion :
CaptchaWidget(
  onTokenReceived: (token) => setState(() => _captchaToken = token),
  onError: (e) => setState(() => errorMessage = t.captchaError),
  onTokenExpired: () => setState(() => _captchaToken = null),
),
// ...
// Valider avant connexion :
if (_captchaToken == null) {
  setState(() => errorMessage = t.captchaRequired);
  return;
}
```

**Note :** Voir aussi #7 sur la clé Turnstile.

---

### [MOYENNE #7] Clé Cloudflare Turnstile = clé de test universelle

**Fichier concerné :** `lib/widgets/captcha_widget.dart:50`, `assets/.env`

**Description :**
```dart
siteKey: dotenv.env['TURNSTILE_SITE_KEY'] ?? '1x00000000000000000000AA',
```

`TURNSTILE_SITE_KEY` n'est pas définie dans le `.env`. Le fallback `'1x00000000000000000000AA'` est la **clé de test officielle Cloudflare** qui valide automatiquement **tous les challenges sans vérification réelle**.

**Impact :** Même si le CAPTCHA était intégré, il serait bypassable.

**Correction :**
1. Créer un site sur [Cloudflare Turnstile Dashboard](https://dash.cloudflare.com/) et obtenir une vraie clé de site
2. Ajouter `TURNSTILE_SITE_KEY=votre_vraie_clé` dans `.env` (mais ne pas le bundler — cf. #1)
3. Utiliser `--dart-define=TURNSTILE_SITE_KEY=...` à la compilation

---

### [MOYENNE #8] Headers de sécurité HTTP manquants

**Fichier concerné :** `vercel.json`

**Headers absents et risques associés :**

| Header | Risque si absent |
|--------|-----------------|
| `Content-Security-Policy` | XSS, injection de scripts tiers |
| `X-Frame-Options` | Clickjacking |
| `Strict-Transport-Security` | Downgrade HTTPS→HTTP |
| `X-Content-Type-Options` | MIME sniffing |
| `Referrer-Policy` | Fuite d'URL dans les referer headers |
| `Permissions-Policy` | Accès non autorisé aux APIs navigateur (camera, mic, geolocation) |

**Correction — ajouter dans `vercel.json` :**
```json
{
  "source": "/(.*)",
  "headers": [
    {"key": "X-Frame-Options", "value": "DENY"},
    {"key": "X-Content-Type-Options", "value": "nosniff"},
    {"key": "Referrer-Policy", "value": "strict-origin-when-cross-origin"},
    {"key": "Permissions-Policy", "value": "camera=(), microphone=(), geolocation=()"},
    {"key": "Strict-Transport-Security", "value": "max-age=31536000; includeSubDomains"},
    {"key": "Content-Security-Policy", "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://challenges.cloudflare.com; connect-src 'self' https://*.supabase.co; img-src 'self' data:; style-src 'self' 'unsafe-inline'; frame-src https://challenges.cloudflare.com;"}
  ]
}
```

---

### [MOYENNE #9] `mockito` en dépendance de production

**Fichier concerné :** `pubspec.yaml:29`

**Description :**
```yaml
dependencies:
  mockito: ^5.4.4  # ← package de test en PRODUCTION
```

`mockito` est un package de mocking pour les tests. Il ne devrait jamais être en `dependencies` (production) mais en `dev_dependencies`. Cela augmente la taille du bundle et expose potentiellement des fonctionnalités de test en production.

**Correction :**
```yaml
dependencies:
  # Supprimer mockito d'ici

dev_dependencies:
  mockito: ^5.4.4  # ← Ici c'est correct
  mocktail: ^1.0.4
```

---

### [FAIBLE #10] Absence de fichier security.txt

**URL attendue :** `https://hoopsleague.fr/.well-known/security.txt`

**Description :** Aucune politique de divulgation responsable des vulnérabilités n'est définie.

**Correction :**
```
Contact: security@hoopsleague.fr
Expires: 2027-01-01T00:00:00.000Z
Preferred-Languages: fr, en
Policy: https://hoopsleague.fr/security-policy
```

---

## Analyse Infrastructure

### DNS & Réseau

| Élément | Valeur | Évaluation |
|---------|--------|------------|
| IPs | 216.198.79.1, 64.29.17.65 | Vercel CDN ✓ |
| MX | mx1/mx2.improvmx.com | Service email tiers — ok |
| SSL Issuer | Let's Encrypt R12 | ✓ |
| SSL Validité | 01/02/2026 → 02/05/2026 | ✓ Valide |
| SSL Type | RSA 2048 bits | Acceptable (ECDSA recommandé) |
| TLS 1.0 | Désactivé | ✓ Bon |
| TLS 1.1 | Désactivé | ✓ Bon |
| TLS 1.2 | ECDHE-RSA-AES128-GCM-SHA256 | ✓ |
| TLS 1.3 | TLS_AES_128_GCM_SHA256 | ✓ |
| Sous-domaines | www.hoopsleague.fr uniquement | ✓ Surface minimale |
| Bot Protection | Vercel (429 sur scan automatisé) | ✓ Bonne protection |
| CAPTCHA | Cloudflare Turnstile (widget existant) | ⚠ Non intégré |

### Points Positifs

- TLS 1.0 et 1.1 désactivés
- Vercel bot protection active (contre les scans automatisés)
- Classe `SecurityUtils` implémentée pour la validation d'accès
- `delete_user_account()` vérifie l'authentification avant d'agir
- `SECURITY DEFINER` avec vérification `auth.uid()` correctement implémentée
- Widget CAPTCHA développé (mais non intégré)
- Hive utilisé pour le cache local (pas de données sensibles identifiées)

---

## Plan d'Action Priorisé

### Immédiat (aujourd'hui)

1. **Révoquer la clé Supabase** `sb_publishable_yXWHZZxz4llOn31KWfBBtA_-9h1ApWx` dans le dashboard
2. **Retirer `assets/.env` des assets Flutter** dans `pubspec.yaml`
3. **Rebuild et redéployer** le projet sans le fichier `.env`
4. **Bloquer l'accès** aux fichiers `.env` dans `vercel.json`

### Dans les 7 jours

5. **Activer RLS** sur toutes les tables Supabase et créer les politiques
6. **Implémenter le trigger PostgreSQL** de validation des paris
7. **Intégrer CaptchaWidget** dans `sign_in_page.dart` et `sign_up_page.dart`
8. **Obtenir une vraie clé Turnstile** et la configurer via `--dart-define`

### Dans les 30 jours

9. **Corriger DMARC/SPF** : passer à `p=quarantine` et `-all`
10. **Ajouter les headers de sécurité** dans `vercel.json`
11. **Supprimer `email_exists` RPC** ou le sécuriser
12. **Déplacer `mockito`** en `dev_dependencies`
13. **Créer `security.txt`**

---

## Score de Maturité Sécurité

| Domaine | Score | Commentaire |
|---------|-------|-------------|
| Gestion des secrets | 1/5 | Clé exposée dans les assets |
| Contrôle d'accès (RLS) | 2/5 | RLS non confirmé actif |
| Authentification | 3/5 | Supabase Auth correctement utilisé mais sans CAPTCHA |
| Protection des données | 2/5 | Données exposées via API si RLS absent |
| Sécurité réseau/transport | 4/5 | TLS correct, headers manquants |
| Intégrité des données | 2/5 | Validation temporelle côté client |
| **Score global** | **2.3/5** | Des améliorations critiques nécessaires |

---

*Rapport généré le 2026-02-21 — Analyse réalisée sur autorisation explicite du propriétaire*
