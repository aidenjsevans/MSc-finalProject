import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationView extends ConsumerStatefulWidget {
  const EmailVerificationView({super.key});

  @override
  ConsumerState<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends ConsumerState<EmailVerificationView> {

  late final ProviderSubscription<dynamic> authSubscription;
  
  bool _hasSentEmail = false;

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.auth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = ref.read(firebaseAuthNotifierProvider.notifier);
      authNotifier.sendEmailVerification();
      _hasSentEmail = true;
    });

  }

  @override
  void dispose() {
    authSubscription.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuthNotifier = ref.read(firebaseAuthNotifierProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.primaryContainer,
              width: 5
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Icon(
                    Icons.email_rounded,
                    size: IconConstant.largeSize,
                  ),
                ),
              ),
              
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Text(
                    "We have sent a verification email. Haven't received an email yet? Press Re-send",
                    style: Theme.of(context).textTheme.titleMedium,
                    ),
                ),
              ),
          
              ElevatedButton(
                onPressed: () {
                  if (!_hasSentEmail) {
                    firebaseAuthNotifier.sendEmailVerification();
                    _hasSentEmail = true;
                  }
                }, 
                child: Text(
                  'Re-send',
                  style: TextStyle(
                    fontSize: 24
                  ),
                )
              ),
          
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Text(
                    "Once your email is verified, please return to the login page and enter your credentials",
                    style: Theme.of(context).textTheme.titleMedium,
                    ),
                ),
              ),
          
            ],
          ),
        ),
      )
    );  
  }
}

