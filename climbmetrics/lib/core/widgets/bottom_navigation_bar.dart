
import 'package:climbmetrics/core/utils/constants.dart';
import 'package:flutter/material.dart';

class PrimaryBottomNaviagtionBar extends StatelessWidget {
  PrimaryBottomNaviagtionBar({super.key});

  final List<String> routeList = [
    metricListRoute,
    projectLibraryListRoute,    
    boulderingWallListRoute,
  ];

  int getCurrentIndex(String? routeName) {
    if (routeName == null) {
      return routeList.indexOf(projectLibraryListRoute);
    } else {
      return routeList.indexOf(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final int currentIndex = getCurrentIndex(currentRoute);
    
    return BottomNavigationBar(
      key: Key('bottomNavigationBar'),
      currentIndex: currentIndex,
      onTap: (index) {
        final newRoute = routeList[index];
        if (newRoute != currentRoute) {
          Navigator.of(context).pushReplacementNamed(newRoute);
        }
      },
      items: [
        BottomNavigationBarItem(
          key: Key('metricsBottomNavigationBarItem'),
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Metrics'
        ),
        BottomNavigationBarItem(
          key: Key('projectLibrariesBottomNavigationBarItem'),
          icon: Icon(Icons.folder_rounded),
          label: 'Project Libraries'
        ),
        BottomNavigationBarItem(
          key: Key('boulderingWallsBottomNavigationBarItem'),
          icon: Icon(Icons.corporate_fare_rounded),
          label: 'Bouldering Walls'
        ),                
      ]
    );
  }
}