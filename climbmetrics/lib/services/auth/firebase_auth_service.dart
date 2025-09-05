 
import 'package:climbmetrics/core/utils/error_state.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException, User, UserCredential;
import 'package:firebase_core/firebase_core.dart';

/// The [FirebaseAuthService] provides various methods for authentication. 
/// It takes the [FirebaseApp] and [FirebaseAuth] as constructor arguments so it can
/// use their services
class FirebaseAuthService {

  FirebaseApp? _firebaseApp;
  FirebaseAuth? _auth;

  FirebaseAuthService({
    FirebaseApp? firebaseApp,
    FirebaseAuth? auth
  }) : 
  _firebaseApp = firebaseApp,
  _auth = auth;

//  UTILITY---------------------------------------------------------------------------------
  
/// Connects the [FirebaseAuthService] to the [FirebaseApp] and [FirebaseAuth] instances
/// 
/// Returns the [FirebaseApp], [FirebaseAuth], and [ErrorState]. If an error occurs, the returned
/// [FirebaseApp] and [FirebaseAuth] are null
  Future<(ErrorState,FirebaseApp?,FirebaseAuth?)> initializeFA() async {
    
    const String function = 'FirebaseAuthService.initialize()';
    try {
      
      if (_firebaseApp == null) {
        final FirebaseApp firebaseApp = await Firebase.initializeApp();
        _firebaseApp = firebaseApp;
      }

      if (_auth == null) {
        final FirebaseAuth auth = FirebaseAuth.instance;
        _auth = auth;
      }

      return(ErrorState.none(function: function), _firebaseApp, _auth);

    } on FirebaseException catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: '${e.code}\n\n${e.toString()}'
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);      
    }
  }

/// Getter for the [FirebaseApp] and [FirebaseAuth] instances
/// 
/// If both instances already exist, the method will return them alongiside an [ErrorState], 
/// otherwise the method will call [initializeFA]
  Future<(ErrorState,FirebaseApp?,FirebaseAuth?)> get firebase async {
    const String function = 'FirebaseAuthService get() firebase';
    if (_firebaseApp == null || _auth == null) {
      return await initializeFA();
    } else {
    return (ErrorState.none(function: function), _firebaseApp!, _auth!);
    }
  }

/// Getter for the current session [User]
/// 
/// Returns the [User] alongside and [ErrorState]. If an error occurs, the returned
/// [User] is null
  Future<(ErrorState,User?)> get user async {
    const String function = 'FirebaseAuthService get() user';
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }
    User? firebaseUser = _auth!.currentUser;
    return (ErrorState.none(function: function), firebaseUser);
  }

/// Reloads the current session
/// 
/// Returns an [ErrorState]
  Future<ErrorState> reload() async {
    const String function = 'FirebaseAuthService.reload()';
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    if (initErrorState.isNotNull()) {
      return initErrorState;     
    }
    final (ErrorState userErrorState, User? firebaseUser) = await user;   
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    try {
      if (firebaseUser != null) {
        await firebaseUser.reload();
        return ErrorState.none(function: function);
      } else {
        final reloadErrorState = ErrorState.auth(
          error: AuthError.notLoggedIn,
          function: function, 
          context: null
        );
        return reloadErrorState;
      }
    } on FirebaseAuthException catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: '${e.code}\n\n${e.toString()}'
      );
      exceptionErrorState.toLog();
      return exceptionErrorState; 
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;  
    }
  }

//------------------------------------------------------------------------------------------


//    LOGIN---------------------------------------------------------------------------------

