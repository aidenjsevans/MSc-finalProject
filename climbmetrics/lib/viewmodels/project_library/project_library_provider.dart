import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/database/database_provider.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_list_notifier.dart';
import 'package:climbmetrics/viewmodels/project_library/project_library_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the [ProjectLibraryListNotifier] and its [state] available to objects defined within the [ProviderScope]
final projectLibraryListNotifierProvider = StateNotifierProvider<
ProjectLibraryListNotifier,
(ErrorState, List<ProjectLibraryModel>?)>((ref) {
  final databaseNotifier = ref.watch(databaseNotifierProvider.notifier);
  return ProjectLibraryListNotifier(databaseNotifier);
});

/// Makes the [ProjectLibraryNotifier] and its [state] available to objects defined within the [ProviderScope]
final projectLibraryNotifierProvider = StateNotifierProvider<
ProjectLibraryNotifier,
(ErrorState, ProjectLibraryModel?)>((ref) {
  final databaseNotifier = ref.watch(databaseNotifierProvider.notifier);
  return ProjectLibraryNotifier(databaseNotifier);
});