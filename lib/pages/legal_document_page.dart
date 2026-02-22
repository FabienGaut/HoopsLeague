import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../theme/app_colors.dart';

class LegalDocumentPage extends StatelessWidget {
  final String documentPath;
  final String title;

  const LegalDocumentPage({
    super.key,
    required this.documentPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
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
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString(documentPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tagRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.error, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error loading document: ${snapshot.error}',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Markdown(
                data: snapshot.data ?? '',
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  h1: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 2,
                  ),
                  h2: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                  h3: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.6,
                  ),
                  listBullet: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  strong: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  em: TextStyle(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  blockquote: TextStyle(
                    color: AppColors.textSecondary,
                    backgroundColor: AppColors.surfaceHover,
                  ),
                  code: TextStyle(
                    color: AppColors.primaryBlue,
                    backgroundColor: AppColors.tagBlue,
                    fontFamily: 'monospace',
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
            );
          },
        ),
      ),
    );
  }
}
