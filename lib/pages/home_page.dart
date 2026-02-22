import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';
import 'package:hoopsleague/pages/sign_up_page.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import 'legal_document_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double logoSize = ((screenWidth * 0.35).clamp(80, 180)).toDouble();
    final double buttonWidth = ((screenWidth * 0.7).clamp(160, 300)).toDouble();
    final double buttonHeight = ((screenHeight * 0.07).clamp(45, 60)).toDouble();
    final double titleFontSize = ((screenWidth * 0.08).clamp(22, 32)).toDouble();
    final double buttonFontSize = ((screenWidth * 0.045).clamp(14, 18)).toDouble();
    final double spacing = ((screenHeight * 0.03).clamp(10, 30)).toDouble();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset("assets/images/logo_black.png", width: logoSize, height: logoSize),
                SizedBox(height: spacing),

                // Slogan
                AutoSizeText(
                  "Let's see if you know ball.",
                  maxLines: 2,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: spacing * 2),

                // Sign In Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    ),
                    icon: const Icon(Icons.login_outlined, color: Colors.white, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.signIn,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: buttonFontSize,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(height: spacing),

                // Sign Up Button
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUpPage(
                          refreshKey: DateTime.now().millisecondsSinceEpoch.toString(),
                        ),
                      ),
                    ),
                    icon: Icon(Icons.person_add_outlined, color: AppColors.primaryBlue, size: 20),
                    label: Text(
                      AppLocalizations.of(context)!.signUP,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: buttonFontSize,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.surfaceDark,
                      side: BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                SizedBox(height: spacing * 2),

                // Legal links
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/cgu.md',
                              title: AppLocalizations.of(context)!.termsAndConditions,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.termsAndConditions,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: logScale(context, 11),
                        ),
                      ),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/privacy_policy.md',
                              title: AppLocalizations.of(context)!.privacyPolicy,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.privacyPolicy,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: logScale(context, 11),
                        ),
                      ),
                    ),
                    Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentPage(
                              documentPath: 'assets/legal_docs/mentions_legales.md',
                              title: AppLocalizations.of(context)!.legalNotice,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.legalNotice,
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: logScale(context, 11),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing * 2),

                // NBA Disclaimer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Text(
                    AppLocalizations.of(context)!.nbaDisclaimer,
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: logScale(context, 10),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
