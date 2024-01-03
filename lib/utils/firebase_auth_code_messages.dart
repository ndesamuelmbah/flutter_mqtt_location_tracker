String getFirebaseAuthCodeMessage(String code) {
  String errorMessage;
  if (code.contains('user-not-found')) {
    errorMessage = 'Account with the provided credentials does not exist';
  } else if (code.contains('expired-action-code')) {
    errorMessage = 'The action code has expired';
  } else if (code.contains('operation-not-allowed')) {
    errorMessage = 'Operation not allowed';
  } else if (code.contains('user-disabled')) {
    errorMessage = 'User account has been disabled';
  } else if (code.contains('invalid-action-code')) {
    errorMessage = 'Invalid action code';
  } else if (code.contains('email-already-in-use')) {
    errorMessage = 'Email is already in use';
  } else if (code.contains('invalid-credential')) {
    errorMessage =
        'Invalid credential. Could not find an account with the provided credentials';
  } else if (code.contains('invalid-verification-code')) {
    errorMessage = 'Invalid verification code';
  } else if (code.contains('invalid-custom-token')) {
    errorMessage = 'Invalid custom token';
  } else if (code.contains('invalid-verification-id')) {
    errorMessage = 'Invalid verification ID';
  } else if (code.contains('custom-token-mismatch')) {
    errorMessage = 'Custom token mismatch';
  } else if (code.contains('account-exists-with-different-credential')) {
    errorMessage = 'An account already exists with a different credential';
  } else if (code.contains('wrong-password')) {
    errorMessage = 'Wrong password';
  } else if (code.contains('invalid-email')) {
    errorMessage = 'Invalid email';
  } else if (code.contains('weak-password')) {
    errorMessage =
        'Weak password, enter a strong password of 6 or more characters';
  } else {
    errorMessage = 'An error occurred';
  }
  return errorMessage;
}
