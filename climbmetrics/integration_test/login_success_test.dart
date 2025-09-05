import 'package:climbmetrics/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Successfully login', (WidgetTester tester) async {
    
    app.main();
    await tester.pumpAndSettle();

    final credentials = {
    "email": "aidenjsevans@gmail.com",
    "password": "axe122"
    };

    await Future.delayed(Duration(seconds: 3));

    final emailField = find.byKey(const Key('emailTextField'));
    expect(emailField, findsOneWidget);
    await tester.enterText(emailField, credentials['email']!);

    await Future.delayed(Duration(seconds: 3));

    final passwordField = find.byKey(const Key('passwordTextField'));
    expect(passwordField, findsOneWidget);
    await tester.enterText(passwordField, credentials['password']!);

    await Future.delayed(Duration(seconds: 1));

    final loginButton = find.byKey(const Key('loginIconButton'));
    expect(loginButton,findsOneWidget);
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

  });

}

