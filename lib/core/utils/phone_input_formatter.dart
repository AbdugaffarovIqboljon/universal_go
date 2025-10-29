import 'package:flutter/services.dart';

class UzbekPhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Always keep +998 prefix
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '+998 ',
        selection: TextSelection.collapsed(offset: 5),
      );
    }
    
    // Don't allow removing +998
    if (!text.startsWith('+998')) {
      return oldValue;
    }
    
    // Remove all non-digits except +
    final digitsOnly = text.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Build formatted string: +998 XX XXX XX XX
    final buffer = StringBuffer('+998');
    final digits = digitsOnly.substring(4); // Remove +998
    
    if (digits.isNotEmpty) {
      buffer.write(' ');
      buffer.write(digits.substring(0, digits.length > 2 ? 2 : digits.length));
    }
    
    if (digits.length > 2) {
      buffer.write(' ');
      buffer.write(digits.substring(2, digits.length > 5 ? 5 : digits.length));
    }
    
    if (digits.length > 5) {
      buffer.write(' ');
      buffer.write(digits.substring(5, digits.length > 7 ? 7 : digits.length));
    }
    
    if (digits.length > 7) {
      buffer.write(' ');
      buffer.write(digits.substring(7, digits.length > 9 ? 9 : digits.length));
    }
    
    final formatted = buffer.toString();
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}