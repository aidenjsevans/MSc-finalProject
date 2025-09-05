import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/text_field.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView>  {
  
  late final ProviderSubscription<dynamic> authSubscription;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final authStateCheck = StateCheck.firstAuth();
    authSubscription = authStateCheck.check(
      context: context, 
      ref: ref
    );
  }

  @override
  void dispose() {
    authSubscription.close();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Map<Enum, String> emailErrorText = {
    AuthError.emailAlreadyInUse: 'Email already in use',
    AuthError.tooManyRequests: 'Too many requests',
    AuthError.networkRequestFailed: 'Network request failed',
    AuthError.exception: 'Error',
    AuthError.channelError: 'Entry required',
    AuthError.invalidEmail: 'Invalid email'
  };

  Map<Enum, String> passwordErrorText = {
    AuthError.weakPassword: 'Weak password',
    AuthError.tooManyRequests: 'Too many requests',
    AuthError.networkRequestFailed: 'Network request failed',
    AuthError.exception: 'Error',
    AuthError.channelError: 'Entry required',
  };
  
  @override
  Widget build(BuildContext context) {
    
    final authNotifier = ref.watch(firebaseAuthNotifierProvider.notifier);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PrimaryAppBar(
        title: 'Register'
      ),
      body: Stack(
        children: [

          Align(
            alignment: Alignment(0,-0.3),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: standardTextField(
                controller: _emailController, 
                errorText: _emailErrorText, 
                labelText: 'Email'
              ),
            ),
          ),

          Align(
            alignment: Alignment(0,0),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: standardTextField(
                controller: _passwordController,
                obscureText: true, 
                errorText: _passwordErrorText, 
                labelText: 'Password'
              ),
            ),
          ),

          Align(
            alignment:  Alignment(0.85,0),
            child: IconButton(
              onPressed: () async {

                setState(() {
                  _isLoading = true;
                });

                ErrorState errorState = await authNotifier.register(
                  _emailController.text.trim(), 
                  _passwordController.text,
                );

                setState(() {
                  _isLoading = false;
                });

                if (errorState.isNotNull()) {
                  setState(() {
                    _emailErrorText = emailErrorText[errorState.state];
                    _passwordErrorText = passwordErrorText[errorState.state];
                  });
                  return;
                }
              },  
              icon: _isLoading ? CircularProgressIndicator() : Icon(
                Icons.app_registration_rounded,
                size: 40,
              )
            )
          ),

          Align(
            alignment: Alignment(0,0.5),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              }, 
              child: Text(
                "Already have an account? Login here",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
              )
            ),
          ),
        ]
      ),
    );
  }
}