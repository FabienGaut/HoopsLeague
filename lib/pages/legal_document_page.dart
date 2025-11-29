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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          
          // Content
          SafeArea(
            child: FutureBuilder<String>(
              future: rootBundle.loadString(documentPath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF256af4),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading document: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                
                return Markdown(
                  data: snapshot.data ?? '',
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.6,
                    ),
                    h1: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 2,
                    ),
                    h2: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                    h3: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                    listBullet: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    strong: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    em: const TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    blockquote: TextStyle(
                      color: Colors.white70,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                    code: TextStyle(
                      color: Color(0xFF9C9CFF),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      fontFamily: 'monospace',
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
