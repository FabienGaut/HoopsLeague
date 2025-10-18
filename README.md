# NBA Betting Application

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


### TODO

Mini spec, this application must be able to :
- Faire fonctionner le pytest 🚧
- Developper l'app en TDD  🚧
- Create/Delete account for each user with 100 points at the init  ✅
- A user should have the following attributes : id, name, email, password hash, points, daily point status, bets, passed bets, creatoin date, role (user/admin), status (active, banned, deleted), timezone  ✅
- Save user account informations into a FireBase database  ✅
- An API should be made in order to request game/users informations  🚧
- Login/Logout from the account ✅
- Browse the different upcoming NBA games with the odds displayed  ✅
- Place bets with points  ✅
- Give 10 points each day to every users to allow them to place bets   ⏳
- Rule the bets ( TBD 2)  ⏳
- Make a ranking of the users with the points given   ⏳
- Get the odds for the upcoming games  ✅
- Verify each bets after each game is done   🚧
- Update a game data base with the winner and the score for each game after each verification  🚧
- A cron/worflow should be automated to launch the games information retrieval every day and the bets checking every day
- Cyber audit and tests should be made on the app  ⏳
- Bet data base : bet_id, game_id, odd, selection(home team, away team), user_id, points betted by the user  ✅
- Transaction data base : transaction_id, user_id, type(bet, added, daily_points, win, adjust), timestamp  💤
- Game data base : game_id, home team, away team, odd_home_team, odd_away_team, winner, start_time, status (started, finished, cancelled, scheduled)  ✅
- logging of the app to monitore it  💤
- CI/CD  ⏳
- Data protection, password protection, data base protection  ⏳

### TODO/TBD

1. Authentification & sécurité

méthode d'auth (JWT, sessions, refresh tokens, OAuth?) → définir.  
stockage sécurisé des mots de passe (bcrypt/argon2) et politique mot-de-passe.  
vérification d'email / activation de compte / reset password.  
protection anti brute-force (rate limiting, blocage IP temporaires).  
TLS obligatoire, CORS, CSP si tu exposes une UI web.  
gestion des rôles (admin, support) et accès admin pour gestion jeux/utilisateurs.

2. Rule of the bets
   règles de paris : types acceptés (moneyline, spread, total), cotes (decimal/american), min/max wager, montant entier ou flottant, frais éventuels.  
   règles de règlement : conditions de victoire, délais pour annuler paris (ex : jusqu'au tip-off), que faire en cas de match annulé/report?  
   distribution des 10 points journaliers : heure/timezone, idempotence (une fois par jour), que se passe-t-il si  l'utilisateur est inactif/suspendu.

3. API Endpoints : ❌ Utilisation d'un serveur pour la backedn et de firebase pour la bdd
   POST /auth/register, POST /auth/login, POST /auth/refresh, POST /auth/logout  
   GET /users/{id}, PATCH /users/{id}, DELETE /users/{id}  
   GET /games?from=...&to=...&league=NBA (pagination)  
   GET /games/{id} (with odds)  
   GET /odds?game_id=...  
   POST /bets (place bet) — body: game_id, selection, stake, client_odds_snapshot  
   GET /bets?user_id=...  
   POST /admin/games/import (admin)  
   POST /webhooks/provider (optional) — to receive pushed updates  
   GET /ranking?limit=50

4. Règles d’acceptation (exemples)
   Lors d’un pari, le solde de l’utilisateur est débité atomiquement et le pari est enregistré.   
   Les 10 points journaliers ne peuvent être crédités qu’une fois par jour par utilisateur (selon sa timezone configurée).    
   La vérification des paris se base sur le score officiel et doit mettre à jour les paris en moins de X minutes après réception du résultat.  
   Toutes les API changent le moins possible les cotes lors du placement — si la cote a changé, renvoyer 409 avec nouvelle cote.

5. Cas limites / edge cases à couvrir  
   Match OT/annulé/restart : comment régler les paris ?  
   Pari placé quelques secondes avant le tip-off — cohérence/autorisation.  
   Provider d’odds en panne — utiliser cache ou mode maintenance.  
   Utilisateur malicieux essaye d’exploiter daily bonus (multi-accounts) — besoin de détection/fingerprinting.  
   Reconciliation manuelle pour disputes.

6. Sécurité / Cyber-audit checklist minimal
   Hash mots de passe (argon2/bcrypt).  
   JWT avec refresh tokens et rotation.   
   Limites de débit + WAF.  
   Tests SAST/DAST, dépendances scannées, secrets scanning.  
   Pentest focalisé sur endpoints de pari (injection, auth bypass).  
   Logging/audit immuable pour disputes.   
   Backup chiffré + plan RTO/RPO


### Road Map

1. Application basics, frontend ✅
2. API/DataBase ✅
3. Linking API and Application (Backend) 🚧
4. Monitoring, logging ⏳
5. Cyber audit⏳
6. Deployment⏳


### +
https://github.com/swar/nba_api/blob/master/docs/nba_api/live/endpoints/odds.md
https://dashboard.api-football.com/subscription/basketball : tres bonne api mais payante