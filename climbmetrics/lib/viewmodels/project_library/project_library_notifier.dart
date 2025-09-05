import 'dart:developer';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectLibraryNotifier extends StateNotifier<(ErrorState,ProjectLibraryModel?)> {
  
  final DatabaseNotifier _databaseNotifier;

  ProjectLibraryNotifier(
    this._databaseNotifier
  ) : super((ErrorState.none(),null));

/// Sets the [state] value, taking a [ProjectLibraryModel] as an argument 
  Future<void> selectCurrentProjectLibrary(ProjectLibraryModel? projectLibrary) async {
    const String function = 'ProjectLibraryNotifier.selectCurrentProjectLibrary()';
    state = (ErrorState.selected(), projectLibrary);
    log('\nState: ${state.$1.state}\nFunction: $function\nContext: Project library ID: ${state.$2?.projectLibraryID}');
  }

/// Calls the [getCurrentProjectLibrary] method from the [DatabaseNotifier] and changes the internal [state] of the [ProjectLibraryNotifier]
  Future<void> getCurrentProjectLibrary(int projectLibraryID) async {
    const String function = 'ProjectLibraryNotifier.selectCurrentProjectLibrary()';
    state = await _databaseNotifier.getCurrentProjectLibrary(projectLibraryID);
    log('\nState: ${state.$1.state}\nFunction: $function\nContext: Project library ID: ${state.$2?.projectLibraryID}');
  }

/// Changes the [state] to ([ErrorState.none],null)
  void reset() {
  const String function = 'ProjectLibraryNotifier.reset()';
  state = (ErrorState.none(),null);
  log('\nState: ${state.$1.state}\nFunction: $function\nContext: null');
  }
}
