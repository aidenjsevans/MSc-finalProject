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
    
    final projectLibraryListView = find.byKey(Key('ProjectLibraryListView'));
    expect(projectLibraryListView, findsOneWidget);

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

    final projectLibraryListTile = find.byKey(Key('projectLibraryTile1'));
    expect(projectLibraryListTile, findsOneWidget);

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

    await Future.delayed(Duration(seconds: 1));

    String routeID = '226b5d02-1ed8-4a98-a93a-83e9965757ad';

    final boulderingRouteListTile = find.byKey(Key('boulderingRouteListTile$routeID'));
    await tester.scrollUntilVisible(boulderingRouteListTile, 400);
    expect(boulderingRouteListTile, findsOneWidget);

    
    final addBoulderingRouteIconButton = find.byKey(Key('isNotInProjectLibraryAddIconButton$routeID'));
    expect(addBoulderingRouteIconButton, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(addBoulderingRouteIconButton);

    await tester.pumpAndSettle();

    await Future.delayed(Duration(seconds: 1));

    final insertBoulderingRouteIconButton = find.byKey(Key('insertBoulderingRouteIconButton1'));
    expect(insertBoulderingRouteIconButton, findsOneWidget);

    await tester.tap(insertBoulderingRouteIconButton);

    await tester.pumpAndSettle();

    final insertBoulderingRouteSnackBar = find.byKey(Key('successSnackBar'));
    expect(insertBoulderingRouteSnackBar, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    final backButton = find.byTooltip('Back');
    
    await tester.tap(backButton);
    
    await tester.pumpAndSettle();

    expect(boulderingWallListView, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    final projectLibrariesBottomNavigationBarItem = find.byKey(Key('projectLibrariesBottomNavigationBarItem'));
    expect(projectLibrariesBottomNavigationBarItem, findsOneWidget);

    await tester.tap(projectLibrariesBottomNavigationBarItem);

    await tester.pumpAndSettle();

    expect(projectLibraryListView, findsOneWidget);

    expect(projectLibraryListTile, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(projectLibraryListTile);

    await tester.pumpAndSettle();

    final projectLibraryView = find.byKey(Key('ProjectLibraryView'));
    expect(projectLibraryView, findsOneWidget);

    expect(boulderingRouteListTile, findsOneWidget);

    final boulderingRoutePopupMenuButton = find.byKey(Key('inProjectLibraryPopupMenuButton$routeID'));
    expect(boulderingRoutePopupMenuButton, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(boulderingRoutePopupMenuButton);

    await tester.pumpAndSettle();

    final archivePopupMenuItem = find.byKey(Key('archivePopupMenuItem$routeID'));
    expect(archivePopupMenuItem, findsOneWidget);

    final deletePopupMenuItem = find.byKey(Key('deletePopupMenuItem$routeID'));
    expect(deletePopupMenuItem, findsOneWidget);

    await Future.delayed(Duration(seconds: 2));

    await tester.tap(archivePopupMenuItem);

    await tester.pumpAndSettle();

    final archiveSnackBar = find.byKey(Key('successSnackBar'));
    expect(archiveSnackBar, findsOneWidget);

    await Future.delayed(Duration(seconds: 1));

    await tester.tap(find.byTooltip('Back'));
    
    await tester.pumpAndSettle();

    expect(projectLibraryListView, findsOneWidget);

    final metricsBottomNavigationBarItem = find.byKey(Key('metricsBottomNavigationBarItem')); 
    expect(metricsBottomNavigationBarItem, findsOneWidget);
    
    await Future.delayed(Duration(seconds: 1));

    await tester.tap(metricsBottomNavigationBarItem);

    await tester.pumpAndSettle();

    final hardestRouteText = find.byKey(Key('hardestRouteText'));
    expect(hardestRouteText, findsOneWidget);

    final totalBarChart = find.byKey(Key('totalBarChart'));
    await tester.scrollUntilVisible(totalBarChart, 50, continuous: true);

    expect(totalBarChart, findsOneWidget);

    final totalBarChartCenter = tester.getCenter(totalBarChart);
    final totalBarChartCenterOffset = totalBarChartCenter + Offset(-15,0);

    await Future.delayed(Duration(seconds: 1));

    await tester.longPressAt(totalBarChartCenterOffset);

    await tester.pumpAndSettle();

    await Future.delayed(Duration(seconds: 1));

    final yearBarChart = find.byKey(Key('yearBarChart'));
    await tester.scrollUntilVisible(yearBarChart, 50, continuous: true);

    expect(yearBarChart, findsOneWidget);

    final yearBarChartCenter = tester.getCenter(yearBarChart);
    final yearBarChartCenterOffset = yearBarChartCenter + Offset(-15,0);

    await tester.longPressAt(yearBarChartCenterOffset);

    await tester.pumpAndSettle();

    await Future.delayed(Duration(seconds: 1));

    final monthBarChart = find.byKey(Key('monthBarChart'));
    await tester.scrollUntilVisible(monthBarChart, 50, continuous: true);

    expect(monthBarChart, findsOneWidget);

    final monthBarChartCenter = tester.getCenter(monthBarChart);
    final monthBarChartCenterOffset = monthBarChartCenter + Offset(-15,0);

    await tester.longPressAt(monthBarChartCenterOffset);

    await tester.pumpAndSettle();

    await Future.delayed(Duration(seconds: 1));

    final radarChart = find.byKey(Key('radarChart'));
    await tester.scrollUntilVisible(radarChart, 50, continuous: true);

    expect(radarChart, findsOneWidget);

    final pieChart = find.byKey(Key('pieChart'));
    await tester.scrollUntilVisible(pieChart, 50, continuous: true);

    expect(pieChart, findsOneWidget);

    final pieChartCenter = tester.getCenter(pieChart);
    final pieChartCenterOffset = pieChartCenter + Offset(-15,-15);

    await tester.longPressAt(pieChartCenterOffset);

    await tester.pumpAndSettle();

    final lineChart = find.byKey(Key('lineChart'));
    await tester.scrollUntilVisible(lineChart, 50, continuous: true);

    expect(lineChart, findsOneWidget);
  });
}