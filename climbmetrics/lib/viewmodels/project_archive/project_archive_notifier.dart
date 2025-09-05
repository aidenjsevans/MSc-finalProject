import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [ProjectArchiveNotifier] provides various methods that can change its [state], which is 
/// a list of [BoulderingRouteModel] and list of archive dates
class ProjectArchiveNotifier extends StateNotifier<(ErrorState,List<String>?,List<BoulderingRouteModel>?)> {

  final DatabaseNotifier _databaseNotifier;

  ProjectArchiveNotifier(
    this._databaseNotifier
  ) : super((ErrorState.none(), null, null));

/// Calls the [getCurrentArchivedBoulderingRouteList] method from the [DatabaseNotifier] and changes the internal [state] of the [ProjectArchiveNotifier]
  Future<void> getCurrentArchivedBoulderingRouteList() async {
    state = (ErrorState.loading(),null,null);
    await Future.delayed(Duration(seconds: 1));
    state = await  _databaseNotifier.getCurrentArchivedBoulderingRouteList();
  }

/// Changes the [state] to ([ErrorState.none],null,null)
  void reset() {
    state = (ErrorState.none(), null, null);
  }
}