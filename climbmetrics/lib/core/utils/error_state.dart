import 'dart:developer';

class ErrorState {
  
  Enum? state;
  String? function;
  String? context;
  
  ErrorState({
    this.state,
    this.function,
    this.context
  });
  
  factory ErrorState.none({
    String? function,
    String? context}) {
    return ErrorState(
      function: function,
      context: context
    );
  }

  factory ErrorState.auth({
    required AuthError error, 
    required String function,
    required String? context}) {
    return ErrorState(
      state: error,
      function: function,
      context: context
    );
  }

  factory ErrorState.database({
    required DatabaseError error, 
    required String function, 
    required String? context}) {
    return ErrorState(
      state: error,
      function: function,
      context: context
    );
  }

  factory ErrorState.cloud({
    required CloudError error, 
    required String function, 
    required String? context}) {
    return ErrorState(
      state: error,
      function: function,
      context: context
    );
  }

  factory ErrorState.metrics({
    required MetricsError error, 
    required String function, 
    required String? context}) {
    return ErrorState(
      state: error,
      function: function,
      context: context
    );
  }

  factory ErrorState.loading() {
    return ErrorState(
      state: Transition.loading
    );
  }

  factory ErrorState.selected() {
    return ErrorState(
      state: Transition.selected
    );
  }
  
  bool isNull() {
    if (state == null) {
      return true;
    } else {
      return false;
    }
  }

  bool isLoading() {
    if (state == Transition.loading) {
      return true;
    } else {
      return false;
    }
  }

  bool isSelected() {
    if (state == Transition.selected) {
      return true;
    } else {
      return false;
    }
  }

  bool isNotNull() {
    if (state != null) {
      return true;
    } else {
      return false;
    }
  }

  void toLog() {
    log('\nState: $state\nFunction: $function\nContext: $context');
  }
}

enum AuthError {
  userNotFound,
  notLoggedIn,
  alreadyLoggedIn,
  alreadyLoggedOut,
  invalidEmail,
  invalidPassword,
  invalidCredential,
  emailAlreadyInUse,
  emailNotVerified,
  weakPassword,
  tooManyRequests,
  networkRequestFailed,
  channelError,
  exception
}

enum DatabaseError {
  notLoggedIn,
  openFailed,
  notInitialized,
  syntaxError,
  entryNotFound,
  databaseAlreadyClosed,
  userAlreadyInDatabase,
  userNotFound,
  counterNotFound,
  boulderingRouteListNotFound,
  boulderingRouteNotFound,
  boulderingWallLinkListNotFound,
  projectLibraryNotFound,
  archivedBoulderingRouteListNotFound,
  userHasNoProjectLibrary,
  emptyEntry,
  exception
}

enum CloudError {
  notLoggedIn,
  loading,
  cloudUnavailable,
  aggregrateError,
  documentIdAlreadyExists,
  timeout,
  boulderingWallListNotFound,
  boulderingWallNotFound,
  boulderingRouteNotFound,
  boulderingRouteReviewListNotFound,
  companyNotFound,
  exception
}

enum MetricsError {
  boulderingWallListEmpty
}

enum Transition {
  selected,
  loading
}