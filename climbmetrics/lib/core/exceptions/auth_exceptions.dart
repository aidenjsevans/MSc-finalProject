// Authentication exceptions
class AlreadyLoggedInException implements Exception {
  
  @override
  String toString() => 'AlreadyLoggedInException: User is already logged in.';
}

class AlreadyLoggedOutException implements Exception {
    
  @override
  String toString() => 'AlreadyLoggedOutException: User is already logged out.';
}

class NotLoggedInException implements Exception {

  @override
  String toString() => 'NotLoggedInException: User is not logged in.';
}

class EmptyEntryException implements Exception {

  @override
  String toString() => 'EmptyEntryException: No text entry values were given.';
}

class AuthNotInitializedException implements Exception {

  @override
  String toString() => 'AuthNotInitializedException: Authentication provider has not initialized.';
}

class InvalidEmailException implements Exception {

  @override
  String toString() => 'InvalidEmailException: Incorrect email provided';
}

class InvalidPasswordException implements Exception {

  @override
  String toString() => 'WrongPasswordException: Incorrect password provided';
}

class InvalidCredentialException implements Exception {

  @override
  String toString() => 'InvalidCredentialException: Incorrect credential provided';
}

class WeakPasswordException implements Exception {

  @override
  String toString() => 'WeakPasswordException: Weak password provided';
}

class EmailAlreadyInUseException implements Exception {

  @override
  String toString() => 'EmailAlreadyInUseException: Email provided already in use';
}

class EmailNotVerifiedException implements Exception {

    @override
    String toString() => 'EmailNotVerifiedException: Email provided has not been verified';
  }

class GenericAuthException implements Exception {
  
  @override
  String toString() => 'GenericAuthException';
}

class ChannelErrorException implements Exception {
  
  @override
  String toString() => 'ChannelErrorException';
}


