import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:climbmetrics/main.dart' as app;

void main() {
  
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Successfully create a project library', (WidgetTester tester) async {
    
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
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    final createProjectLibraryListTile = find.byKey(const Key('createProjectLibraryListTile'));
    expect(createProjectLibraryListTile, findsOneWidget);
    await tester.tap(createProjectLibraryListTile);

    await tester.pumpAndSettle();

    final projectLibraryNameTextField = find.byKey(const Key('projectNameTextField'));
    expect(projectLibraryNameTextField, findsOneWidget);

    final projectTagNameTextField = find.byKey(const Key('projectTagTextField'));
    expect(projectTagNameTextField, findsOneWidget);

    final projectLibrarySubmitButton = find.byKey(const Key('projectLibrarySubmitButton'));
    expect(projectLibrarySubmitButton, findsOneWidget);

    final String projectName = 'Project 1';
    final String projectTag = 'The Red Goat';

    await Future.delayed(Duration(seconds: 1));

    await tester.enterText(projectLibraryNameTextField, projectName);

    await Future.delayed(Duration(seconds: 1));

    await tester.enterText(projectTagNameTextField, projectTag);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(projectLibrarySubmitButton);

    await tester.pumpAndSettle();

    final snackBar = find.byKey(const Key('successSnackBar'));
    expect(snackBar, findsOneWidget);

    final projectLibraryTile = find.byKey(Key('projectLibraryTile1'));
    expect(projectLibraryTile, findsOneWidget);

    final projectLibraryListTilePopupMenuButton = find.byKey(Key('projectLibraryListTilePopupMenuButton1'));
    expect(projectLibraryListTilePopupMenuButton, findsOneWidget);

    await tester.tap(projectLibraryListTilePopupMenuButton);

    await tester.pumpAndSettle();

    final projectLibraryListTileDeletePopupMenuItem = find.byKey(Key('projectLibraryListTileDeletePopupMenuItem1'));
    expect(projectLibraryListTileDeletePopupMenuItem, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(projectLibraryListTileDeletePopupMenuItem);

    await tester.pumpAndSettle();

    final deleteProjectLibrarySnackBar = find.byKey(Key('successSnackBar'));
    expect(deleteProjectLibrarySnackBar, findsOneWidget);

    await Future.delayed(Duration(seconds: 5));

    expect(projectLibraryTile, findsNothing);
  });
}