import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/project_library/project_libary_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [ProjectLibraryListNotifier] provides various methods that can change its [state], which is 
/// a list of [ProjectLibraryModel]
class ProjectLibraryListNotifier extends StateNotifier<(ErrorState,List<ProjectLibraryModel>?)> {
  
  final DatabaseNotifier _databaseNotifier;
  
  ProjectLibraryListNotifier(
    this._databaseNotifier
  ) : super((ErrorState.none(), null));

/// Calls the [getCurrentProjectLibraryList] method from the [DatabaseNotifier] and changes the internal [state] of the [ProjectLibraryListNotifier]
  Future<void> getCurrentProjectLibraryList() async {
    state = (ErrorState.loading(), null);
    state = await _databaseNotifier.getCurrentProjectLibraryList();
  }

/// Calls the [insertCurrentProjectLibrary] method from the [DatabaseNotifier]
  Future<ErrorState> insertCurrentProjectLibrary(String name, String? tag) async {
    return await _databaseNotifier.insertCurrentProjectLibrary(name, tag);
  }

/// Calls the [deleteCurrentProjectLibrary] method from the [DatabaseNotifier]
  Future<ErrorState> deleteCurrentProjectLibrary(int projectLibraryID) async {
    return await _databaseNotifier.deleteCurrentProjectLibrary(projectLibraryID);
  }

/// Changes the [state] to ([ErrorState.none],null)
  void reset() {
    state = (ErrorState.none(), null);
  }
}