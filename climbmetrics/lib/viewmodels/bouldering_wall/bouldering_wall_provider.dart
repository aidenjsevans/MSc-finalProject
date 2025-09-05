import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_list_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_notifier.dart';
import 'package:climbmetrics/viewmodels/bouldering_wall/bouldering_wall_search_notifier.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_provider.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [BoulderingWallSearchNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingWallSearchNotifierProvider = StateNotifierProvider<
BoulderingWallSearchNotifier,
(ErrorState,String?,List<BoulderingWallModel>?,Map<String,bool>?)>((ref) {
  final cloudNotifier = ref.read(cloudNotifierProvider.notifier);
  final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
  return BoulderingWallSearchNotifier(cloudNotifier, databaseNotifier);
});

/// Makes the [BoulderingWallLinkNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingWallLinkNotifierProvider = StateNotifierProvider<
BoulderingWallLinkNotifier,
BoulderingWallLinkModel?>((ref) {
  return BoulderingWallLinkNotifier();
});

/// Makes the [BoulderingWallLinkListNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingWallLinkListNotifierProvider = StateNotifierProvider<
BoulderingWallLinkListNotifier,
(ErrorState,List<BoulderingWallLinkModel>?)>((ref) {
  final databaseNotifier = ref.read(databaseNotifierProvider.notifier);
  return BoulderingWallLinkListNotifier(databaseNotifier);
});

/// Makes the [BoulderingWallNotifier] and its [state] available to objects defined within the [ProviderScope]
final boulderingWallNotifierProvider = StateNotifierProvider<
BoulderingWallNotifier,
(ErrorState, String?, BoulderingWallModel?)>((ref) {
  final cloudNotifier = ref.read(cloudNotifierProvider.notifier);
  return BoulderingWallNotifier(cloudNotifier);
});