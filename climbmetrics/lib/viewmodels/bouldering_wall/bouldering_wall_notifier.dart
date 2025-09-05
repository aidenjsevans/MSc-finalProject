import 'dart:developer';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_link_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [BoulderingWallLinkNotifier] provides various methods that can change its [state], which is 
/// a [BoulderingWallLinkModel]
class BoulderingWallLinkNotifier extends StateNotifier<BoulderingWallLinkModel?> {

  BoulderingWallLinkNotifier() : super(null);

/// Sets the [state] value, taking a [BoulderingWallLinkModel] as an argument 
  void selectBoulderingWallLink(BoulderingWallLinkModel boulderingWallLink) {
    const String function = 'BoulderingWallLinkNotifier.selectBoulderingWall()';
    state = boulderingWallLink;
    log('\nState: $state\nFunction: $function\nContext: ${boulderingWallLink.boulderingWallID}');
  }

/// Changes the [state] to null
  void reset() {
    const String function = 'BoulderingWallNotifier.reset()';
    state = null;
    log('\nState: $state\nFunction: $function\nContext: null');
  }

}

class BoulderingWallNotifier extends StateNotifier<(ErrorState, String?, BoulderingWallModel?)> {

  final CloudNotifier _cloudNotifier;

  BoulderingWallNotifier(
    this._cloudNotifier
  ): super((ErrorState.none(),null,null));

  void fetchBoulderingWallByBoulderingWallID(String boulderingWallID) async {
    state = (ErrorState.loading(), null, null);
    state = await _cloudNotifier.fetchBoulderingWallByBoulderingWallID(boulderingWallID);
  }

  void reset() {
    state = (ErrorState.none(),null,null);
  }
}