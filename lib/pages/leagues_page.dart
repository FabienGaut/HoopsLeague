import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';

import '../utils/security_utils.dart';

final supabase = Supabase.instance.client;

class LeaguesPage extends StatefulWidget {
  final String uid;
  final SupabaseClient? supabaseClient;

  const LeaguesPage({
    super.key,
    required this.uid,
    this.supabaseClient,
  });

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  late final SupabaseClient supabase;
  final TextEditingController _leagueNameController = TextEditingController();
  final TextEditingController _joinLeagueController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> leagues = [];
  Map<String, dynamic>? _leaguePreview;
  Timer? _debounceTimer;
  List<Map<String, dynamic>> _pendingRequests = [];

  // Ranking state
  List<Map<String, dynamic>> rankingUsers = [];
  Map<String, dynamic>? selectedLeagueForRanking;
  bool isLoadingRanking = false;

  @override
  void initState() {
    super.initState();
    supabase = widget.supabaseClient ?? Supabase.instance.client;
    _loadLeagues();
    _joinLeagueController.addListener(_onJoinLeagueTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _joinLeagueController.removeListener(_onJoinLeagueTextChanged);
    _leagueNameController.dispose();
    _joinLeagueController.dispose();
    super.dispose();
  }

  void _onJoinLeagueTextChanged() {
    _debounceTimer?.cancel();
    if (_joinLeagueController.text.trim().isEmpty) {
      if (!mounted) return;
      setState(() => _leaguePreview = null);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _searchLeaguePreview();
    });
  }

  Future<void> _loadLeagues() async {
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await supabase.from('leagues')
          .select()
          .contains('users_id', [widget.uid]);
      if (!mounted) return;
      setState(() {
        leagues = List<Map<String, dynamic>>.from(data);
        if (leagues.isNotEmpty) {
          selectedLeagueForRanking = leagues.first;
        }
      });
      await _loadPendingRequests();
      if (selectedLeagueForRanking != null) {
        await fetchLeaderboard();
      }
    } catch (e) {
      debugPrint('Erreur chargement leagues: $e');
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLeaderboard() async {
    if (selectedLeagueForRanking == null) return;

    if (!mounted) return;
    setState(() => isLoadingRanking = true);
    try {
      final List<String> leagueUsersIds =
      List<String>.from(selectedLeagueForRanking!['users_id'] ?? []);
      if (leagueUsersIds.isEmpty) {
        if (!mounted) return;
        setState(() => rankingUsers = []);
        if (mounted) {
          setState(() => isLoadingRanking = false);
        }
        return;
      }

      final response = await supabase.rpc(
          'get_league_members',
          params: {'p_league_id': selectedLeagueForRanking!['id']}
      );
      debugPrint('League members response: $response');

      if (!mounted) return;
      setState(() => rankingUsers = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Erreur fetch leaderboard: $e');
    }
    if (mounted) {
      setState(() => isLoadingRanking = false);
    }
  }

  Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.tagOrange;
      case 2:
        return AppColors.tagBlue.withValues(alpha: 0.7);
      case 3:
        return AppColors.tagGreen.withValues(alpha: 0.7);
      default:
        return AppColors.surfaceHover;
    }
  }

  Future<void> _createLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final name = _leagueNameController.text.trim();
    if (name.isEmpty) return;

    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.securityError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      debugPrint('=== CREATE LEAGUE START ===');
      debugPrint('League name: $name');
      debugPrint('Creator UID: ${widget.uid}');

      final existing = await supabase.rpc(
        'search_league_by_name',
        params: {'p_name': name},
      );

      if (existing != null) {
        debugPrint('League already exists: $name');
        messenger.showSnackBar(
          SnackBar(content: Text(t.leagueExists), backgroundColor: AppColors.warning),
        );
        return;
      }

      debugPrint('Creating league...');
      final newLeague = await supabase.from('leagues').insert({
        'name': name,
        'users_id': [widget.uid],
      }).select().single();

      final leagueId = newLeague['id'];
      debugPrint('League created with ID: $leagueId');

      debugPrint('Adding league to user leagues array...');
      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', widget.uid)
          .single();

      final userLeagues = List<String>.from(userData['leagues'] ?? []);
      debugPrint('Current user leagues: $userLeagues');

      userLeagues.add(leagueId);
      debugPrint('Updated user leagues: $userLeagues');

      await supabase
          .from('usersdata')
          .update({'leagues': userLeagues})
          .eq('id', widget.uid);

