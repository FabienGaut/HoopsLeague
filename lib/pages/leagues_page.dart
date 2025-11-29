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
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  late final SupabaseClient supabase;
  final TextEditingController _leagueNameController = TextEditingController();
  final TextEditingController _joinLeagueController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> leagues = [];
  Map<String, dynamic>? _leaguePreview;
  Timer? _debounceTimer;
  List<Map<String, dynamic>> _pendingRequests = [];

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
      setState(() => _leaguePreview = null);
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLeaguePreview();
    });
  }

  Future<void> _loadLeagues() async {
    // Security: Validate user ID before loading leagues
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      setState(() => isLoading = false);
      return;
    }
    
    setState(() => isLoading = true);
    try {
      final data = await supabase.from('leagues')
          .select()
          .contains('users_id', [widget.uid]);
      setState(() {
        leagues = List<Map<String, dynamic>>.from(data);
      });
      // Recharger les demandes en attente après avoir chargé les ligues
      await _loadPendingRequests();
    } catch (e) {
      debugPrint('Erreur chargement leagues: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final name = _leagueNameController.text.trim();
    if (name.isEmpty) return;

    // Security: Validate user ID before creating league
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.securityError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      debugPrint('=== CREATE LEAGUE START ===');
      debugPrint('League name: $name');
      debugPrint('Creator UID: ${widget.uid}');
      
      final existing = await supabase
          .from('leagues')
          .select('id')
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        debugPrint('League already exists: $name');
        messenger.showSnackBar(
          SnackBar(content: Text(t.leagueExists)),
        );
        return;
      }

      // Créer la ligue
      debugPrint('Creating league...');
      final newLeague = await supabase.from('leagues').insert({
        'name': name,
        'users_id': [widget.uid],
      }).select().single();
      
      final leagueId = newLeague['id'];
      debugPrint('League created with ID: $leagueId');

      // Ajouter la ligue au tableau leagues de l'utilisateur créateur
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
        SnackBar(content: Text(t.leagueCreated)),
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR CRÉATION LEAGUE ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${t.errorMessage}: $e')),
        );
      }
    }
  }

  Future<void> _joinLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) return;

    // Security: Validate user ID before joining league
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.securityError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Récupérer la ligue par son nom
      final league = await supabase
          .from('leagues')
          .select()
          .eq('name', leagueName)
          .maybeSingle();

      if (league == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('${t.leagueNotFoundWithName} "$leagueName"')),
        );
        return;
      }

      final leagueId = league['id'];
      final pendingUsers = List<String>.from(league['pending_users'] ?? []);

      // Vérifier si l'utilisateur est déjà en attente
      if (pendingUsers.contains(widget.uid)) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.alreadyInPending)),
        );
        return;
      }

      // Auto-join pour la ligue "HoopsLeague"
      if (leagueName.toLowerCase() == 'hoopsleague') {
        // Ajouter directement l'utilisateur à la ligue
        final usersId = List<String>.from(league['users_id'] ?? []);
        
        // Vérifier si déjà membre
        if (usersId.contains(widget.uid)) {
          messenger.showSnackBar(
            SnackBar(content: Text(t.alreadyMember)),
          );
          return;
        }
        
        // Ajouter à la liste des membres
        usersId.add(widget.uid);
        
        // Mettre à jour la ligue
        await supabase
            .from('leagues')
            .update({'users_id': usersId})
            .eq('id', leagueId);
        
        // Ajouter la ligue au profil utilisateur
        final userData = await supabase
            .from('usersdata')
            .select('leagues')
            .eq('id', widget.uid)
            .single();
        
        final userLeagues = List<String>.from(userData['leagues'] ?? []);
        if (!userLeagues.contains(leagueId)) {
          userLeagues.add(leagueId);
          await supabase
              .from('usersdata')
              .update({'leagues': userLeagues})
              .eq('id', widget.uid);
        }
        
        _joinLeagueController.clear();
        _loadLeagues();
        messenger.showSnackBar(
          SnackBar(content: Text('${t.joinedLeague} $leagueName !')),
        );
      } else {
        // Pour les autres ligues, ajouter en pending comme avant
        pendingUsers.add(widget.uid);

        await supabase
            .from('leagues')
            .update({'pending_users': pendingUsers})
            .eq('id', leagueId);

        _joinLeagueController.clear();
        messenger.showSnackBar(
          SnackBar(content: Text(t.requestSent)),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${t.errorMessage}: $e')),
      );
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final allPendingRequests = <Map<String, dynamic>>[];

      // Pour chaque ligue dont l'utilisateur est membre
      for (final league in leagues) {
        final leagueId = league['id'];
        final leagueName = league['name'];
        final pendingUserIds = List<String>.from(league['pending_users'] ?? []);

        // Récupérer les infos des utilisateurs en attente
        for (final userId in pendingUserIds) {
          try {
            final userName = await supabase.rpc(
              'get_username_from_uid',
              params: {'p_user_id': userId},
            );

            // Si l'utilisateur n'existe pas, on l'affiche quand même avec un nom par défaut
            allPendingRequests.add({
              'league_id': leagueId,
              'league_name': leagueName,
              'user_id': userId,
              'user_name': userName ?? 'Utilisateur supprimé',
            });
          } catch (e) {
            debugPrint('Erreur récupération user $userId: $e');
            // Ajouter quand même avec un nom par défaut en cas d'erreur
            allPendingRequests.add({
              'league_id': leagueId,
              'league_name': leagueName,
              'user_id': userId,
              'user_name': 'Utilisateur inconnu',
            });
          }
        }
      }

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

      // Récupérer la ligue
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

      // Retirer de pending_users et ajouter à users_id
      pendingUsers.remove(userId);
      usersId.add(userId);
      
      debugPrint('Updated users_id: $usersId');
      debugPrint('Updated pending_users: $pendingUsers');

      // Mettre à jour la ligue
      debugPrint('Updating league...');
      await supabase
          .from('leagues')
          .update({
            'users_id': usersId,
            'pending_users': pendingUsers,
          })
          .eq('id', leagueId);
      
      debugPrint('League updated successfully');

      // Ajouter la ligue au tableau leagues de l'utilisateur
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

      // Rafraîchir les données
      debugPrint('Refreshing leagues...');
      await _loadLeagues();
      debugPrint('Refreshing pending requests...');
      await _loadPendingRequests();
      debugPrint('=== ACCEPT USER END ===');

      messenger.showSnackBar(
        SnackBar(content: Text('$userName ${t.userAcceptedInLeague}')),
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERREUR ACCEPT USER ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      messenger.showSnackBar(
        SnackBar(content: Text('${t.errorMessage}: $e')),
      );
    }
  }

  Future<void> _rejectUser(String leagueId, String userId, String userName) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Récupérer la ligue
      final league = await supabase
          .from('leagues')
          .select('pending_users')
          .eq('id', leagueId)
          .single();

      final pendingUsers = List<String>.from(league['pending_users'] ?? []);

      // Retirer de pending_users
      pendingUsers.remove(userId);

      await supabase
          .from('leagues')
          .update({'pending_users': pendingUsers})
          .eq('id', leagueId);

      // Rafraîchir les données
      await _loadLeagues();
      await _loadPendingRequests();

      messenger.showSnackBar(
        SnackBar(content: Text('$userName ${t.userRejected}')),
      );
    } catch (e) {
      debugPrint('Erreur reject user: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(t.errorRejectingUser)),
      );
    }
  }

  Future<void> _searchLeaguePreview() async {
    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) {
      setState(() => _leaguePreview = null);
      return;
    }

    try {
      final league = await supabase
          .from('leagues')
          .select('id, name, users_id')
          .eq('name', leagueName)
          .maybeSingle();

      setState(() {
        _leaguePreview = league;
      });
    } catch (e) {
      debugPrint('Erreur recherche league: $e');
      setState(() => _leaguePreview = null);
    }
  }

  Future<void> _leaveLeague(String leagueId, String leagueName) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a2332),
        title: Text(
          t.leaveLeague,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${t.leaveLeagueConfirm}\n"$leagueName"',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              t.cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              t.leave,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Remove user from league's users_id array
      final league = await supabase
          .from('leagues')
          .select('users_id')
          .eq('id', leagueId)
          .single();

      final usersList = List<String>.from(league['users_id'] ?? []);
      usersList.remove(widget.uid);

      await supabase
          .from('leagues')
          .update({'users_id': usersList})
          .eq('id', leagueId);

      // Remove league from user's leagues array
      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', widget.uid)
          .single();

      final leaguesList = List<String>.from(userData['leagues'] ?? []);
      leaguesList.remove(leagueId);

      await supabase
          .from('usersdata')
          .update({'leagues': leaguesList})
          .eq('id', widget.uid);

      _loadLeagues();
      messenger.showSnackBar(
        SnackBar(content: Text('${t.leftLeague} $leagueName')),
      );
    } catch (e) {
      debugPrint('Erreur leave league: $e');
      messenger.showSnackBar(
        SnackBar(content: Text('${t.errorMessage}: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown, // rétrécit si nécessaire
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: kToolbarHeight * 0.6, // proportion de l’AppBar
              ),
              SizedBox(width: kToolbarHeight * 0.2),
              Text(
                t.myLeagues,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4, // proportion de l’AppBar
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌌 Dégradé violet → noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: accentPrimary))
                  : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Création de ligue
                    Text(
                      t.createLeague,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: logScale(context, 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _glassInputRow(
                      controller: _leagueNameController,
                      hint: t.leagueName,
                      buttonText: t.create,
                      onPressed: _createLeague,
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Rejoindre une ligue
                    Text(
                      t.joinLeague,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: logScale(context, 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _glassInputRow(
                      controller: _joinLeagueController,
                      hint: t.enterLeagueName,
                      buttonText: t.join,
                      onPressed: _joinLeague,
                    ),
                    
                    // 🔹 Prévisualisation de la ligue
                    if (_joinLeagueController.text.trim().isNotEmpty)
                      _buildLeaguePreview(),
                    
                    const SizedBox(height: 16),

                    // 🔹 Demandes en attente (toujours afficher si l'utilisateur a des ligues)
                    if (leagues.isNotEmpty)
                      _buildPendingRequestsSection(),

                    if (leagues.isNotEmpty)
                      const SizedBox(height: 16),

                    // 🔹 Suggestions de ligues
                    _buildLeagueSuggestions(),
                    const SizedBox(height: 24),

                    // 🔹 Liste des ligues
                    Text(
                      t.myLeagues,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: logScale(context, 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    leagues.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          t.noMembersInLeague,
                          style: const TextStyle(color: textSecondary),
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leagues.length,
                      itemBuilder: (context, index) {
                        final league = leagues[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              league['name'],
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              t.membersCount(
                                (league['users_id'] as List?)?.length ?? 0,
                              ),
                              style: const TextStyle(color: textSecondary),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.exit_to_app,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _leaveLeague(
                                league['id'],
                                league['name'],
                              ),
                              tooltip: t.quit,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16), // Padding en bas pour le scroll
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLeaguePreview() {
    final t = AppLocalizations.of(context)!;
    
    if (_leaguePreview == null) {
      // Still loading or not found
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: logScale(context, 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.leagueNotFoundPreview,
                  style: TextStyle(
                    color: Colors.orange.shade200,
                    fontSize: logScale(context, 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // League found - show preview
    final memberCount = (_leaguePreview!['users_id'] as List?)?.length ?? 0;
    final alreadyJoined = leagues.any((l) => l['id'] == _leaguePreview!['id']);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentPrimary.withValues(alpha: 0.2),
              accentPrimary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentPrimary.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              alreadyJoined ? Icons.check_circle : Icons.group,
              color: alreadyJoined ? Colors.green : accentPrimary,
              size: logScale(context, 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _leaguePreview!['name'],
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: logScale(context, 14),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alreadyJoined
                        ? t.alreadyMember
                        : t.membersCount(memberCount),
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: logScale(context, 12),
                    ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${_pendingRequests.length}',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: logScale(context, 14),
              ),
            ),
          ),
          title: Text(
            t.pendingRequests,
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: logScale(context, 16),
            ),
          ),
          iconColor: Colors.orange,
          collapsedIconColor: Colors.orange,
          children: _pendingRequests.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        t.noPendingRequests,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: logScale(context, 14),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ]
              : _pendingRequests.map((request) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF222F49),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // User icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: accentPrimary,
                      size: logScale(context, 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['user_name'],
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: logScale(context, 14),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          request['league_name'],
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: logScale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Accept button
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _acceptUser(
                      request['league_id'],
                      request['user_id'],
                      request['user_name'],
                    ),
                    tooltip: t.accept,
                  ),
                  // Reject button
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _rejectUser(
                      request['league_id'],
                      request['user_id'],
                      request['user_name'],
                    ),
                    tooltip: t.reject,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLeagueSuggestions() {
    final suggestedLeagues = ['HoopsLeague'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.amber,
              size: logScale(context, 18),
            ),
            const SizedBox(width: 6),
            Text(
              'Ligues suggérées',
              style: TextStyle(
                color: textSecondary,
                fontSize: logScale(context, 14),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestedLeagues.map((leagueName) {
            // Check if user is already in this league
            final alreadyJoined = leagues.any((l) => l['name'] == leagueName);
            
            return GestureDetector(
              onTap: alreadyJoined ? null : () {
                _joinLeagueController.text = leagueName;
                _joinLeague();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: alreadyJoined
                      ? LinearGradient(
                          colors: [
                            Colors.grey.withValues(alpha: 0.3),
                            Colors.grey.withValues(alpha: 0.2),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            accentPrimary.withValues(alpha: 0.3),
                            accentPrimary.withValues(alpha: 0.15),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: alreadyJoined
                        ? Colors.white.withValues(alpha: 0.1)
                        : accentPrimary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: alreadyJoined
                      ? []
                      : [
                          BoxShadow(
                            color: accentPrimary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      alreadyJoined ? Icons.check_circle : Icons.add_circle_outline,
                      color: alreadyJoined ? Colors.white54 : accentPrimary,
                      size: logScale(context, 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      leagueName,
                      style: TextStyle(
                        color: alreadyJoined ? textSecondary : textPrimary,
                        fontSize: logScale(context, 13),
                        fontWeight: alreadyJoined ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF222F49), // même fond que GamesPage
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF222F49), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                maxLength: 30,
                controller: controller,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logScale(context, 14),
                ),
                decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: logScale(context, 14),
                ),
                border: InputBorder.none,
                isCollapsed: true, // <-- pour un centrage parfait
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              ),

              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue, // couleur GamesPage
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: logScale(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
