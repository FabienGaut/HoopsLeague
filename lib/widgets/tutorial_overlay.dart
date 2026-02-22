import 'package:flutter/material.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/theme/utils.dart';
import '../l10n/app_localizations.dart';

/// Tutorial overlay that guides new users through the app features
class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  void _skipTutorial() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: Stack(
        children: [
          // Skip button
          Positioned(
            top: 50,
            right: 16,
            child: TextButton(
              onPressed: _skipTutorial,
              child: Text(
                AppLocalizations.of(context)!.skip,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logScale(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Tutorial content based on current step
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),

          // Navigation buttons
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step indicator
                Text(
                  '${_currentStep + 1} / $_totalSteps',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: logScale(context, 14),
                  ),
                ),
                // Next button
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _currentStep < _totalSteps - 1
                        ? AppLocalizations.of(context)!.next
                        : AppLocalizations.of(context)!.finish,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: logScale(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTutorialCard(
          icon: Icons.touch_app,
          title: AppLocalizations.of(context)!.tutorialStatsTitle,
          description: AppLocalizations.of(context)!.tutorialStatsDesc,
        );
      case 1:
        return _buildTutorialCard(
          icon: Icons.swipe,
          title: AppLocalizations.of(context)!.tutorialSwipeTitle,
          description: AppLocalizations.of(context)!.tutorialSwipeDesc,
        );
      case 2:
        return _buildTutorialCard(
          icon: Icons.bar_chart,
          title: AppLocalizations.of(context)!.tutorialOddsTitle,
          description: AppLocalizations.of(context)!.tutorialOddsDesc,
        );
      case 3:
        return _buildTutorialCard(
          icon: Icons.card_giftcard,
          title: AppLocalizations.of(context)!.tutorialDailyPointsTitle,
          description: AppLocalizations.of(context)!.tutorialDailyPointsDesc,
        );
      case 4:
        return _buildTutorialCard(
          icon: Icons.people,
          title: AppLocalizations.of(context)!.tutorialLeaguesTitle,
          description: AppLocalizations.of(context)!.tutorialLeaguesDesc,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTutorialCard({
    required IconData icon,
    required String title,
    required String description,
    String? imageAsset,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: logScale(context, 24),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: logScale(context, 16),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Optional image
          if (imageAsset != null) ...[
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
