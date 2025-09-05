import 'package:climbmetrics/services/database/database_service.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [DatabaseService] available to objects defined within the [ProviderScope]
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final firebaseAuthService = ref.watch(firebaseAuthServiceProvider);
  return DatabaseService(firebaseAuthService);
});

/// Makes the [DatabaseNotifier] and its [state] available to objects defined within the [ProviderScope]
final databaseNotifierProvider = StateNotifierProvider<DatabaseNotifier,DatabaseState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final firebaseAuthNotifier = ref.watch(firebaseAuthNotifierProvider.notifier);
  final databaseNotifier = DatabaseNotifier(databaseService, firebaseAuthNotifier);
  return databaseNotifier;
});

