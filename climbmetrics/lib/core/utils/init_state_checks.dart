import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:climbmetrics/viewmodels/auth/auth_state.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StateCheck {

  final Map<(Enum?,Enum,RoutingMethod),String> errorStateRouteMap;
  final StateNotifierProvider notifierProvider;

  StateCheck({
    required this.errorStateRouteMap,
    required this.notifierProvider
  });

  ProviderSubscription<dynamic> check({
    required BuildContext context, 
    required WidgetRef ref,
    }) {
    return ref.listenManual(
      notifierProvider,
      (previous, next) {
        for (var entry in errorStateRouteMap.entries) {
          final (
            Enum? previousState,
            Enum nextState,
            Enum routingMethod
            ) = entry.key;
          
          final String endpoint = entry.value;

          switch (routingMethod) {
            case RoutingMethod.pushReplacementNamed:
            if (previousState == null) {
              if (next == nextState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(endpoint);
                });
                return;
              } 
            } else {
              if (previous == previousState && next == nextState) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacementNamed(endpoint);
                });
                return;
              } 
            }
          }
        }
      }
    );
  }
  
  factory StateCheck.auth() {
    final errorStateRouteMap = {
      (null, AuthState.loggedOut, RoutingMethod.pushReplacementNamed): loginRoute,
      (null, AuthState.emailNotVerified, RoutingMethod.pushReplacementNamed): loginRoute,
      (null, AuthState.error, RoutingMethod.pushReplacementNamed): fatalErrorRoute,
      (null, AuthState.loggedIn, RoutingMethod.pushReplacementNamed): databaseLoadingRoute
    };
    return StateCheck( 
      errorStateRouteMap: errorStateRouteMap,
      notifierProvider: firebaseAuthNotifierProvider
    );
  }

  factory StateCheck.firstAuth() {
    final errorStateRouteMap = {
      (null, AuthState.loggedOut, RoutingMethod.pushReplacementNamed): loginRoute,
      (null, AuthState.emailNotVerified, RoutingMethod.pushReplacementNamed): emailVerificationRoute,
      (null, AuthState.error, RoutingMethod.pushReplacementNamed): fatalErrorRoute,
      (null, AuthState.loggedIn, RoutingMethod.pushReplacementNamed): databaseLoadingRoute
    };
    return StateCheck( 
      errorStateRouteMap: errorStateRouteMap,
      notifierProvider: firebaseAuthNotifierProvider
    );
  }

  factory StateCheck.database() {
    final errorStateRouteMap = {
      (null, DatabaseState.closed, RoutingMethod.pushReplacementNamed): loginRoute,
      (null, AuthState.error, RoutingMethod.pushReplacementNamed): fatalErrorRoute,
    };
    return StateCheck( 
      errorStateRouteMap: errorStateRouteMap,
      notifierProvider: databaseNotifierProvider 
    );
  }
}

enum RoutingMethod {
  pushReplacementNamed
}


/*

ProviderSubscription<AuthState> standardAuthStateCheck({
  required BuildContext context,
  required WidgetRef ref
}) {
  return ref.listenManual<AuthState>(
    firebaseAuthNotifierProvider,
    (previous, next) {
      if (next == AuthState.loggedOut) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(loginRoute);
        });
      } else if (next == AuthState.emailNotVerified) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(emailVerificationRoute);
        });        
      } else if (next == AuthState.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(fatalErrorRoute);
        });        
      }
  });
}

ProviderSubscription<DatabaseState> standardDatabaseStateCheck({
  required BuildContext context,
  required WidgetRef ref
}) {
  return ref.listenManual<DatabaseState>(
    databaseNotifierProvider,
    (previous, next) {
      if (next == DatabaseState.closed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(loginRoute);
        });            
      } else if (next == DatabaseState.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(fatalErrorRoute);
        });           
      }       
    }
  );
}

*/