/// Attempts to login a user, taking an [email] and [password] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> login(String email, String password) async {
    const String function = 'FirebaseAuthService.login()';
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    final (ErrorState userErrorState, User? firebaseUser) = await user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      try {
        final UserCredential credential = await auth!.signInWithEmailAndPassword(email: email, password: password);
        final signedInFirebaseUser = credential.user;
        if (signedInFirebaseUser == null) {
          final loginErrorState = ErrorState.auth(
            error: AuthError.userNotFound, 
            function: function, 
            context: 'Email: $email'
          );
          return loginErrorState;              
        }
        await signedInFirebaseUser.reload();
        final reloadedFirebaseUser = auth.currentUser;     
        if (!reloadedFirebaseUser!.emailVerified) {
          final loginErrorState = ErrorState.auth(
            error: AuthError.emailNotVerified, 
            function: function, 
            context: 'User ID: ${signedInFirebaseUser.uid}, Email: ${signedInFirebaseUser.email}'
          );
          return loginErrorState;
        } 
        return ErrorState.none(function: function);
      } on FirebaseException catch (e) {
        switch (e.code) {
          case 'invalid-email':
          final loginErrorState = ErrorState.auth(
            error: AuthError.invalidEmail, 
            function: function, 
            context: 'Email: $email'
          );
          return loginErrorState;
          case 'user-not-found':
          final loginErrorState = ErrorState.auth(
            error: AuthError.userNotFound, 
            function: function, 
            context: 'Email: $email'
          );
          return loginErrorState;              
          case 'wrong-password':
          final loginErrorState = ErrorState.auth(
            error: AuthError.invalidPassword, 
            function: function, 
            context: null
          );
          return loginErrorState;
          case 'too-many-requests':
          final loginErrorState = ErrorState.auth(
            error: AuthError.tooManyRequests, 
            function: function, 
            context: null
          );              
          return loginErrorState;
          case 'invalid-credential':
          final loginErrorState = ErrorState.auth(
            error: AuthError.invalidCredential, 
            function: function, 
            context: 'Email: $email'
          );
          return loginErrorState;
          case 'network-request-failed':
          final loginErrorState = ErrorState.auth(
            error: AuthError.networkRequestFailed, 
            function: function, 
            context: null
          );
          return loginErrorState;
          case 'channel-error':
          final loginErrorState = ErrorState.auth(
            error: AuthError.channelError, 
            function: function, 
            context: null
          );
          return loginErrorState;              
          default:
          final exceptionErrorState = ErrorState.auth(
            error: AuthError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;                         
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.auth(
          error: AuthError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } else {
      final loginErrorState = ErrorState.auth(
        error: AuthError.alreadyLoggedIn, 
        function: function, 
        context: 'User ID: ${firebaseUser.uid}, Email: $email'
      );
      return loginErrorState;
    }
  }

/// Attemps to logout a user
/// 
/// Returns an [ErrorState]
  Future<ErrorState> logout() async {
    const String function = 'FirebaseAuthService.logout()';
    
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    final (ErrorState userErrorState, User? firebaseUser) = await user;
    if (userErrorState.isNotNull()) {
      return initErrorState;
    }
    try {
      if (firebaseUser != null) {
        await auth!.signOut();
        return ErrorState.none(function: function);
      } else {
        final logoutErrorState = ErrorState.auth(
          error: AuthError.alreadyLoggedOut, 
          function: function, 
          context: null
        );
        return logoutErrorState;
      }
    } on FirebaseAuthException catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: '${e.code}\n\n${e.toString()}'
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;           
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.auth(
        error: AuthError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;            
    }
  } 

//------------------------------------------------------------------------------------------


//  REGISTER--------------------------------------------------------------------------------

/// Attempts to register a user, taking an [email] and [password] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> register(String email, String password) async {
    const String function = 'FirebaseAuthService.register()';
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    
    final (ErrorState userErrorState, User? firebaseUser) = await user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    
    if (firebaseUser == null) {
      try {
        
        await auth!.createUserWithEmailAndPassword(email: email, password: password);
        return ErrorState.none();  
      
      } on FirebaseException catch (e) {
        switch (e.code) {
          case 'email-already-in-use':
          final registerErrorState = ErrorState.auth(
            error: AuthError.emailAlreadyInUse, 
            function: function, 
            context: 'Email: $email'
          );
          return registerErrorState;
          case 'invalid-email':
          final registerErrorState = ErrorState.auth(
            error: AuthError.invalidEmail, 
            function: function, 
            context: 'Email: $email'
          );
          return registerErrorState;
          case 'weak-password':
          final registerErrorState = ErrorState.auth(
            error: AuthError.weakPassword, 
            function: function, 
            context: null
          );
          return registerErrorState;
          case 'too-many-requests':
          final registerErrorState = ErrorState.auth(
            error: AuthError.tooManyRequests, 
            function: function, 
            context: null
          );
          return registerErrorState;   
          case 'network-request-failed':
          final registerErrorState = ErrorState.auth(
            error: AuthError.networkRequestFailed, 
            function: function, 
            context: null
          );
          return registerErrorState;
          case 'channel-error':
          final registerErrorState = ErrorState.auth(
            error: AuthError.channelError, 
            function: function, 
            context: null
          );
          return registerErrorState;
          default:
          final exceptionErrorState = ErrorState.auth(
            error: AuthError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;               
        } 
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.auth(
          error: AuthError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;          
      }
    } else {
      final registerErrorState = ErrorState.auth(
        error: AuthError.alreadyLoggedIn, 
        function: function, 
        context: 'Email: $email'
      );
      return registerErrorState;
    }
  }

/// Sends a verification email to the current session [User] email address
/// 
/// Returns an [ErrorState]
  Future<ErrorState> sendEmailVerification() async {
    String function = 'FirebaseAuthService.sendEmailVerification()';
    final (ErrorState initErrorState, FirebaseApp? firebaseApp, FirebaseAuth? auth) = await firebase;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    final (ErrorState userErrorState, User? firebaseUser) = await user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }
    if (firebaseUser != null) {
      try {
        await firebaseUser.sendEmailVerification();
        return ErrorState.none();
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'user-not-found':
          final exceptionErrorState = ErrorState.auth(
            error: AuthError.userNotFound, 
            function: function, 
            context: null
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;
          default:
          final exceptionErrorState = ErrorState.auth(
            error: AuthError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return exceptionErrorState; 
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.auth(
          error: AuthError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;  
      }
    } else {
      final sendErrorState = ErrorState.auth(
        error: AuthError.notLoggedIn, 
        function: function, 
        context: null
      );
      return sendErrorState;
    }
  }

//------------------------------------------------------------------------------------------
}
