import 'dart:developer';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [BoulderingRouteNotifier] provides various methods that can change its [state], which is 
/// a [BoulderingRouteModel]
class BoulderingRouteNotifier extends StateNotifier<(ErrorState,BoulderingRouteModel?)> {
  
  final CloudNotifier _cloudNotifier;

  BoulderingRouteNotifier(
    this._cloudNotifier
  ) : super((ErrorState.none(),null));

/// Sets the [state] value, taking a [BoulderingRouteModel] as an argument 
  void selectBoulderingRoute(BoulderingRouteModel? boulderingRoute) async {
    const String function = 'BoulderingRouteNotifier.selectBoulderingRoute()';
    state = (ErrorState.selected(), boulderingRoute);
    toLog(function: function);
  }

/// Calls the [fetchBoulderingRouteLikeAndDislikeCount], [fetchBoulderingRouteRating], and [fetchBoulderingRouteCommunityDifficultyRating]
/// methods from the [CloudNotifier] and changes the internal [state] of the [BoulderingRouteNotifier]
/// depending on the [ErrorState] 
  Future<void> cloudSyncBoulderingRoute(BoulderingRouteModel boulderingRoute) async {
    const String function = 'BoulderingRouteNotifier.cloudSyncBoulderingRoute()';
    state = (ErrorState.loading(), boulderingRoute);
    toLog(function: function);
    
    String routeID = boulderingRoute.routeID!;

    final (
      ErrorState likeErrorState, 
      int? likes, 
      int? dislikes
      ) = await _cloudNotifier.fetchBoulderingRouteLikeAndDislikeCount(routeID);
    
    if (likeErrorState.isNotNull() || likes == null || dislikes == null) {
      state = (likeErrorState, null);
      return;
    }
    
    final (
      ErrorState ratingErrorState, 
      double? rating
      ) = await _cloudNotifier.fetchBoulderingRouteRating(routeID);

    if (rating == null) {
      state = (ratingErrorState, null);
      return;
    }

    final (
      ErrorState difficultyErrorState, 
      BoulderingDifficultyDistributionModel? difficultyDistribution
      ) = await _cloudNotifier.fetchBoulderingRouteCommunityDifficultyRating(routeID);

    if (difficultyErrorState.isNotNull() || difficultyDistribution == null) {
      state = (difficultyErrorState, null);
      return;
    }

    boulderingRoute.likes = likes;
    boulderingRoute.dislikes = dislikes;
    boulderingRoute.rating = rating;
    boulderingRoute.communityDifficultyRating = difficultyDistribution;

    state = (ErrorState.none(), boulderingRoute);
  }

/// Calls the [uploadCurrentBoulderingRouteReview] method from the [CloudNotifier]
  Future<ErrorState> uploadCurrentBoulderingRouteReview(String routeID, double rating, String? text) async {
    const String function = 'BoulderingRouteNotifier.uploadCurrentBoulderingRouteReview()';
    toLog(function: function);
    return await _cloudNotifier.uploadCurrentBoulderingRouteReview(routeID, rating, text);
    
  }

/// Calls the [uploadCurrentBoulderingRouteCommunityDifficultyRating] method from the [CloudNotifier]
  Future<ErrorState> uploadCurrentBoulderingRouteCommunityDifficultyRating(String routeID, int difficultyRating) async {
    const String function = 'BoulderingRouteNotifier.uploadCurrentBoulderingRouteCommunityDifficultyRating()';
    toLog(function: function);
    return await _cloudNotifier.uploadCurrentBoulderingRouteCommunityDifficultyRating(routeID, difficultyRating);
  }

/// Calls the [fetchBoulderingRouteByBoulderingRouteID] method from the [CloudNotifier]
  Future<(ErrorState, BoulderingRouteModel?)> fetchBoulderingRouteByBoulderingRouteID(String routeID) async {
    const String function = 'BoulderingRouteNotifier.fetchBoulderingRouteByBoulderingRouteID()';
    toLog(function: function);
    return await _cloudNotifier.fetchBoulderingRouteByBoulderingRouteID(routeID);
  }

/// Calls the [uploadCurrentBoulderingRouteLikeOrDislike] method from the [CloudNotifier]
  Future<ErrorState> uploadCurrentBoulderingRouteLikeOrDislike(String routeID, bool isLike) async {
    const String function = 'BoulderingRouteNotifier.uploadCurrentBoulderingRouteLikeOrDislike()';
    toLog(function: function);
    return await _cloudNotifier.uploadCurrentBoulderingRouteLikeOrDislike(routeID, isLike);
  }

/// Calls the [hasLiked] method from the [CloudNotifier]
  Future<(ErrorState, String?)> hasLiked(String routeID) async {
    const String function = 'BoulderingRouteNotifier.hasLiked()';
    toLog(function: function);
    return await _cloudNotifier.hasLiked(routeID);
  }

/// Calls the [hasDisliked] method from the [CloudNotifier]
  Future<(ErrorState, String?)> hasDisliked(String routeID) async {
    const String function = 'BoulderingRouteNotifier.hasDisliked()';
    toLog(function: function);
    return await _cloudNotifier.hasDisliked(routeID);
  }

/// Calls the [removeLikeOrDislikeByID] method from the [CloudNotifier]
  Future<ErrorState> removeLikeOrDislikeByID(String id, bool isLike) async {
    const String function = 'BoulderingRouteNotifier.removeLikeOrDislikeByID()';
    toLog(function: function);
    return await _cloudNotifier.removeLikeOrDislikeByID(id, isLike);
  } 

/// Changes the [state] to ([ErrorState.none],null)
  void reset() {
    const String function = 'BoulderingRouteNotifier.reset()';
    state = (ErrorState.none(),null);
    toLog(function: function);
  }

  void toLog({
    required String function
  }) {
    
    final (
      ErrorState errorState,
      BoulderingRouteModel? boulderingRoute
      ) = state;
    
    log('\nState: ${errorState.state}\nFunction: $function\nContext: $boulderingRoute');
  }

}