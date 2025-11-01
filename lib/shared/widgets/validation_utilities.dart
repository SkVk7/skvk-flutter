/// Validation Utilities
///
/// Common validation functions that can be used across all forms
/// to ensure consistent validation logic
library;

/// Generic validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
  });

  static const ValidationResult valid = ValidationResult(isValid: true);
}

/// Common validation functions
class ValidationUtils {
  /// Validate required field
  static ValidationResult validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName is required',
      );
    }
    return ValidationResult.valid;
  }

  /// Validate minimum length
  static ValidationResult validateMinLength(String value, int minLength, String fieldName) {
    if (value.trim().length < minLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be at least $minLength characters',
      );
    }
    return ValidationResult.valid;
  }

  /// Validate maximum length
  static ValidationResult validateMaxLength(String value, int maxLength, String fieldName) {
    if (value.trim().length > maxLength) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be less than $maxLength characters',
      );
    }
    return ValidationResult.valid;
  }

  /// Validate email format
  static ValidationResult validateEmail(String email) {
    if (email.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Email is required',
      );
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid email address',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate phone number
  static ValidationResult validatePhoneNumber(String phone) {
    if (phone.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Phone number is required',
      );
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(phone.trim().replaceAll(' ', '').replaceAll('-', ''))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid phone number',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate date of birth
  static ValidationResult validateDateOfBirth(DateTime dateOfBirth) {
    final now = DateTime.now();
    final minDate = DateTime(1900);
    final maxDate = now.subtract(const Duration(days: 1));

    if (dateOfBirth.isBefore(minDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Date of birth cannot be before 1900',
      );
    }

    if (dateOfBirth.isAfter(maxDate)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Date of birth cannot be in the future',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate age range
  static ValidationResult validateAgeRange(DateTime dateOfBirth, int minAge, int maxAge) {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    
    if (age < minAge) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Age must be at least $minAge years',
      );
    }

    if (age > maxAge) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Age must be less than $maxAge years',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate coordinates
  static ValidationResult validateLatitude(double latitude) {
    if (latitude < -90 || latitude > 90) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Latitude must be between -90 and 90',
      );
    }
    return ValidationResult.valid;
  }

  /// Validate longitude
  static ValidationResult validateLongitude(double longitude) {
    if (longitude < -180 || longitude > 180) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Longitude must be between -180 and 180',
      );
    }
    return ValidationResult.valid;
  }

  /// Validate coordinates together
  static ValidationResult validateCoordinates(double latitude, double longitude) {
    final latResult = validateLatitude(latitude);
    if (!latResult.isValid) return latResult;

    final lngResult = validateLongitude(longitude);
    if (!lngResult.isValid) return lngResult;

    if (latitude == 0.0 && longitude == 0.0) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please select a valid location',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate name (first name, last name, etc.)
  static ValidationResult validateName(String name, String fieldName) {
    final requiredResult = validateRequired(name, fieldName);
    if (!requiredResult.isValid) return requiredResult;

    final minLengthResult = validateMinLength(name, 2, fieldName);
    if (!minLengthResult.isValid) return minLengthResult;

    final maxLengthResult = validateMaxLength(name, 50, fieldName);
    if (!maxLengthResult.isValid) return maxLengthResult;

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(name.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName can only contain letters, spaces, hyphens, and apostrophes',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate place name
  static ValidationResult validatePlaceName(String placeName) {
    final requiredResult = validateRequired(placeName, 'Place name');
    if (!requiredResult.isValid) return requiredResult;

    final minLengthResult = validateMinLength(placeName, 2, 'Place name');
    if (!minLengthResult.isValid) return minLengthResult;

    final maxLengthResult = validateMaxLength(placeName, 100, 'Place name');
    if (!maxLengthResult.isValid) return maxLengthResult;

    return ValidationResult.valid;
  }

  /// Validate password
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password is required',
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must be at least 8 characters',
      );
    }

    if (password.length > 128) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must be less than 128 characters',
      );
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one uppercase letter',
      );
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one lowercase letter',
      );
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one number',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate confirm password
  static ValidationResult validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please confirm your password',
      );
    }

    if (password != confirmPassword) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Passwords do not match',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate URL
  static ValidationResult validateUrl(String url) {
    if (url.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'URL is required',
      );
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(url.trim())) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Please enter a valid URL',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate numeric range
  static ValidationResult validateNumericRange(
    String value,
    double min,
    double max,
    String fieldName,
  ) {
    if (value.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName is required',
      );
    }

    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be a valid number',
      );
    }

    if (numericValue < min || numericValue > max) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be between $min and $max',
      );
    }

    return ValidationResult.valid;
  }

  /// Validate integer range
  static ValidationResult validateIntegerRange(
    String value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName is required',
      );
    }

    final intValue = int.tryParse(value.trim());
    if (intValue == null) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be a valid integer',
      );
    }

    if (intValue < min || intValue > max) {
      return ValidationResult(
        isValid: false,
        errorMessage: '$fieldName must be between $min and $max',
      );
    }

    return ValidationResult.valid;
  }
}

/// Form validation mixin for easy validation in forms
mixin FormValidationMixin<T> {
  final Map<T, String> _fieldErrors = {};

  /// Get field error
  String? getFieldError(T field) => _fieldErrors[field];

  /// Set field error
  void setFieldError(T field, String error) {
    _fieldErrors[field] = error;
  }

  /// Clear field error
  void clearFieldError(T field) {
    _fieldErrors.remove(field);
  }

  /// Clear all field errors
  void clearAllErrors() {
    _fieldErrors.clear();
  }

  /// Check if form has errors
  bool get hasErrors => _fieldErrors.isNotEmpty;

  /// Get all errors
  Map<T, String> get allErrors => Map.unmodifiable(_fieldErrors);

  /// Validate field with custom validator
  bool validateField(T field, ValidationResult Function() validator) {
    final result = validator();
    if (result.isValid) {
      clearFieldError(field);
      return true;
    } else {
      setFieldError(field, result.errorMessage ?? 'Invalid value');
      return false;
    }
  }

  /// Validate required field
  bool validateRequiredField(T field, String? value, String fieldName) {
    return validateField(field, () => ValidationUtils.validateRequired(value, fieldName));
  }

  /// Validate name field
  bool validateNameField(T field, String name, String fieldName) {
    return validateField(field, () => ValidationUtils.validateName(name, fieldName));
  }

  /// Validate email field
  bool validateEmailField(T field, String email) {
    return validateField(field, () => ValidationUtils.validateEmail(email));
  }

  /// Validate phone field
  bool validatePhoneField(T field, String phone) {
    return validateField(field, () => ValidationUtils.validatePhoneNumber(phone));
  }

  /// Validate date of birth field
  bool validateDateOfBirthField(T field, DateTime dateOfBirth) {
    return validateField(field, () => ValidationUtils.validateDateOfBirth(dateOfBirth));
  }

  /// Validate coordinates field
  bool validateCoordinatesField(T field, double latitude, double longitude) {
    return validateField(field, () => ValidationUtils.validateCoordinates(latitude, longitude));
  }
}
