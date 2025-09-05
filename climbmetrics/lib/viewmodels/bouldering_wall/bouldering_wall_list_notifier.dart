import 'dart:developer';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/viewmodels/database/database_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [BoulderingWallLinkListNotifier] provides various methods that can change its [state], which is 
/// a list of [BoulderingWallLinkModel]
class BoulderingWallLinkListNotifier extends StateNotifier<(ErrorState,List<BoulderingWallLinkModel>?)>{

  final DatabaseNotifier _databaseNotifier;

  BoulderingWallLinkListNotifier(
    this._databaseNotifier
  ) : super((ErrorState.none(),null));

/// Calls the [getCurrentBoulderingWallLinkList] method from the [DatabaseNotifier] and changes the internal [state] of the [BoulderingWallLinkListNotifier]
/// depending on the [ErrorState] 
  Future<void> getCurrentBoulderingWallLinkList() async {
    
    const String function = 'BoulderingWallListNotifier.getCurrentBoulderingWallLinkList()';
    state = (ErrorState.loading(), null);

    final (
      ErrorState getErrorState, 
      List<BoulderingWallLinkModel>? boulderingWallLinkList
      ) = await _databaseNotifier.getCurrentBoulderingWallLinkList();
    
    if (getErrorState.isNotNull() || boulderingWallLinkList == null) {
      state = (getErrorState,null);
      return;
    }
    
    state = (ErrorState.none(function: function), boulderingWallLinkList);
    log('\nState: $state\nFunction: $function\nContext: null');
  }

/// Calls the [insertCurrentBoulderingWallLink] method from the [DatabaseNotifier]
/// 
/// Returns an [ErrorStates] 
  Future<ErrorState> insertCurrentBoulderingWallLink(
    String boulderingWallID, 
    String displayName,
    String city,
    String postcode,
    String street,
    ) async {

    final ErrorState errorState = await _databaseNotifier.insertCurrentBoulderingWallLink(
      boulderingWallID, 
      displayName, 
      city, 
      postcode, 
      street
      );
    
    return errorState;
  }

/// Calls the [insertCurrentBoulderingWallLink] method from the [DatabaseNotifier]
/// 
/// Returns an [ErrorState]
  Future<ErrorState> deleteCurrentBoulderingWallLink(String boulderingWallID) async {
    return _databaseNotifier.deleteCurrentBoulderingWallLink(boulderingWallID);
  }

/// Calls the [isCurrentBoulderingWallLinked] method from the [DatabaseNotifier]
/// 
/// Returns an [ErrorState]
  Future<(ErrorState,bool)> isCurrentBoulderingWallLinked(String boulderingWallID) async {
    return _databaseNotifier.isCurrentBoulderingWallLinked(boulderingWallID);
  }

/// Changes the [state] to ([ErrorState.none],null)
  void reset() {
    const String function = 'BoulderingWallListNotifier.reset()';
    state = (ErrorState.none(),null);
    log('\nState: $state\nFunction: $function\nContext: null');
  }
}

