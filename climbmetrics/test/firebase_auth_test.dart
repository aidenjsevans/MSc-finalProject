import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class UserNotFoundAuth extends MockFirebaseAuth {
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw FirebaseAuthException(
      code: 'user-not-found',
    );
  }
}

class InvalidEmailAuth extends MockFirebaseAuth {
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw FirebaseAuthException(
      code: 'invalid-email',
    );
  }

}

class InvalidCredentialAuth extends MockFirebaseAuth {
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw FirebaseAuthException(
      code: 'invalid-credential',
    );
  }

}

Future<void> main() async {
  group('FirebaseAuthService - login()', () {
    test('Given a valid password and email, When login() is called, Then returns a null ErrorState', () async {
      
      // GIVEN a mock FirebaseAuthService with a mock user
      final mockUser = MockUser(
        uid: 'test123',
        email: 'test@example.com',
      );

      final mockAuth = MockFirebaseAuth(mockUser: mockUser);
      final mockFirebaseApp = MockFirebaseApp();
      final mockAuthService = FirebaseAuthService(auth: mockAuth, firebaseApp: mockFirebaseApp);
      
      // WHEN login() is called
      final ErrorState loginErrorState = await mockAuthService.login(mockUser.email!, 'password');

      // THEN returns null ErrorState
      expect(loginErrorState.isNull(), true);
      expect(mockAuth.currentUser == null, false);
    });

    test('Given a user does not exist, When login() is called, Then returns ErrorState.state equal to AuthError.userNotFound', () async {
      
      // GIVEN a mock FirebaseAuthService and an unregistered user
      final mockUser = MockUser(
        uid: 'test123',
        email: 'test@example.com',
      );

      final mockAuth = UserNotFoundAuth();
      final mockFirebaseApp = MockFirebaseApp();
      final mockAuthService = FirebaseAuthService(auth: mockAuth, firebaseApp: mockFirebaseApp);
      
      // WHEN login() is called
      final ErrorState loginErrorState = await mockAuthService.login(mockUser.email!, 'password');

      // THEN returns null ErrorState
      expect(loginErrorState.state, AuthError.userNotFound);
      expect(mockAuth.currentUser == null, true);
    });

    test('Given a user gives an incorrect email, When login() is called, Then returns ErrorState.state equal to AuthError.invalidEmail', () async {
      
      // GIVEN a mock FirebaseAuthService and an mock user
      final mockUser = MockUser(
        uid: 'test123',
        email: 'invalidemail@example.com',
      );

      final mockAuth = InvalidEmailAuth();
      final mockFirebaseApp = MockFirebaseApp();
      final mockAuthService = FirebaseAuthService(auth: mockAuth, firebaseApp: mockFirebaseApp);
      
      // WHEN login() is called
      final ErrorState loginErrorState = await mockAuthService.login(mockUser.email!, 'password');

      // THEN returns null ErrorState
      expect(loginErrorState.state, AuthError.invalidEmail);
      expect(mockAuth.currentUser == null, true);
    });

    test('Given a user gives an incorrect credential, When login() is called, Then returns ErrorState.state equal to AuthError.invalidCredential', () async {
      
      // GIVEN a mock FirebaseAuthService and an mock user
      final mockUser = MockUser(
        uid: 'test123',
        email: 'invalidemail@example.com',
      );

      final mockAuth = InvalidCredentialAuth();
      final mockFirebaseApp = MockFirebaseApp();
      final mockAuthService = FirebaseAuthService(auth: mockAuth, firebaseApp: mockFirebaseApp);
      
      // WHEN login() is called
      final ErrorState loginErrorState = await mockAuthService.login(mockUser.email!, 'password');

      // THEN returns null ErrorState
      expect(loginErrorState.state, AuthError.invalidCredential);
      expect(mockAuth.currentUser == null, true);
    });
  });
}