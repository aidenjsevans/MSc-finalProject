import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_route/bouldering_route_notifier.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [BoulderingRouteListNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingRouteListNotifierProvider = StateNotifierProvider<
BoulderingRouteListNotifier,
(ErrorState,List<BoulderingRouteModel>?)>((ref) {
  final cloudNotifier = ref.watch(cloudNotifierProvider.notifier);
  final databaseNotifier = ref.watch(databaseNotifierProvider.notifier);
  return BoulderingRouteListNotifier(cloudNotifier, databaseNotifier);
});

/// Makes the [BoulderingRouteNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingRouteNotifierProvider = StateNotifierProvider<
BoulderingRouteNotifier,
(ErrorState,BoulderingRouteModel?)>((ref) {
  final cloudNotifier = ref.watch(cloudNotifierProvider.notifier);
  return BoulderingRouteNotifier(cloudNotifier);
});