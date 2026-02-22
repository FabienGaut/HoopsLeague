import 'package:flutter/material.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/utils/responsive_utils.dart';
import '../l10n/app_localizations.dart';

class SidebarNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;
  final String uid;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.uid,
  });

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  int? _hoveredIndex;

  double _getResponsiveSidebarWidth(BuildContext context) {
    final screenWidth = ResponsiveBreakpoints.getScreenWidth(context);
    if (screenWidth >= ResponsiveBreakpoints.ultraWide) return 280;
    if (screenWidth >= ResponsiveBreakpoints.desktop) return 240;
    if (screenWidth >= ResponsiveBreakpoints.tablet) return 220;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<NavigationItem> items = [
      NavigationItem(
        icon: Icons.sports_basketball_outlined,
        activeIcon: Icons.sports_basketball,
        label: localizations.title,
        index: 0,
      ),
      NavigationItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: localizations.myBets,
        index: 1,
      ),
      NavigationItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: localizations.leagues,
        index: 2,
      ),
      NavigationItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: localizations.manageAccount,
        index: 3,
      ),
    ];

    return Container(
      width: _getResponsiveSidebarWidth(context),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          right: BorderSide(
            color: AppColors.borderDark,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - style Notion épuré
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.sports_basketball,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'HoopsLeague',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppColors.borderDark,
            height: 1,
          ),

          const SizedBox(height: 8),

          // Navigation items - style Notion
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = widget.currentIndex == item.index;
                final isHovered = _hoveredIndex == item.index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = item.index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => widget.onTabTapped(item.index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.surfaceHover
                            : isHovered
                                ? AppColors.surfaceHover.withValues(alpha: 0.5)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer - style minimaliste
          Divider(
            color: AppColors.borderDark,
            height: 1,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '© 2025 HoopsLeague',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}
