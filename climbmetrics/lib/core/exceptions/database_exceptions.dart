//  Database exceptions
class EmailFieldRequiredException implements Exception {
  
  @override
  String toString() => 'EmailFieldRequiredException: Email is required for the model.';
}

class UserAlreadyInDatabaseException implements Exception {
  
  @override
  String toString() => 'UserAlreadyInDatabaseException: The user is already in the database.';
}

class DatabaseAlreadyClosedException implements Exception {
  
  @override
  String toString() => 'DatabaseAlreadyClosedException: The .closeDatabase method was called on a null _database';
}

class EntryNotFoundException implements Exception {
  
  @override
  String toString() => 'EntryNotFoundException: The entry queried does not exist in the database';
}