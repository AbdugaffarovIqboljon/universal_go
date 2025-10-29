
extension StringExtension on String {
  // Validation
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
 bool get isValidUzbekPhone {
    // Remove spaces and special chars
    final clean = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Must start with +998 and have 13 digits total
    // Format: +998 XX XXX XX XX (where X is digit)
    final uzbekPhoneRegex = RegExp(r'^\+998[0-9]{9}$');
    return uzbekPhoneRegex.hasMatch(clean);
  }
  
  bool get isValidPassword {
    return length >= 8 && 
           RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(this);
  }
  
  // Text formatting
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  // Trimming and cleaning
  String get trimAndLower => trim().toLowerCase();
  String get trimAndUpper => trim().toUpperCase();
  
  // Null safety
  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => isNotEmpty;
  
  // Phone number formatting
  String get formatPhoneNumber {
    if (length < 10) return this;
    return '${substring(0, 3)}-${substring(3, 6)}-${substring(6)}';
  }
  
  // Currency formatting (for UZS)
  String get formatCurrency {
    if (isEmpty) return '0 UZS';
    final number = double.tryParse(this) ?? 0;
    return '${number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    )} UZS';
  }
}
