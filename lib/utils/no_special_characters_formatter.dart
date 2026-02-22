import 'package:flutter/services.dart';

class NoSpecialCharactersFormatter extends TextInputFormatter {
  final int? maxLength;

  NoSpecialCharactersFormatter({this.maxLength});

  static final RegExp _forbiddenChars = RegExp(
    r'''["'{}()\[\],;=<>]|SELECT|DROP|INSERT|UPDATE|DELETE|UNION|ALTER|CREATE|TRUNCATE|EXEC|SCRIPT''',
    caseSensitive: false,
  );

  static final RegExp _controlChars = RegExp(
    r'[\u0000-\u001F\u007F-\u009F\u200B-\u200D\uFEFF]'
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null && newValue.text.length > maxLength!) {
      return oldValue;
    }

    if (_forbiddenChars.hasMatch(newValue.text)) {
      return oldValue;
    }

    if (_controlChars.hasMatch(newValue.text)) {
      return oldValue;
    }

    return newValue;
  }
}
