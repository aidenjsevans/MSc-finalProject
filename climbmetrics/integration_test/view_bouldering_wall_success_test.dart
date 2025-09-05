import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:climbmetrics/main.dart' as app;

void main() {
  
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Successfully add bouldering route to project library', (WidgetTester tester) async {
    
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

    final projectLibraryListSnackBar = find.byKey(const Key('successSnackBar'));
    expect(projectLibraryListSnackBar, findsOneWidget);

    final bottomNavigationBar = find.byKey(const Key('bottomNavigationBar'));
    expect(bottomNavigationBar, findsOneWidget);

    final boulderingWallsBottomNavigationBarItem = find.byKey(const Key('boulderingWallsBottomNavigationBarItem'));
    expect(boulderingWallsBottomNavigationBarItem, findsOneWidget);

    await Future.delayed(Duration(seconds: 3));

    await tester.tap(boulderingWallsBottomNavigationBarItem);

    await tester.pumpAndSettle();

    final boulderingWallListView = find.byKey(Key('BoulderingWallListView'));
    expect(boulderingWallListView, findsOneWidget);

    final noBoulderingWallText = find.byKey(Key('noBoulderingWallsText'));
    expect(noBoulderingWallText, findsOneWidget);

    final boulderingWallSearchTextField = find.byKey(Key('boulderingWallSearchTextField'));
    expect(boulderingWallSearchTextField, findsOneWidget);

    final searchButton = find.byKey(Key('searchButton'));
    expect(searchButton, findsOneWidget);

    final String boulderingWallNameSearchText = 'The Red Goat Climbing Wall';

    await tester.enterText(boulderingWallSearchTextField, boulderingWallNameSearchText);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(searchButton);

    await tester.pumpAndSettle();

    final boulderingWallSearchResultView = find.byKey(Key('BoulderingWallSearchResultView'));
    expect(boulderingWallSearchResultView, findsOneWidget);

    final boulderingWallCompanyDisplayNameFinder = find.byKey(Key('boulderingWallCompanyDisplayName'));
    expect(boulderingWallCompanyDisplayNameFinder, findsOneWidget);

    final boulderingWallAddressFinder = find.byKey(Key('boulderingWallAddress'));
    expect(boulderingWallAddressFinder, findsOneWidget);

    final boulderingWallCompanyDisplayNameTextWidget = tester.widget<Text>(boulderingWallCompanyDisplayNameFinder);
    expect(boulderingWallCompanyDisplayNameTextWidget.data, 'The Red Goat Climbing Wall');

    final boulderingWallAddressTextWidget = tester.widget<Text>(boulderingWallAddressFinder);
    expect(boulderingWallAddressTextWidget.data, '6 Redeness Street, York, YO31 7UU');

    String boulderingWallID = '0f5bd181-4f0a-470e-950a-14bf7c2d4fba';

    final addBoulderingWallButton = find.byKey(Key('addBoulderingWallButton$boulderingWallID'));
    expect(addBoulderingWallButton, findsOneWidget);

    await tester.tap(addBoulderingWallButton);

    await tester.pumpAndSettle();

    final boulderingWallListSnackBar = find.byKey(Key('successSnackBar'));
    expect(boulderingWallListSnackBar, findsOneWidget);
    
    expect(boulderingWallListView, findsOneWidget);
    expect(noBoulderingWallText, findsNothing);

    final boulderingWallListTile = find.byKey(Key('boulderingWallListTile$boulderingWallID'));
    expect(boulderingWallListTile, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(boulderingWallListTile);

    await tester.pumpAndSettle();

    final boulderingWallView = find.byKey(Key('BoulderingWallView'));
    expect(boulderingWallView, findsOneWidget);
  });
}