class ValidationResult {
  const ValidationResult({
    required this.isValid,
    this.errors = const {},
  });

  final bool isValid;
  final Map<String, String> errors;

  static const valid = ValidationResult(isValid: true);

  static ValidationResult failure(Map<String, String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
}

class Validators {
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp _isbnRegex = RegExp(r'^(?:\d[\ |-]?){9,12}[\d|X]$');

  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isValidPassword(String? password) {
    if (password == null || password.length < 6) return false;
    return true;
  }

  static bool isValidName(String? name) {
    if (name == null || name.trim().length < 2) return false;
    return true;
  }

  static bool isValidIsbn(String? isbn) {
    if (isbn == null || isbn.trim().isEmpty) return false;
    return _isbnRegex.hasMatch(isbn.trim());
  }

  static ValidationResult validateRegister({
    required String? name,
    required String? email,
    required String? password,
  }) {
    final errors = <String, String>{};

    if (!isValidName(name)) {
      errors['name'] = 'Name must be at least 2 characters long.';
    }
    if (!isValidEmail(email)) {
      errors['email'] = 'A valid email address is required.';
    }
    if (!isValidPassword(password)) {
      errors['password'] = 'Password must be at least 6 characters long.';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateLogin({
    required String? email,
    required String? password,
  }) {
    final errors = <String, String>{};

    if (!isValidEmail(email)) {
      errors['email'] = 'A valid email address is required.';
    }
    if (password == null || password.isEmpty) {
      errors['password'] = 'Password is required.';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }
    return ValidationResult.valid;
  }

  static ValidationResult validateBook({
    required String? title,
    required String? author,
    required String? category,
    required String? isbn,
    required int? quantity,
  }) {
    final errors = <String, String>{};

    if (title == null || title.trim().isEmpty) {
      errors['title'] = 'Title is required.';
    }
    if (author == null || author.trim().isEmpty) {
      errors['author'] = 'Author is required.';
    }
    if (category == null || category.trim().isEmpty) {
      errors['category'] = 'Category is required.';
    }
    if (!isValidIsbn(isbn)) {
      errors['isbn'] = 'A valid ISBN (10 or 13 digits) is required.';
    }
    if (quantity == null || quantity < 1) {
      errors['quantity'] = 'Quantity must be at least 1.';
    }

    if (errors.isNotEmpty) {
      return ValidationResult.failure(errors);
    }
    return ValidationResult.valid;
  }
}
