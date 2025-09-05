import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/viewmodels/auth/register/register_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [RegisterNotifier] available to objects defined within the [ProviderScope]
final registerNotifierProvider = StateNotifierProvider<RegisterNotifier, ErrorState>((ref) {
  return RegisterNotifier();
});