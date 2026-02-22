import 'package:flutter/material.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/utils/responsive_utils.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/sidebar_navigation.dart';
import 'app_state.dart';
import 'games_page.dart';
import 'passed_bets.dart';
import 'leagues_page.dart';
import 'manage_account_page.dart';
import 'bucket_page.dart';
import 'bug_page.dart';

/// Public interface for MainNavigation controller methods
abstract class MainNavigationController {
  void showBucketPage(List<Map<String, dynamic>> bets, {VoidCallback? onBetPlaced, void Function(int index)? onBetRemoved});
  void showBugReportPage();
  void closeOverlay();
}

class MainNavigation extends StatefulWidget {
  final String uid;
  final int initialIndex;
  final bool showTutorial;

  const MainNavigation({
    super.key,
    required this.uid,
    this.initialIndex = 0,
    this.showTutorial = false,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  static MainNavigationController? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainNavigationState>();
  }
}

class _MainNavigationState extends State<MainNavigation>
    with WidgetsBindingObserver
    implements MainNavigationController {
  late int _currentIndex;
  Widget? _overlayPage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app resumes from background
      context.read<AppState>().refreshUserData();
      // Force rebuild to refresh current page
      setState(() {});
    }
  }

  void _onTabTapped(int index) {
    // Avoid unnecessary rebuild if tapping the same tab
    if (_currentIndex == index && _overlayPage == null) return;

    setState(() {
      _currentIndex = index;
      // Close any overlay (BucketPage, BugPage, etc.) when changing tabs
      _overlayPage = null;
    });
  }

  @override
  void showBucketPage(List<Map<String, dynamic>> bets, {VoidCallback? onBetPlaced, void Function(int index)? onBetRemoved}) {
    setState(() {
      _overlayPage = BucketPage(
        uid: widget.uid,
        bets: bets,
        onBetPlaced: onBetPlaced,
        onBetRemoved: onBetRemoved,
        onClose: () {
          setState(() {
            _overlayPage = null;
          });
        },
      );
    });
  }

  @override
  void showBugReportPage() {
    setState(() {
      _overlayPage = BugPage(
        uid: widget.uid,
        onClose: () {
          setState(() {
            _overlayPage = null;
          });
        },
      );
    });
  }

  @override
  void closeOverlay() {
    setState(() {
      _overlayPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      GamesPage(uid: widget.uid, showTutorial: widget.showTutorial),
      MyBetsPage(uid: widget.uid),
      LeaguesPage(uid: widget.uid),
      ManageAccountPage(uid: widget.uid),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use responsive breakpoints utility
        final bool isDesktop = ResponsiveBreakpoints.isDesktop(context);

        if (isDesktop) {
          // Desktop layout with sidebar
          return Scaffold(
            body: Row(
              children: [
                // Sidebar navigation
                SidebarNavigation(
                  currentIndex: _currentIndex,
                  onTabTapped: _onTabTapped,
                  uid: widget.uid,
                ),
                // Main content area
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1600),
                      child: Stack(
                        children: [
                          IndexedStack(
                            index: _currentIndex,
                            children: pages,
                          ),
                          if (_overlayPage != null)
                            _overlayPage!,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile layout with bottom navigation bar
          return Scaffold(
            body: Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: pages,
                ),
                if (_overlayPage != null)
                  _overlayPage!,
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                border: Border(
                  top: BorderSide(
                    color: AppColors.borderDark,
                    width: 1,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.surfaceDark,
                selectedItemColor: AppColors.textPrimary,
                unselectedItemColor: AppColors.textTertiary,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 0,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.sports_basketball_outlined),
                    activeIcon: Icon(
                      Icons.sports_basketball,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    label: AppLocalizations.of(context)!.title,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.history_outlined),
                    activeIcon: Icon(
                      Icons.history,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    label: AppLocalizations.of(context)!.myBets,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.people_outline),
                    activeIcon: Icon(
                      Icons.people,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    label: AppLocalizations.of(context)!.leagues,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings_outlined),
                    activeIcon: Icon(
                      Icons.settings,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    label: AppLocalizations.of(context)!.manageAccount,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
