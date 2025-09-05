import 'package:climbmetrics/viewmodels/auth/auth_state.dart';
import 'package:climbmetrics/viewmodels/auth/firebase_auth_notifier.dart';
import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:climbmetrics/viewmodels/auth/login/login_provider.dart';
import 'package:climbmetrics/viewmodels/auth/register/register_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [FirebaseAuthService] available to objects defined within the [ProviderScope]
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Makes the [FirebaseAuthNotifier] and [AuthState] available to objects defined within the [ProviderScope]
final firebaseAuthNotifierProvider = StateNotifierProvider<FirebaseAuthNotifier,AuthState>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  final loginNotifier = ref.watch(loginNotifierProvider.notifier);
  final registerNotifier = ref.watch(registerNotifierProvider.notifier);
  return FirebaseAuthNotifier(
    firebaseAuthService,
    loginNotifier,
    registerNotifier
  );
});