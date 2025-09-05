import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/services/database/firebase_cloud_service.dart';
import 'package:climbmetrics/viewmodels/cloud/cloud_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The [CloudNotifier] provides various methods that can change its [state], which is of the 
/// type [CloudState]. It takes the [FirebaseCloudService] as a constructor
/// argument
class CloudNotifier extends StateNotifier<CloudState>{
  
  final FirebaseCloudService _cloudService;

  CloudNotifier(
    this._cloudService
  ) : super(CloudState.closed);

//  UTILITY---------------------------------------------------------------------------------------------------------------------------------------

/// Calls the [initializeFF] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  void initializeFF() {
    final (ErrorState errorState, FirebaseFirestore? ff) = _cloudService.initializeFF();
    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  BOULDERING WALL-------------------------------------------------------------------------------------------------------------------------------

/// Calls the [fetchBoulderingWallByBoulderingWallID] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, String?, BoulderingWallModel?)> fetchBoulderingWallByBoulderingWallID(String boulderingWallID) async {
  
    final (
      ErrorState errorState, 
      String? displayName, 
      BoulderingWallModel? boulderingWall) = await _cloudService.fetchBoulderingWallByBoulderingWallID(boulderingWallID
    );
    
    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.companyNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.boulderingWallNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }

    errorState.toLog();
    return (errorState, displayName, boulderingWall);
  }

/// Calls the [fetchBoulderingWallListByCompanyName] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState,String?,List<BoulderingWallModel>?)> fetchBoulderingWallListByCompanyName(String companyName) async {
    
    final (
      ErrorState errorState, 
      String? displayName, 
      List<BoulderingWallModel>? boulderingWallList) = await _cloudService.fetchBoulderingWallListByCompanyName(companyName
    );
    
    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.companyNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.boulderingWallNotFound:
      state = CloudState.nominal;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return (errorState, displayName, boulderingWallList);
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  BOULDERING ROUTE------------------------------------------------------------------------------------------------------------------------------

/// Calls the [fetchBoulderingRouteListByBoulderingWallID] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState,List<BoulderingRouteModel>)> fetchBoulderingRouteListByBoulderingWallID(String boulderingWallID) async {
    final (
      ErrorState errorState,
      List<BoulderingRouteModel> boulderingRouteList) = await _cloudService.fetchBoulderingRouteListByBoulderingWallID(boulderingWallID);
    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.companyNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.boulderingRouteNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.boulderingWallNotFound:
      state = CloudState.nominal;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
  errorState.toLog();
  return (errorState, boulderingRouteList);
  }

/// Calls the [fetchBoulderingRouteByBoulderingRouteID] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, BoulderingRouteModel?)> fetchBoulderingRouteByBoulderingRouteID(String routeID) async {
  final (
    ErrorState errorState, 
    BoulderingRouteModel? boulderingRoute
    ) = await _cloudService.fetchBoulderingRouteByBoulderingRouteID(routeID);
  
  switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.companyNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.boulderingRouteNotFound:
      state = CloudState.nominal;
      break;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
  
  errorState.toLog();
  return (errorState, boulderingRoute);

}

/// Calls the [fetchBoulderingRouteLikeAndDislikeCount] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, int?, int?)> fetchBoulderingRouteLikeAndDislikeCount(String routeID) async {
    final (
      ErrorState errorState, 
      int? likes, 
      int? dislikes
      ) = await _cloudService.fetchBoulderingRouteLikeAndDislikeCount(routeID);

    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.aggregrateError:
      state = CloudState.nominal;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return (errorState, likes, dislikes);
  }

/// Calls the [fetchBoulderingRouteRating] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, double?)> fetchBoulderingRouteRating(String routeID) async {
    final (
      ErrorState errorState, 
      double? rating
      ) = await _cloudService.fetchBoulderingRouteRating(routeID);

  switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.aggregrateError:
      state = CloudState.nominal;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return (errorState, rating);
  }

