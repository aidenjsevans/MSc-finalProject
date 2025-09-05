
import 'dart:developer';

import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:climbmetrics/viewmodels/auth/auth_state.dart';
import 'package:climbmetrics/viewmodels/auth/firebase_auth_notifier.dart';
import 'package:climbmetrics/viewmodels/auth/login/login_notifier.dart';
import 'package:climbmetrics/viewmodels/auth/register/register_notifier.dart';
import 'package:climbmetrics/views/auth/login_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:climbmetrics/main.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements FirebaseAuthService {}

class MockLoginNotifier extends Mock implements LoginNotifier {
  MockLoginNotifier() : super();
}

class MockRegisterNotifier extends Mock implements RegisterNotifier {
  MockRegisterNotifier() : super();
}

class LoggedOutFirebaseAuthNotifier extends FirebaseAuthNotifier {

  LoggedOutFirebaseAuthNotifier() : super(
    MockAuthService(),
    MockLoginNotifier(),
    MockRegisterNotifier()
  );

  @override
  Future<void> initializeFA() async {
    state = AuthState.loggedOut;
  }
}


void main() {
  testWidgets('Navigate to LoginView if the user is not signed in', (WidgetTester tester) async {
    try {
      await tester.pumpWidget(
      ProviderScope(
          overrides: [
            firebaseAuthNotifierProvider.overrideWith((ref) => LoggedOutFirebaseAuthNotifier()
            )
          ],
          child: MyApp()
        )
      );

      await tester.pump(Duration(seconds: 1));
      expect(find.byType(LoginView), findsOneWidget);
    } on Exception catch(e) {
      log(e.toString());
    }
    
  });
}