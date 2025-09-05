import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/observers.dart';
import 'package:climbmetrics/views/auth/email_verification_view.dart';
import 'package:climbmetrics/views/bouldering_route/bouldering_route_view.dart';
import 'package:climbmetrics/views/bouldering_wall/bouldering_wall_list_view.dart';
import 'package:climbmetrics/views/bouldering_wall/bouldering_wall_search_result_view.dart';
import 'package:climbmetrics/views/bouldering_wall/bouldering_wall_view.dart';
import 'package:climbmetrics/views/bouldering_wall/qr_scanner_view.dart';
import 'package:climbmetrics/views/error/fatal_error_view.dart';
import 'package:climbmetrics/views/metrics/metric_list_view.dart';
import 'package:climbmetrics/views/project_library/project_library_list_view.dart';

import 'package:climbmetrics/views/auth/init_view.dart';
import 'package:climbmetrics/views/auth/login_view.dart';
import 'package:climbmetrics/views/auth/register_view.dart';
import 'package:climbmetrics/views/database/database_loading_view.dart';
import 'package:climbmetrics/views/project_library/project_library_view.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    //  The ProviderScope defines what Widgets in the Widget tree have access to
    //  the various Providers. Since the ProviderScope contains the root Widget, 
    //  MyApp, all Widgets will have access to the Providers.
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimbMetrics',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
        
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 147, 197, 217)
        ),
        
        colorScheme: ColorScheme.light(
          primaryContainer: Color.fromARGB(255, 147, 197, 217),
          secondaryContainer: Color.fromARGB(255, 111, 196, 230),
          tertiaryContainer: Color.fromARGB(255, 70, 196, 255),
        ),
        
        textTheme: TextTheme(
          
          titleLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
          
          titleMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),

          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),

          bodyLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
          
          bodyMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
          
          bodySmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
        ),
        useMaterial3: true
        ),
      initialRoute: initRoute,
      navigatorObservers: [
        routeObserver
      ],
      routes: {

        //  AUTHENTICATION------------------------------------------------------------------------------------------------------
        initRoute: (context) => const InitView(key: ValueKey('InitView')),
        loginRoute: (context) => const LoginView(key: ValueKey('LoginView')),
        registrationRoute: (context) => const RegisterView(key: ValueKey('RegisterView')),
        emailVerificationRoute: (context) => const EmailVerificationView(key: ValueKey('EmailVerificationView')),        
        //----------------------------------------------------------------------------------------------------------------------
        

        //  PROJECT LIBRARY-----------------------------------------------------------------------------------------------------
        projectLibraryListRoute: (context) => const ProjectLibraryListView(key: ValueKey('ProjectLibraryListView')),
        projectLibraryRoute: (context) => const ProjectLibraryView(key: ValueKey('ProjectLibraryView')),
        //----------------------------------------------------------------------------------------------------------------------
        

        //  DATABASE------------------------------------------------------------------------------------------------------------
        databaseLoadingRoute: (context) => const DatabaseLoadingView(key: ValueKey('DatabaseLoadingView')),
        //----------------------------------------------------------------------------------------------------------------------
        

        //  METRICS-------------------------------------------------------------------------------------------------------------
        metricListRoute: (context) => const MetricListView(key: ValueKey('MetricListView')),
        //----------------------------------------------------------------------------------------------------------------------
        
        
        //  BOULDERING WALL-----------------------------------------------------------------------------------------------------
        boulderingWallListRoute: (context) => const BoulderingWallListView(key: ValueKey('BoulderingWallListView')),
        boulderingWallRoute: (context) => const BoulderingWallView(key: ValueKey('BoulderingWallView')),
        boulderingWallSearchResultRoute: (context) => const BoulderingWallSearchResultView(key: ValueKey('BoulderingWallSearchResultView')),
        qrScannerRoute: (context) => const QrScannerView(key: ValueKey('QRScannerView')),
        //----------------------------------------------------------------------------------------------------------------------


        //  BOULDERING ROUTE----------------------------------------------------------------------------------------------------
        boulderingRouteRoute: (context) => const BoulderingRouteView(key: ValueKey('BoulderingRouteView')),
        //----------------------------------------------------------------------------------------------------------------------


        //  ERROR---------------------------------------------------------------------------------------------------------------
        fatalErrorRoute: (context) => const FatalErrorView(key: ValueKey('FatalErrorView'))
        //----------------------------------------------------------------------------------------------------------------------
        
      },
    );
  }
}


     


