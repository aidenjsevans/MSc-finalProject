import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [BoulderingRouteListNotifier] provides various methods that can change its [state], which is 
/// a list of [BoulderingRouteModel]
class BoulderingRouteListNotifier extends StateNotifier<(ErrorState,List<BoulderingRouteModel>?)>{

  final CloudNotifier _cloudNotifier;
  final DatabaseNotifier _databaseNotifier;

  BoulderingRouteListNotifier(
    this._cloudNotifier,
    this._databaseNotifier
  ) : super((ErrorState.none(),null));

/// Calls the [fetchBoulderingRouteListByBoulderingWallID] method from the [CloudNotifier] and changes the internal [state] of the [BoulderingRouteListNotifier]
  Future<void> fetchBoulderingRouteListByBoulderingWallID(String boulderingWallID) async {
    state = await _cloudNotifier.fetchBoulderingRouteListByBoulderingWallID(boulderingWallID);
  }

/// Calls the [getProjectBoulderingRouteList] method from the [DatabaseNotifier] and changes the internal [state] of the [BoulderingRouteListNotifier]
  Future<void> getProjectBoulderingRouteList(int projectLibraryID) async {
    state = await _databaseNotifier.getProjectBoulderingRouteList(projectLibraryID);
  }

/// Changes the [state] to ([ErrorState.none],null)
  void reset() {
    state = (ErrorState.none(),null);
  }
}