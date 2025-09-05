import 'dart:developer';

import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_notifier.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [BoulderingWallSearchNotifier] provides various methods that can change its [state], which contains a display name,
/// list of [BoulderingWallModel], and a [Map] indicating if each [BoulderingWallModel] is linked to the current session users
/// account
class BoulderingWallSearchNotifier extends StateNotifier<(ErrorState,String?,List<BoulderingWallModel>?,Map<String,bool>?)> {

  final CloudNotifier _cloudNotifier;
  final DatabaseNotifier _databaseNotifier;

  BoulderingWallSearchNotifier(
    this._cloudNotifier,
    this._databaseNotifier
  ) : super((ErrorState.none(),null,null, null));

/// Calls the [fetchBoulderingWallListByCompanyName] method from the [CloudNotifier] and the 
/// the [isCurrentBoulderingWallLinked] method from the [DatabaseNotifier]. It then changes the internal [state] of the [BoulderingWallSearchNotifier]
/// depending on the [ErrorState] 
  Future<ErrorState> fetchBoulderingWallListByCompanyName(String companyName) async {
    
    Map<String,bool>? isLinkedMap;

    final (
      ErrorState errorState, 
      String? displayName, 
      List<BoulderingWallModel>? boulderingWallList
      ) = await _cloudNotifier.fetchBoulderingWallListByCompanyName(companyName);
    
    if (boulderingWallList != null) {
      isLinkedMap = {};
      
      for (final boulderingWall in boulderingWallList) {

        log('$boulderingWall');
        
        String boulderingWallID = boulderingWall.boulderingWallID!;
        
        final (
          ErrorState isErrorState, 
          bool result
        ) = await _databaseNotifier.isCurrentBoulderingWallLinked(boulderingWallID);

        if (isErrorState.isNotNull()) {
          state = (isErrorState, null, null, null);
          return isErrorState;
        }

        isLinkedMap[boulderingWallID] = result;
      }
    }

    state = (errorState, displayName, boulderingWallList, isLinkedMap);
    return errorState;
  }

/// Changes the [state] to ([ErrorState.none],null,null,null)
  void reset() {
    const String function = 'BoulderingWallSearchNotifier.reset()';
    state = (ErrorState.none(),null,null,null);
    log('\nState: $state\nFunction: $function\nContext: null');
  }
}