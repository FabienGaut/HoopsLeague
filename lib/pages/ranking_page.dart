import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../utils/security_utils.dart';

final supabase = Supabase.instance.client;

class LeaderboardPage extends StatefulWidget {
  final String uid;

  const LeaderboardPage({super.key, required this.uid});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> leagues = [];
  Map<String, dynamic>? selectedLeague;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeagues();
    });
  }

  Future<void> _loadLeagues() async {
    final messenger = ScaffoldMessenger.of(context);

    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      setState(() => isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unauthorizedAccess),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      debugPrint('=== FETCHING USER LEAGUES ===');
      debugPrint('User ID: ${widget.uid}');

      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', widget.uid)
          .single();

      debugPrint('User data retrieved: $userData');

      final List<String> leagueIds = List<String>.from(userData['leagues'] ?? []);
      debugPrint('League IDs found: $leagueIds');
      debugPrint('Number of leagues: ${leagueIds.length}');

      if (leagueIds.isEmpty) {
        debugPrint('No leagues found for user');
        setState(() {
          leagues = [];
          selectedLeague = null;
          users = [];
        });
        return;
      }

      debugPrint('Fetching league data for IDs: $leagueIds');
      final leaguesData = await supabase.from('leagues').select().inFilter('id', leagueIds);

      debugPrint('Leagues data retrieved: $leaguesData');
      debugPrint('Number of leagues retrieved: ${(leaguesData as List).length}');

      setState(() {
        leagues = List<Map<String, dynamic>>.from(leaguesData);
        debugPrint('Leagues stored in state: ${leagues.length}');
        for (var league in leagues) {
          debugPrint('  - ${league['name']} (ID: ${league['id']})');
        }

        if (leagues.isNotEmpty) {
          selectedLeague = leagues.first;
          debugPrint('Selected league: ${selectedLeague!['name']}');
        }
      });

      if (selectedLeague != null) fetchLeaderboard();
      debugPrint('=== FETCH USER LEAGUES COMPLETE ===');
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR FETCH USER LEAGUES ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLeaderboard() async {
    if (selectedLeague == null) return;

    setState(() => isLoading = true);
    try {
      final List<String> leagueUsersIds = List<String>.from(selectedLeague!['users_id'] ?? []);
      if (leagueUsersIds.isEmpty) {
        setState(() => users = []);
        return;
      }

      final response = await supabase.rpc(
        'get_league_members',
        params: {'p_league_id': selectedLeague!['id']},
      );
      debugPrint('League members response: $response');

      setState(() => users = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Erreur fetch leaderboard: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getRankBackground(int rank) {
    switch (rank) {
      case 1:
        return AppColors.tagOrange;
      case 2:
        return AppColors.surfaceHover;
      case 3:
        return AppColors.tagBlue;
      default:
        return AppColors.surfaceDark;
    }
  }

  Color getRankAccent(int rank) {
    switch (rank) {
      case 1:
        return AppColors.warning;
      case 2:
        return AppColors.textSecondary;
      case 3:
        return AppColors.primaryBlue;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(AppColors.logoAsset, height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(
                t.hoopsLeagueTitle,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: kToolbarHeight * 0.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : Column(
                children: [
                  if (leagues.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderDark, width: 1),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          value: selectedLeague,
                          dropdownColor: AppColors.surfaceElevated,
                          isExpanded: true,
                          underline: const SizedBox(),
                          iconEnabledColor: AppColors.primaryBlue,
                          items: leagues.map((league) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: league,
                              child: Text(
                                league['name'] ?? 'League',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedLeague = value);
                            fetchLeaderboard();
                          },
                        ),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: fetchLeaderboard,
                      child: users.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 100),
                                Center(
                                  child: Text(
                                    t.noMembersInLeague,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: logScale(context, 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final rank = index + 1;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: getRankBackground(rank),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderDark, width: 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: getRankAccent(rank).withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$rank',
                                          style: TextStyle(
                                            color: getRankAccent(rank),
                                            fontWeight: FontWeight.bold,
                                            fontSize: logScale(context, 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      user['user_name'] ?? t.unknownUser,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: logScale(context, 16),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.tagBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${user['points'] ?? 0} ${t.pointsSuffix}',
                                        style: TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: logScale(context, 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
