import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import 'legal_document_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          t.about,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App info card
              _buildCard(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Image.asset('assets/images/logo_black.png', height: 80),
                    const SizedBox(height: 16),
                    Text(
                      'HoopsLeague',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: logScale(context, 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: logScale(context, 14),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.appDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: logScale(context, 14),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Legal section
              _sectionHeader(Icons.gavel_outlined, t.legalInformation),
              _buildCard(
                child: Column(
                  children: [
                    _buildLinkTile(
                      context,
                      icon: Icons.description_outlined,
                      title: t.termsAndConditions,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalDocumentPage(
                            documentPath: 'assets/legal_docs/cgu.md',
                            title: t.termsAndConditions,
                          ),
                        ),
                      ),
                    ),
                    Divider(color: AppColors.borderDark, height: 1),
                    _buildLinkTile(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: t.privacyPolicy,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalDocumentPage(
                            documentPath: 'assets/legal_docs/privacy_policy.md',
                            title: t.privacyPolicy,
                          ),
                        ),
                      ),
                    ),
                    Divider(color: AppColors.borderDark, height: 1),
                    _buildLinkTile(
                      context,
                      icon: Icons.business_outlined,
                      title: t.legalNotice,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LegalDocumentPage(
                            documentPath: 'assets/legal_docs/mentions_legales.md',
                            title: t.legalNotice,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Credits section
              _sectionHeader(Icons.favorite_outline, t.credits),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Twemoji credit
                          _buildCreditItem(
                            context,
                            title: 'Twemoji',
                            description: t.twemojiCredit,
                            url: 'https://twemoji.twitter.com/',
                            onTap: () => _launchUrl('https://twemoji.twitter.com/'),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.borderDark, height: 1),
                          const SizedBox(height: 16),
                          // Noto Color Emoji credit
                          _buildCreditItem(
                            context,
                            title: 'Noto Color Emoji',
                            description: t.notoEmojiCredit,
                            url: 'https://fonts.google.com/noto/specimen/Noto+Color+Emoji',
                            onTap: () => _launchUrl('https://fonts.google.com/noto/specimen/Noto+Color+Emoji'),
                          ),
                          const SizedBox(height: 16),
                          Divider(color: AppColors.borderDark, height: 1),
                          const SizedBox(height: 16),
                          // Flutter credit
                          _buildCreditItem(
                            context,
                            title: 'Flutter',
                            description: t.flutterCredit,
                            url: 'https://flutter.dev/',
                            onTap: () => _launchUrl('https://flutter.dev/'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // NBA Disclaimer
              _sectionHeader(Icons.sports_basketball_outlined, 'NBA'),
              _buildCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    t.nbaDisclaimer,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: logScale(context, 13),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Copyright
              Center(
                child: Text(
                  '© 2025 HoopsLeague. ${t.allRightsReserved}',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: logScale(context, 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _buildLinkTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: logScale(context, 15),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildCreditItem(BuildContext context, {required String title, required String description, required String url, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: logScale(context, 15),
                ),
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tagBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, size: 14, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Site',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: logScale(context, 12),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: logScale(context, 13),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
