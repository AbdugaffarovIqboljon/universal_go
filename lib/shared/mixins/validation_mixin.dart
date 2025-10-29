import '../extensions/string_extension.dart';

mixin ValidationMixin {
  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.isValidEmail) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.isValidPassword) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }
  
  // Confirm password validation
  String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  // Phone validation
 String? validateUzbekPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all spaces and special characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (!cleanPhone.startsWith('+998')) {
      return 'Phone must start with +998';
    }
    
    if (cleanPhone.length != 13) {
      return 'Phone number must be 13 digits (+998 XX XXX XX XX)';
    }
    
    if (!cleanPhone.isValidUzbekPhone) {
      return 'Please enter a valid Uzbek phone number';
    }
    
    return null;
  }
  
  // Name validation
  String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    return null;
  }
  
  // Required field validation
  String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Number validation
  String? validateNumber(String? value, {String fieldName = 'Number'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
  
  // Positive number validation
  String? validatePositiveNumber(String? value, {String fieldName = 'Number'}) {
    final numberValidation = validateNumber(value, fieldName: fieldName);
    if (numberValidation != null) return numberValidation;
    
    final number = double.tryParse(value!);
    if (number != null && number <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
}
