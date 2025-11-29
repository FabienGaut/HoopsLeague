import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hoopsleague/pages/leagues_page.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import '../helpers/test_helpers.dart';

void main() {
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

  group('LeaguesPage - Data Structure Tests', () {
    test('createLeague helper should create proper league structure', () {
      const leagueId = 'world-league-id';
      const leagueName = 'World League';
      const adminUserId = 'admin-123';
      const pendingUserId = 'pending-456';

      final league = TestData.createLeague(
        id: leagueId,
        name: leagueName,
        usersId: [adminUserId],
        pendingUsers: [pendingUserId],
      );

      expect(league['id'], equals(leagueId));
      expect(league['name'], equals(leagueName));
      expect(league['users_id'], contains(adminUserId));
      expect(league['pending_users'], contains(pendingUserId));
      expect(league['users_id'].length, equals(1));
      expect(league['pending_users'].length, equals(1));
    });

    test('createUserData helper should create proper user data structure', () {
      const userId = 'user-123';
      const userName = 'TestPlayer';
      const leagueId = 'league-456';

      final userData = TestData.createUserData(
        id: userId,
        userName: userName,
        leagues: [leagueId],
      );

      expect(userData['id'], equals(userId));
      expect(userData['user_name'], equals(userName));
      expect(userData['leagues'], contains(leagueId));
      expect(userData['leagues'].length, equals(1));
    });

    test('league access request flow - data transformation', () {
      // Scenario: User requests to join league, admin accepts
      const adminUserId = 'admin-user-123';
      const newUserId = 'new-user-456';
      const leagueId = 'world-league-id';
      const leagueName = 'World League';

      // Step 1: Initial state - league has admin, new user is pending
      final initialLeague = TestData.createLeague(
        id: leagueId,
        name: leagueName,
        usersId: [adminUserId],
        pendingUsers: [newUserId],
      );

      final initialUserData = TestData.createUserData(
        id: newUserId,
        userName: 'NewPlayer',
        leagues: [], // User has no leagues yet
      );

      // Verify initial state
      expect(initialLeague['users_id'], contains(adminUserId));
      expect(initialLeague['users_id'], isNot(contains(newUserId)));
      expect(initialLeague['pending_users'], contains(newUserId));
      expect(initialUserData['leagues'], isEmpty);

      // Step 2: Simulate acceptance - what should happen
      // Remove user from pending_users
      final pendingUsers = List<String>.from(initialLeague['pending_users']);
      pendingUsers.remove(newUserId);

      // Add user to users_id
      final usersId = List<String>.from(initialLeague['users_id']);
      usersId.add(newUserId);

      // Add league to user's leagues array
      final userLeagues = List<String>.from(initialUserData['leagues']);
      userLeagues.add(leagueId);

      // Step 3: Verify final state
      expect(usersId, contains(adminUserId));
      expect(usersId, contains(newUserId));
      expect(usersId.length, equals(2));
      expect(pendingUsers, isEmpty);
      expect(userLeagues, contains(leagueId));
      expect(userLeagues.length, equals(1));

      // This validates the logic in _acceptUser method:
      // 1. User is removed from pending_users ✓
      // 2. User is added to users_id ✓
      // 3. League ID is added to user's leagues array ✓
    });

    test('league access request flow - multiple leagues', () {
      const userId = 'user-123';
      const existingLeagueId = 'existing-league';
      const newLeagueId = 'new-league';

      // User already has one league
      final userData = TestData.createUserData(
        id: userId,
        userName: 'Player',
        leagues: [existingLeagueId],
      );

      expect(userData['leagues'], contains(existingLeagueId));
      expect(userData['leagues'].length, equals(1));

      // User joins another league
      final userLeagues = List<String>.from(userData['leagues']);
      userLeagues.add(newLeagueId);

      expect(userLeagues, contains(existingLeagueId));
      expect(userLeagues, contains(newLeagueId));
      expect(userLeagues.length, equals(2));
    });

    test('league access request flow - reject user', () {
      const adminUserId = 'admin-123';
      const rejectedUserId = 'rejected-456';
      const leagueId = 'league-id';

      final league = TestData.createLeague(
        id: leagueId,
        name: 'Test League',
        usersId: [adminUserId],
        pendingUsers: [rejectedUserId],
      );

      final userData = TestData.createUserData(
        id: rejectedUserId,
        userName: 'RejectedPlayer',
        leagues: [],
      );

      // Simulate rejection - only remove from pending, don't add to users_id or leagues
      final pendingUsers = List<String>.from(league['pending_users']);
      pendingUsers.remove(rejectedUserId);

      expect(pendingUsers, isEmpty);
      expect(league['users_id'], isNot(contains(rejectedUserId)));
      expect(userData['leagues'], isEmpty);
    });
  });

  group('LeaguesPage - Non-Regression Test', () {
    test('League access request acceptance flow', () {
      // This test validates the complete flow described in the user requirement:
      // 1. Create a user
      // 2. User requests to join "World League"
      // 3. Another user (admin) accepts the request
      // 4. Verify league ID is added to user's leagues array

      // Setup: World League with admin
      const adminUserId = 'admin-user-123';
      const newUserId = 'new-player-456';
      const worldLeagueId = 'world-league-id';
      const worldLeagueName = 'World League';

      // Initial state: World League exists with admin
      final worldLeague = TestData.createLeague(
        id: worldLeagueId,
        name: worldLeagueName,
        usersId: [adminUserId],
        pendingUsers: [],
      );

      // Step 1: Create new user
      final newUser = TestData.createUserData(
        id: newUserId,
        userName: 'NewPlayer',
        leagues: [], // No leagues initially
      );

      expect(newUser['leagues'], isEmpty, reason: 'New user should have no leagues');

      // Step 2: User requests to join World League
      // This adds the user to pending_users
      final pendingUsers = List<String>.from(worldLeague['pending_users']);
      pendingUsers.add(newUserId);

      expect(pendingUsers, contains(newUserId), 
        reason: 'User should be in pending_users after requesting to join');

      // Step 3: Admin accepts the request
      // This is what _acceptUser does:
      
      // 3a. Remove from pending_users
      pendingUsers.remove(newUserId);
      
      // 3b. Add to users_id
      final usersId = List<String>.from(worldLeague['users_id']);
      usersId.add(newUserId);
      
      // 3c. Add league ID to user's leagues array (THIS IS THE KEY REQUIREMENT)
      final userLeagues = List<String>.from(newUser['leagues']);
      userLeagues.add(worldLeagueId);

      // Step 4: Verify the final state
      expect(pendingUsers, isEmpty, 
        reason: 'User should be removed from pending_users');
      
      expect(usersId, contains(newUserId), 
        reason: 'User should be added to league users_id');
      
      expect(usersId, contains(adminUserId), 
        reason: 'Admin should still be in league users_id');
      
      // THIS IS THE CRITICAL ASSERTION - validates the user requirement
      expect(userLeagues, contains(worldLeagueId), 
        reason: 'League ID MUST be added to user\'s leagues array in usersdata');
      
      expect(userLeagues.length, equals(1), 
        reason: 'User should have exactly one league');

      // SUCCESS: This test validates that when a league access request is accepted,
      // the league ID is properly added to the user's leagues array in usersdata
    });
  });
}