      debugPrint('League added to user leagues array');
      debugPrint('=== CREATE LEAGUE END ===');

      _leagueNameController.clear();
      _loadLeagues();
      messenger.showSnackBar(
        SnackBar(content: Text(t.leagueCreated), backgroundColor: AppColors.success),
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR CRÉATION LEAGUE ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${t.errorMessage}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _joinLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) return;

    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.securityError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final leagueData = await supabase.rpc(
        'search_league_by_name',
        params: {'p_name': leagueName},
      );

      if (leagueData == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('${t.leagueNotFoundWithName} "$leagueName"'), backgroundColor: AppColors.warning),
        );
        return;
      }

      final leagueId = leagueData['id'] as String;

      if (leagues.any((l) => l['id'] == leagueId)) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.alreadyMember), backgroundColor: AppColors.warning),
        );
        return;
      }

      final result = await supabase.rpc(
        'request_join_league',
        params: {'p_league_id': leagueId},
      );

      _joinLeagueController.clear();
      final status = result['status'] as String?;
      if (status == 'joined') {
        _loadLeagues();
        messenger.showSnackBar(
          SnackBar(content: Text('${t.joinedLeague} $leagueName !'), backgroundColor: AppColors.success),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(t.requestSent), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      final errMsg = e.toString();
      if (errMsg.contains('Already a member')) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.alreadyMember), backgroundColor: AppColors.warning),
        );
      } else if (errMsg.contains('Already pending')) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.alreadyInPending), backgroundColor: AppColors.warning),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('${t.errorMessage}: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final allPendingRequests = <Map<String, dynamic>>[];

      for (final league in leagues) {
        final leagueId = league['id'];
        final leagueName = league['name'];
        final pendingUserIds = List<String>.from(league['pending_users'] ?? []);

        for (final userId in pendingUserIds) {
          try {
            final userName = await supabase.rpc(
              'get_username_from_uid',
              params: {'p_user_id': userId},
            );

            allPendingRequests.add({
              'league_id': leagueId,
              'league_name': leagueName,
              'user_id': userId,
              'user_name': userName ?? 'Utilisateur supprimé',
            });
          } catch (e) {
            debugPrint('Erreur récupération user $userId: $e');
            allPendingRequests.add({
              'league_id': leagueId,
              'league_name': leagueName,
              'user_id': userId,
              'user_name': 'Utilisateur inconnu',
            });
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _pendingRequests = allPendingRequests;
      });
    } catch (e) {
      debugPrint('Erreur chargement pending requests: $e');
    }
  }

  Future<void> _acceptUser(String leagueId, String userId, String userName) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      debugPrint('=== ACCEPT USER START ===');
      debugPrint('League ID: $leagueId');
      debugPrint('User ID: $userId');
      debugPrint('User Name: $userName');

      debugPrint('Fetching league data...');
      final league = await supabase
          .from('leagues')
          .select('users_id, pending_users')
          .eq('id', leagueId)
          .single();

      final usersId = List<String>.from(league['users_id'] ?? []);
      final pendingUsers = List<String>.from(league['pending_users'] ?? []);

      debugPrint('Current users_id: $usersId');
      debugPrint('Current pending_users: $pendingUsers');

      pendingUsers.remove(userId);
      usersId.add(userId);

      debugPrint('Updated users_id: $usersId');
      debugPrint('Updated pending_users: $pendingUsers');

      debugPrint('Updating league...');
      await supabase
          .from('leagues')
          .update({
            'users_id': usersId,
            'pending_users': pendingUsers,
          })
          .eq('id', leagueId);

      debugPrint('League updated successfully');

      debugPrint('Fetching user data...');
      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', userId)
          .single();

      final userLeagues = List<String>.from(userData['leagues'] ?? []);
      debugPrint('Current user leagues: $userLeagues');

      userLeagues.add(leagueId);
      debugPrint('Updated user leagues: $userLeagues');

      debugPrint('Updating user data...');
      await supabase
          .from('usersdata')
          .update({'leagues': userLeagues})
          .eq('id', userId);

      debugPrint('User data updated successfully');

      debugPrint('Refreshing leagues...');
      await _loadLeagues();
      debugPrint('Refreshing pending requests...');
      await _loadPendingRequests();
      debugPrint('=== ACCEPT USER END ===');

      messenger.showSnackBar(
        SnackBar(content: Text('$userName ${t.userAcceptedInLeague}'), backgroundColor: AppColors.success),
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR ACCEPT USER ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      messenger.showSnackBar(
        SnackBar(content: Text('${t.errorMessage}: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _rejectUser(String leagueId, String userId, String userName) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final league = await supabase
          .from('leagues')
          .select('pending_users')
          .eq('id', leagueId)
          .single();

      final pendingUsers = List<String>.from(league['pending_users'] ?? []);

      pendingUsers.remove(userId);

      await supabase
          .from('leagues')
          .update({'pending_users': pendingUsers})
          .eq('id', leagueId);

      await _loadLeagues();
      await _loadPendingRequests();

      messenger.showSnackBar(
        SnackBar(content: Text('$userName ${t.userRejected}'), backgroundColor: AppColors.warning),
      );
    } catch (e) {
      debugPrint('Erreur reject user: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(t.errorRejectingUser), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _searchLeaguePreview() async {
    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) {
      if (!mounted) return;
      setState(() => _leaguePreview = null);
      return;
    }

    try {
      final result = await supabase.rpc(
        'search_league_by_name',
        params: {'p_name': leagueName},
      );

      if (!mounted) return;
      setState(() {
        _leaguePreview = result != null ? Map<String, dynamic>.from(result) : null;
      });
    } catch (e) {
      debugPrint('Erreur recherche league: $e');
      if (!mounted) return;
      setState(() => _leaguePreview = null);
    }
  }

  Future<void> _leaveLeague(String leagueId, String leagueName) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          t.leaveLeague,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${t.leaveLeagueConfirm}\n"$leagueName"',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancel, style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, elevation: 0),
            child: Text(t.leave, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase.rpc(
        'leave_league',
        params: {'p_league_id': leagueId},
      );

      _loadLeagues();
      messenger.showSnackBar(
        SnackBar(content: Text('${t.leftLeague} $leagueName'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      debugPrint('Erreur leave league: $e');
      messenger.showSnackBar(
        SnackBar(content: Text('${t.errorMessage}: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title, {Color? iconBgColor, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBgColor ?? AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16), fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset('assets/images/logo_black.png', height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(
                t.myLeagues,
                style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadLeagues();
            if (selectedLeagueForRanking != null) {
              await fetchLeaderboard();
            }
          },
          color: AppColors.primaryBlue,
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rankings Section
                      if (leagues.isNotEmpty) ...[
                        _sectionHeader(Icons.leaderboard_outlined, t.rankings, iconBgColor: AppColors.tagOrange, iconColor: AppColors.warning),
                        _buildCard(
                          child: Column(
                            children: [
                              // League dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceHover,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderDark),
                                ),
                                child: DropdownButton<Map<String, dynamic>>(
                                  value: selectedLeagueForRanking,
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
                                    setState(() => selectedLeagueForRanking = value);
                                    fetchLeaderboard();
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Ranking list
                              if (isLoadingRanking)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                                  ),
                                )
                              else if (rankingUsers.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Text(
                                      t.noMembersInLeague,
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: rankingUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = rankingUsers[index];
                                    final rank = index + 1;

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: getRankColor(rank),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.borderDark, width: 1),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        leading: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: rank <= 3 ? AppColors.primaryBlue : AppColors.surfaceHover,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$rank',
                                              style: TextStyle(
                                                color: rank <= 3 ? Colors.white : AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: logScale(context, 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          user['user_name'] ?? t.unknownUser,
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: logScale(context, 15),
                                          ),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.tagBlue,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${user['points'] ?? 0} ${t.pointsSuffix}',
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.w600,
                                              fontSize: logScale(context, 13),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],

                      // Suggested leagues
                      _buildLeagueSuggestions(),

                      // My Leagues Section
                      _sectionHeader(Icons.groups_outlined, t.myLeagues),
                      leagues.isEmpty
                          ? _buildCard(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.group_off_outlined, color: AppColors.textTertiary, size: 48),
                                      const SizedBox(height: 12),
                                      Text(
                                        t.noMembersInLeague,
                                        style: TextStyle(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: leagues.map((league) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.borderDark, width: 1),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
                                      child: Icon(Icons.emoji_events_outlined, color: AppColors.primaryBlue, size: 20),
                                    ),
                                    title: Text(
                                      league['name'],
                                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                    subtitle: Text(
                                      () {
                                        final memberCount = (league['users_id'] as List?)?.length ?? 0;
                                        final locale = Localizations.localeOf(context).languageCode;
                                        if (memberCount == 1) {
                                          return locale == 'fr' ? '1 membre' : '1 member';
                                        } else {
                                          return locale == 'fr' ? '$memberCount membres' : '$memberCount members';
                                        }
                                      }(),
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 13)),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.logout_outlined, color: AppColors.error, size: 20),
                                      onPressed: () => _leaveLeague(league['id'], league['name']),
                                      tooltip: t.quit,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                      // Create League Section
                      _sectionHeader(Icons.add_circle_outline, t.createLeague, iconBgColor: AppColors.tagBlue, iconColor: AppColors.primaryBlue),
                      _buildCard(
                        child: _glassInputRow(
                          controller: _leagueNameController,
                          hint: t.leagueName,
                          buttonText: t.create,
                          onPressed: _createLeague,
                        ),
                      ),

                      // Join League Section
                      _sectionHeader(Icons.group_add_outlined, t.joinLeague, iconBgColor: AppColors.tagGreen, iconColor: AppColors.success),
                      _buildCard(
                        child: Column(
                          children: [
                            _glassInputRow(
                              controller: _joinLeagueController,
                              hint: t.enterLeagueName,
                              buttonText: t.join,
                              onPressed: _joinLeague,
                            ),
                            if (_joinLeagueController.text.trim().isNotEmpty)
                              _buildLeaguePreview(),
                          ],
                        ),
                      ),

                      // Pending Requests Section
                      if (leagues.isNotEmpty)
                        _buildPendingRequestsSection(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLeaguePreview() {
    final t = AppLocalizations.of(context)!;

    if (_leaguePreview == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.tagOrange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.leagueNotFoundPreview,
                  style: TextStyle(color: AppColors.warning, fontSize: logScale(context, 13)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final memberCount = (_leaguePreview!['member_count'] as num?)?.toInt() ?? 0;
    final alreadyJoined = leagues.any((l) => l['id'] == _leaguePreview!['id']);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: alreadyJoined ? AppColors.tagGreen : AppColors.tagBlue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              alreadyJoined ? Icons.check_circle_outlined : Icons.group_outlined,
              color: alreadyJoined ? AppColors.success : AppColors.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _leaguePreview!['name'],
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: logScale(context, 14)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alreadyJoined
                        ? t.alreadyMember
                        : () {
                            final locale = Localizations.localeOf(context).languageCode;
                            if (memberCount == 1) {
                              return locale == 'fr' ? '1 membre' : '1 member';
                            } else {
                              return locale == 'fr' ? '$memberCount membres' : '$memberCount members';
                            }
                          }(),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.pending_outlined, '${t.pendingRequests} (${_pendingRequests.length})', iconBgColor: AppColors.tagOrange, iconColor: AppColors.warning),
        _pendingRequests.isEmpty
            ? _buildCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t.noPendingRequests,
                      style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              )
            : Column(
                children: _pendingRequests.map((request) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderDark, width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(8)),
                          child: Icon(Icons.person_outline, color: AppColors.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['user_name'],
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: logScale(context, 14)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                request['league_name'],
                                style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 12)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.check_circle_outlined, color: AppColors.success, size: 24),
                          onPressed: () => _acceptUser(request['league_id'], request['user_id'], request['user_name']),
                          tooltip: t.accept,
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel_outlined, color: AppColors.error, size: 24),
                          onPressed: () => _rejectUser(request['league_id'], request['user_id'], request['user_name']),
                          tooltip: t.reject,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildLeagueSuggestions() {
    final suggestedLeagues = ['HoopsLeague'];

    final filteredSuggestions = suggestedLeagues.where((leagueName) {
      return !leagues.any((l) => l['name'] == leagueName);
    }).toList();

    if (filteredSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ligues suggérées',
                style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredSuggestions.map((leagueName) {
            return GestureDetector(
              onTap: () {
                _joinLeagueController.text = leagueName;
                _joinLeague();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.tagBlue,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primaryBlue, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      leagueName,
                      style: TextStyle(color: AppColors.primaryBlue, fontSize: logScale(context, 13), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _glassInputRow({
    required TextEditingController controller,
    required String hint,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: 30,
            style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 14)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 14)),
              filled: true,
              fillColor: AppColors.surfaceHover,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.borderDark)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primaryBlue)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: Text(
            buttonText,
            style: TextStyle(color: Colors.white, fontSize: logScale(context, 14), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
