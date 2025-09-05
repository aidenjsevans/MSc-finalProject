import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitView extends ConsumerStatefulWidget {
  
  const InitView({super.key});

  @override
  ConsumerState<InitView> createState() => _InitViewState();
}
  
class _InitViewState extends ConsumerState<InitView> {

  late final ProviderSubscription<dynamic> authSubscription; 

  @override
  void initState() {
    super.initState();

    final firebaseAuthNotifier = ref.read(firebaseAuthNotifierProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      firebaseAuthNotifier.initializeFA();
    });

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
    
  }

  @override
  void dispose() {
    authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Align(
            alignment: Alignment(0,0),
            child: Image.asset(
              height: 250, 
              width: 250, 
              'assets/logo.png'
            ),
          ),
          
          Align(
            alignment: Alignment(0,0.5),
            child: CircularProgressIndicator()
          )
        ]
      )
    );  
  }
}

  

