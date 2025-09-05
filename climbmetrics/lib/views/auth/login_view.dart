import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/init_state_checks.dart';
import 'package:climbmetrics/core/widgets/app_bar.dart';
import 'package:climbmetrics/core/widgets/text_field.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  
  late final ProviderSubscription<dynamic> authSubscription; 
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authStateCheck = StateCheck.auth();
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
    AuthError.userNotFound: 'User not found',
    AuthError.invalidEmail: 'Invalid email',
    AuthError.invalidCredential: 'Invalid credential',
    AuthError.emailAlreadyInUse: 'Email not verified',
    AuthError.tooManyRequests: 'Too many requests',
    AuthError.networkRequestFailed: 'Network request failed',
    AuthError.exception: 'Error',
    AuthError.channelError: 'Entry required'
  };

  Map<Enum, String> passwordErrorText = {
    AuthError.userNotFound: 'User not found',
    AuthError.invalidPassword: 'Invalid password',
    AuthError.invalidCredential: 'Invalid credential',
    AuthError.tooManyRequests: 'Too many requests',
    AuthError.networkRequestFailed: 'Network request failed',
    AuthError.exception: 'Error',
    AuthError.channelError: 'Entry required'
  };

  @override
  Widget build(BuildContext context) {
    
    final authNotifier = ref.watch(firebaseAuthNotifierProvider.notifier);
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PrimaryAppBar(
        title: 'Login'
      ),
      body: Stack(
        children: [

          Align(
            alignment: Alignment(0,-1),
            child: Image.asset(
              height: 250,
              width: 250,
              'assets/logo.png'
            ),
          ),

          Align(
            alignment: Alignment(0,-0.3),
            child: FractionallySizedBox(
              widthFactor: 0.9,
              child: standardTextField(
                key: Key('emailTextField'),
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
                key: Key('passwordTextField'),
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
              key: Key('loginIconButton'),
              onPressed: () async {

                setState(() {
                  _isLoading = true;
                });

                ErrorState errorState = await authNotifier.login(
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
                Icons.arrow_circle_right,
                size: 40,
              )
            )
          ),

          Align(
            alignment: Alignment(0,0.5),
            child: TextButton(
              key: Key('registerPageTextButton'),
              onPressed: () {
                Navigator.of(context).pushNamed(registrationRoute);
              }, 
              child: Text(
                "Don't have an account? Register here",
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