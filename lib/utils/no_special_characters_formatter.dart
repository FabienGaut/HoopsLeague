import 'package:flutter/services.dart';

/// Enhanced InputFormatter that blocks dangerous characters and SQL keywords
/// 
/// Blocks:
/// - Special characters: " ' { } ( ) [ ] , ; = < >
/// - SQL keywords: SELECT, DROP, INSERT, UPDATE, DELETE, UNION, etc.
/// - Control characters and zero-width characters
/// - Optionally enforces maximum length
class NoSpecialCharactersFormatter extends TextInputFormatter {
  final int? maxLength;
  
  NoSpecialCharactersFormatter({this.maxLength});
  
  // Block dangerous characters and SQL keywords (case-insensitive)
  static final RegExp _forbiddenChars = RegExp(
    r'''["'{}()\[\],;=<>]|SELECT|DROP|INSERT|UPDATE|DELETE|UNION|ALTER|CREATE|TRUNCATE|EXEC|SCRIPT''',
    caseSensitive: false,
  );
  
  // Block zero-width and control characters
  static final RegExp _controlChars = RegExp(
    r'[\u0000-\u001F\u007F-\u009F\u200B-\u200D\uFEFF]'
  );
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Check length limit
    if (maxLength != null && newValue.text.length > maxLength!) {
      return oldValue;
    }
    
    // Check for forbidden characters or SQL keywords
    if (_forbiddenChars.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // Check for control characters
    if (_controlChars.hasMatch(newValue.text)) {
      return oldValue;
    }
    
    // Accept the new value
    return newValue;
  }
}
