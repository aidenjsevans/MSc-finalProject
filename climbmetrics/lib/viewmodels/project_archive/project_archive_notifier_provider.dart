
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/project_archive/project_archive_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [ProjectArchiveNotifier] and its [state] available to objects defined within the [ProviderScope]
final projectArchiveNotifierProvider = StateNotifierProvider<
ProjectArchiveNotifier,
(ErrorState, List<String>?, List<BoulderingRouteModel>?)>((ref) {
  final databaseNotifier = ref.watch(databaseNotifierProvider.notifier);
  return ProjectArchiveNotifier(databaseNotifier);
});