import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseLoadingView extends ConsumerStatefulWidget {
  const DatabaseLoadingView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DatabaseLoadingViewState();
  
}

class _DatabaseLoadingViewState extends ConsumerState<DatabaseLoadingView> {
  
  late final ProviderSubscription<dynamic> authSubscription;
  late final ProviderSubscription<DatabaseState> databaseSubscription;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    final databaseNotifier = ref.read(databaseNotifierProvider.notifier);

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
    
    databaseNotifier.deleteDB();
    databaseNotifier.initializeDB();
    databaseNotifier.insertCurrentUser();
    
    databaseSubscription = ref.listenManual<DatabaseState>(
      databaseNotifierProvider, 
      (previous, next) {
        if (_hasRedirected) {
          return;
        }
        if (next == DatabaseState.nominal) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(projectLibraryListRoute);
          });
        } else if (next == DatabaseState.error) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(fatalErrorRoute);
          });            
        }
    });
  }

  @override
  void dispose() {
    authSubscription.close();
    databaseSubscription.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator()
      )
    );  
  }
}

  