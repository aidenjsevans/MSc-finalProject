import 'dart:developer';

import 'package:climbmetrics/core/utils/error_state.dart';

import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:climbmetrics/viewmodels/auth/auth_state.dart';
import 'package:climbmetrics/viewmodels/auth/login/login_notifier.dart';
import 'package:climbmetrics/viewmodels/auth/register/register_notifier.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [FirebaseAuthNotifier] provides various methods that can change its [state], which is of the 
/// type [AuthState]. It takes the [FirebaseAuthService], [LoginNotifier], and [RegisterNotifier] as constructor
/// arguments
class FirebaseAuthNotifier extends StateNotifier<AuthState> {
  
  final FirebaseAuthService _firebaseAuthService;
  final LoginNotifier _loginNotifier;
  final RegisterNotifier _registerNotifier;

  FirebaseAuthNotifier(
    this._firebaseAuthService,
    this._loginNotifier,
    this._registerNotifier
    ) : super(AuthState.initializing);

/// Calls the [initializeFA] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState] 
  Future<void> initializeFA() async {
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await _firebaseAuthService.initializeFA();
    initErrorState.toLog();
    if (initErrorState.state == AuthError.exception) {
      state = AuthState.error;
      return;
    }
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    userErrorState.toLog();
    if (firebaseUser != null && !firebaseUser.emailVerified) {
      state = AuthState.emailNotVerified;
    } else if (firebaseUser != null) {
      state = AuthState.loggedIn;
    } else {
      state = AuthState.loggedOut;
    }
    log('\n$state');
  }

/// Calls the [login] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState]
/// 
/// Returns an [ErrorState]
  Future<ErrorState> login(String email, String password) async {
    ErrorState loginErrorState = await _firebaseAuthService.login(email, password);
   
    switch (loginErrorState.state) {
      case null:
      state = AuthState.loggedIn;
      break;      
      case AuthError.userNotFound:
      state = AuthState.loggedOut;
      break;
      case AuthError.emailNotVerified:
      state = AuthState.emailNotVerified;
      break;
      case AuthError.invalidEmail:
      state = AuthState.loggedOut;
      break;
      case AuthError.invalidPassword:
      state = AuthState.loggedOut;
      break;
      case AuthError.tooManyRequests:
      state = AuthState.loggedOut;
      break;
      case AuthError.networkRequestFailed:
      state = AuthState.loggedOut;
      break;
      case AuthError.alreadyLoggedIn:
      state = AuthState.loggedIn;
      break;    
      case AuthError.exception:
      state = AuthState.error;
      break;
    }

    loginErrorState.toLog();
    return loginErrorState;
  }

/// Calls the [register] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState]
/// 
/// Returns an [ErrorState]
  Future<ErrorState> register(String email, String password) async {
    ErrorState registerErrorState = await _firebaseAuthService.register(email, password);
    
    switch (registerErrorState.state) {
      case null:
      state = AuthState.emailNotVerified;
      break;
      case AuthError.emailAlreadyInUse:
      state = AuthState.loggedOut;
      break;
      case AuthError.invalidEmail:
      state = AuthState.loggedOut;
      break;
      case AuthError.weakPassword:
      state = AuthState.loggedOut;
      break;
      case AuthError.tooManyRequests:
      state = AuthState.loggedOut;
      break;
      case AuthError.networkRequestFailed:
      state = AuthState.loggedOut;
      break;
      case AuthError.alreadyLoggedIn:
      state = AuthState.loggedIn;
      break;
      case AuthError.channelError:
      state = AuthState.loggedOut;
      break;
      case AuthError.exception:
      state = AuthState.error;
      break;
    }
    
    registerErrorState.toLog();
    return registerErrorState;
  }

/// Calls the [logout] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState]
  Future<void> logout() async {
    ErrorState logoutErrorState = await _firebaseAuthService.logout();
    switch (logoutErrorState.state) {
      case null:
      state = AuthState.loggedOut;
      break;
      case AuthError.alreadyLoggedOut:
      state = AuthState.loggedOut;
      break;
      case AuthError.exception:
      state = AuthState.error;
      break;
    }
    logoutErrorState.toLog();
    log('\n$state');
    _loginNotifier.setState(ErrorState.none());
    _registerNotifier.setState(ErrorState.none());
  }

/// Calls the [sendEmailVerification] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState]
  Future<void> sendEmailVerification() async {
    ErrorState emailErrorState = await _firebaseAuthService.sendEmailVerification();
    switch (emailErrorState.state) {
      case null:
      state = AuthState.emailNotVerified;
      break;
      case AuthError.userNotFound:
      state = AuthState.loggedOut;
      case AuthError.notLoggedIn:
      state = AuthState.loggedOut;
      break;
      case AuthError.exception:
      state = AuthState.error;
      break;
    }
  }

/// Calls the [reload] method from the [FirebaseAuthService] and changes the internal [state] of the [FirebaseAuthNotifier]
/// depending on the [ErrorState]
  Future<void> reload() async {
    ErrorState reloadErrorState = await _firebaseAuthService.reload();
    switch (reloadErrorState.state) {
      case null:
      final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        state = AuthState.emailNotVerified;
      } else if (firebaseUser != null) {
        state = AuthState.emailNotVerified;
      } else {
        state = AuthState.loggedOut;
      }
      break;
      case AuthError.notLoggedIn:
      state = AuthState.loggedOut;
      break;
      case AuthError.exception:
      state = AuthState.error;
      return;
    }
  }
}