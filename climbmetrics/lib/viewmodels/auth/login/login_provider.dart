import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/viewmodels/auth/login/login_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [LoginNotifier] available to objects defined within the [ProviderScope]
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, ErrorState>((ref) {
  return LoginNotifier();
});