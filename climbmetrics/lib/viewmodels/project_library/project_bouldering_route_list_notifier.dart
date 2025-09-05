import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [ProjectBoulderingRouteListNotifier] provides various methods that can change its [state], which is 
/// a list of [BoulderingRouteModel]
class ProjectBoulderingRouteListNotifier extends StateNotifier<(ErrorState,List<BoulderingRouteModel>?)> {
  
  final DatabaseNotifier _databaseNotifier;
  
  ProjectBoulderingRouteListNotifier(
    this._databaseNotifier
  ) : super((ErrorState.none(),null));

/// Calls the [getProjectBoulderingRouteList] method from the [DatabaseNotifier] and changes the internal [state] of the [ProjectBoulderingRouteListNotifier]
  Future<void> getProjectBoulderingRouteList(int projectLibraryID) async {
    state = await _databaseNotifier.getProjectBoulderingRouteList(projectLibraryID);
  }
}