/// Calls the [fetchBoulderingRouteCommunityDifficultyRating] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, BoulderingDifficultyDistributionModel?)> fetchBoulderingRouteCommunityDifficultyRating(String routeID) async {
    final (
      ErrorState errorState, 
      BoulderingDifficultyDistributionModel?  difficultyDistribution
      ) = await _cloudService.fetchBoulderingRouteCommunityDifficultyRating(routeID);
    
    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.aggregrateError:
      state = CloudState.nominal;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return (errorState, difficultyDistribution);
  }

/// Calls the [uploadCurrentBoulderingRouteReview] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<ErrorState> uploadCurrentBoulderingRouteReview(String routeID, double rating, String? text) async {
    final ErrorState errorState = await _cloudService.uploadCurrentBoulderingRouteReview(routeID, rating, text);

    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return errorState;
  }

/// Calls the [uploadCurrentBoulderingRouteCommunityDifficultyRating] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<ErrorState> uploadCurrentBoulderingRouteCommunityDifficultyRating(String routeID, int difficultyRating) async {
    final ErrorState errorState = await _cloudService.uploadCurrentBoulderingRouteCommunityDifficultyRating(routeID, difficultyRating);

    switch (errorState.state) {
      case null:
      state = CloudState.nominal;
      break;
      case CloudError.cloudUnavailable:
      state = CloudState.error;
      break;
      case CloudError.timeout:
      state = CloudState.nominal;
      break;
      case CloudError.exception:
      state = CloudState.error;
      break;
    }
    
    errorState.toLog();
    return errorState;
  }

/// Calls the [uploadCurrentBoulderingRouteLikeOrDislike] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<ErrorState> uploadCurrentBoulderingRouteLikeOrDislike(String routeID, bool isLike) async {
  final ErrorState errorState = await _cloudService.uploadCurrentBoulderingRouteLikeOrDislike(routeID, isLike);

  switch (errorState.state) {
    case null:
    state = CloudState.nominal;
    break;
    case CloudError.cloudUnavailable:
    state = CloudState.error;
    break;
    case CloudError.timeout:
    state = CloudState.nominal;
    break;
    case CloudError.exception:
    state = CloudState.error;
    break;
  }

  errorState.toLog();
  return errorState;
 }

/// Calls the [hasLiked] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, String?)> hasLiked(String routeID) async {
    final (
      ErrorState errorState,
      String? likeID
      ) = await _cloudService.hasLiked(routeID);
    
    switch (errorState.state) {
    case null:
    state = CloudState.nominal;
    break;
    case CloudError.cloudUnavailable:
    state = CloudState.error;
    break;
    case CloudError.timeout:
    state = CloudState.nominal;
    break;
    case CloudError.exception:
    state = CloudState.error;
    break;
  }

  errorState.toLog();
  return (errorState,likeID);
  }

/// Calls the [hasDisliked] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<(ErrorState, String?)> hasDisliked(String routeID) async {
    final (
      ErrorState errorState,
      String? dislikeID
      ) = await _cloudService.hasDisliked(routeID);
    
    switch (errorState.state) {
    case null:
    state = CloudState.nominal;
    break;
    case CloudError.cloudUnavailable:
    state = CloudState.error;
    break;
    case CloudError.timeout:
    state = CloudState.nominal;
    break;
    case CloudError.exception:
    state = CloudState.error;
    break;
  }

  errorState.toLog();
  return (errorState,dislikeID);
  }

/// Calls the [removeLikeOrDislikeByID] method from the [FirebaseCloudService] and changes the internal [state] of the [CloudNotifier]
/// depending on the [ErrorState] 
  Future<ErrorState> removeLikeOrDislikeByID(String id, bool isLike) async {
    final errorState = await _cloudService.removeLikeOrDislikeByID(id, isLike);

    switch (errorState.state) {
    case null:
    state = CloudState.nominal;
    break;
    case CloudError.cloudUnavailable:
    state = CloudState.error;
    break;
    case CloudError.timeout:
    state = CloudState.nominal;
    break;
    case CloudError.exception:
    state = CloudState.error;
    break;
  }

  errorState.toLog();
  return errorState;
  }

//------------------------------------------------------------------------------------------------------------------------------------------------
}