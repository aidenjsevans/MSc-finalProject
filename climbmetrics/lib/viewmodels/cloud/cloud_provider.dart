
import 'package:climbmetrics/services/database/firebase_cloud_service.dart';
import 'package:climbmetrics/viewmodels/auth/auth_provider.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_notifier.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [FirebaseCloudService] available to objects defined within the [ProviderScope]
final firebaseCloudServiceProvider = Provider<
FirebaseCloudService>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return FirebaseCloudService(authService); 
});

/// Makes the [CloudNotifier] and its [state] available to objects defined within the [ProviderScope]
final cloudNotifierProvider = StateNotifierProvider<
CloudNotifier, 
CloudState>((ref) {
  final cloudService = ref.watch(firebaseCloudServiceProvider);
  return CloudNotifier(cloudService);
});