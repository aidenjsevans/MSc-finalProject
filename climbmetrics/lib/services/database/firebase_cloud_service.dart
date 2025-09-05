import 'package:climbmetrics/core/utils/constants.dart';
import 'package:climbmetrics/core/utils/error_state.dart';
import 'package:climbmetrics/core/utils/generate_id.dart';
import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_route_review_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_wall_model.dart';
import 'package:climbmetrics/services/auth/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The [FirebaseCloudService] provides various CRUD operations and utilities to interact with
/// the Firestore cloud database. It takes the [FirebaseAuthService] as a constructor argument so it can
/// use its services
class FirebaseCloudService {

  FirebaseFirestore? _firebaseFirestore;
  final FirebaseAuthService _firebaseAuthService;

  FirebaseCloudService(
    this._firebaseAuthService
  );


//  UTILITY---------------------------------------------------------------------------------------------------------------------------------------

/// Connects the [FirebaseCloudService] to the [FirebaseFirestore] instance
/// 
/// Returns the [FirebaseFirestore] instance alongside an [ErrorState]. If an error occurs, the returned
/// [FirebaseFirestore] is null
  (ErrorState,FirebaseFirestore?) initializeFF() {
    const String function = 'FirebaseCloudService.initialize()';
    try {
      final firebaseFirestore = FirebaseFirestore.instance;
      _firebaseFirestore = firebaseFirestore;
      return (ErrorState.none(), _firebaseFirestore);
    } on FirebaseException catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: '${e.code}\n\n${e.toString()}'
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, null);
    }
  }

/// Getter for the [FirebaseFirestore] instance
/// 
/// If there is already a [FirebaseFirestore] instance, the method will
/// return the [FirebaseFirestore] alongside its [ErrorState]. Otherwise,
/// the method will call [initializeFF]
  (ErrorState,FirebaseFirestore?) get firebaseFirestore {
    if (_firebaseFirestore != null) {
      return (ErrorState(), _firebaseFirestore!);
    } else {
      return initializeFF();
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  BOULDERING ROUTE------------------------------------------------------------------------------------------------------------------------------

/// Uploads a [BoulderingRouteModel] to the bouldering_route collection
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingRoute(BoulderingRouteModel boulderingRoute) async {
    const String function = 'FirebaseCloudService.uploadBoulderingRoute()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    try {
      if (boulderingRoute.routeID == null) {
        String generatedRouteID = generateID();
        boulderingRoute.routeID = generatedRouteID;
      }
      await ff!.collection(
        boulderingRouteCollectionName).doc(
          boulderingRoute.routeID).set(
            boulderingRoute.toMap());
      return ErrorState.none();      
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return uploadErrorState;
        case 'already-exists':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: ${boulderingRoute.routeID}'
        );
        return uploadErrorState;          
        case 'deadline-exceeded':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return uploadErrorState;          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Fetches a list of [BoulderingRouteModel] from the bouldering_route_contains collection, taking a [boulderingWallID] as
/// an argument
/// 
/// Returns a list of [BoulderingRouteModel] alongside an [ErrorState]. If an error occurs, the
/// returned list of [BoulderingRouteModel] is null
  Future<(ErrorState,List<BoulderingRouteModel>)> fetchBoulderingRouteListByBoulderingWallID(String boulderingWallID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteListByBoulderingWallID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, [BoulderingRouteModel.placeholder()]);
    }
    
    try {
      
      QuerySnapshot snapshot = await ff!.collection(
        boulderingWallContainsCollectionName).where(
          FieldPath.documentId, isEqualTo: boulderingWallID).get();
      
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.boulderingWallNotFound, 
          function: 'FirebaseCloudService.fetchBoulderingRouteListByBoulderingWallID()', 
          context: 'Bouldering Wall ID: $boulderingWallID'
        );
        return (queryErrorState, [BoulderingRouteModel.placeholder()]);   
      }
      
      final List<String> boulderingRouteIDList = [];
      
      for (final boulderingWallContainsDoc in snapshot.docs) {
        Map<String,dynamic> boulderingWallContainsMap = boulderingWallContainsDoc.data() as Map<String,dynamic>;
        boulderingRouteIDList.add(boulderingWallContainsMap['route_id']);
      }
      
      final List<BoulderingRouteModel> boulderingRouteList = []; 
      for (String routeID in boulderingRouteIDList) {
        QuerySnapshot snapshot = await ff.collection(
          boulderingRouteCollectionName).where(
            FieldPath.documentId, isEqualTo: routeID).limit(1).get();
        if (snapshot.docs.isEmpty) {
          final queryErrorState = ErrorState.cloud(
            error: CloudError.boulderingRouteNotFound, 
            function: 'FirebaseCloudService.fetchBoulderingRouteListByBoulderingWallID()', 
            context: 'Route ID: $routeID, Bouldering Wall ID: $boulderingWallID'
          );
          return (queryErrorState, [BoulderingRouteModel.placeholder()]);
        }
        Map<String,dynamic> boulderingRouteMap = snapshot.docs.first.data() as Map<String,dynamic>;
        boulderingRouteList.add(BoulderingRouteModel.fromMap(routeID, boulderingRouteMap));
      }
      final buffer = StringBuffer();
      buffer.writeln('\n\tBouldering wall ID: $boulderingWallID');
      for (final boulderingRoute in boulderingRouteList) {
        buffer.writeln('\tBouldering route ID: ${boulderingRoute.routeID}');
      }
      return (ErrorState.none(
        function: function,
        context: buffer.toString()), boulderingRouteList);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState, [BoulderingRouteModel.placeholder()]);
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState, [BoulderingRouteModel.placeholder()]);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState, [BoulderingRouteModel.placeholder()]);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState, [BoulderingRouteModel.placeholder()]);
    }
  }

/// Fetches a [BoulderingRouteModel] from the bouldering_route_contains collection, taking a [routeID] as
/// an argument
/// 
/// Returns a [BoulderingRouteModel] alongside an [ErrorState]. If an error occurs, the
/// returned [BoulderingRouteModel] is null
  Future<(ErrorState, BoulderingRouteModel?)> fetchBoulderingRouteByBoulderingRouteID(String routeID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteByBoulderingRouteID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }

    try {
      QuerySnapshot snapshot = await ff!
      .collection(boulderingRouteCollectionName)
      .where(FieldPath.documentId, isEqualTo: routeID)
      .limit(1).get();
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.boulderingRouteNotFound, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return (queryErrorState,null); 
      }
      Map<String,dynamic> boulderingRouteMap = snapshot.docs.first.data() as Map<String,dynamic>;
      final boulderingRoute = BoulderingRouteModel.fromMap(routeID, boulderingRouteMap);
      return (ErrorState.none(), boulderingRoute);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Uploads a [BoulderingRouteReviewModel] to the bouldering_route_reviews collection
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingRouteReview(BoulderingRouteReviewModel review) async {
    const String function = 'FirebaseCloudService.uploadBoulderingRouteReview()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    try {
      
      await ff!
      .collection(boulderingRouteReviewsCollectionName)
      .doc(review.reviewID)
      .set(review.toCloudMap());

      return ErrorState.none(
        function: function,
        context: 'ReviewID: ${review.reviewID}\nUser ID: ${review.userID}\nRoute ID: ${review.routeID}\nRating: ${review.rating}/10'
      );

    } on FirebaseException catch (e) {
        switch (e.code) {
          case 'unavailable':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.cloudUnavailable, 
            function: function, 
            context: null
          );
          return uploadErrorState;
          case 'already-exists':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.documentIdAlreadyExists, 
            function: function, 
            context: 'Review ID: $review'
          );
          return uploadErrorState;          
          case 'deadline-exceeded':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.timeout, 
            function: function, 
            context: null
          );
          return uploadErrorState;          
          default:
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
  }

/// Uploads a [BoulderingRouteReviewModel] to the bouldering_route_reviews collection, taking the current session [userID],
/// [routeID], [rating], and [text] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadCurrentBoulderingRouteReview(String routeID, double rating, String? text) async {
    const String function = 'FirebaseCloudService.uploadCurrentBoulderingRouteReview()';
    
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    if (firebaseUser == null) {
      final errorState = ErrorState.cloud(
        error: CloudError.notLoggedIn, 
        function: function, 
        context: null
      );
      return errorState;
    }

    String userID = firebaseUser.uid;
    String reviewID;

    final (
      ErrorState checkErrorState, 
      String? currentReviewID
    ) = await hasReviewed(routeID);
    
    if (checkErrorState.isNull() && currentReviewID != null) {
      reviewID = currentReviewID;
    } else {
      reviewID = generateID();
    }
    
    final review = BoulderingRouteReviewModel(
      reviewID: reviewID,
      userID: userID, 
      routeID: routeID, 
      rating: rating,
      text: text
    );

    return await uploadBoulderingRouteReview(review);
  }

/// Fetches a list of [BoulderingRouteReviewModel] from the bouldering_route_reviews collection, taking a [routeID] as an argument
/// 
/// Returns a list of [BoulderingRouteReviewModel] alongside an [ErrorState]. If an error occurs, the returned
/// list of [BoulderingRouteReviewModel] is null
  Future<(ErrorState, List<BoulderingRouteReviewModel>?)> fetchBoulderingRouteReviewListByRouteID(String routeID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteReviewListByRouteID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    try {
      
      QuerySnapshot snapshot = await ff!
      .collection(boulderingRouteReviewsCollectionName)
      .where('route_id', isEqualTo: routeID)
      .get();

      if (snapshot.docs.isEmpty) {
      final queryErrorState = ErrorState.cloud(
        error: CloudError.boulderingRouteReviewListNotFound, 
        function: function, 
        context: 'Route ID: $routeID'
      );
      return (queryErrorState,null);
      }

      List<BoulderingRouteReviewModel> reviewList = [];

      for (final doc in snapshot.docs) {
        String userID = doc.id;
        Map<String,dynamic> reviewMap = doc.data() as Map<String,dynamic>;
        reviewList.add(BoulderingRouteReviewModel.fromFirestoreMap(userID, reviewMap));
      }

      final buffer = StringBuffer();
      buffer.writeln('\n\tRoute ID: $routeID');

      for (final review in reviewList) {
        buffer.writeln('\t\tUser ID: ${review.userID}');
        buffer.writeln('\t\tRating: ${review.rating}');
        buffer.writeln('\t\tText: ${review.text}');
      }

      return (ErrorState.none(
        function: function,
        context: buffer.toString()
        ), reviewList);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Fetches the number of likes and dislikes a [BoulderingRouteModel] has received, taking a [routeID] as an argument
/// 
/// Returns the [likeCount], [dislikeCount], and an [ErrorState]. If an error occurs, the
/// returned [likeCount] and [dislikeCount] are null
  Future<(ErrorState, int?, int?)> fetchBoulderingRouteLikeAndDislikeCount(String routeID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteLikeCount()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null,null);
    }
    
    try {
      
      AggregateQuerySnapshot likeSnapshot = await ff!
      .collection(boulderingRouteLikesCollectionName)
      .where('route_id', isEqualTo: routeID)
      .count()
      .get();

      final int? likeCount = likeSnapshot.count;

      AggregateQuerySnapshot dislikeSnapshot = await ff
      .collection(boulderingRouteDislikesCollectionName)
      .where('route_id', isEqualTo: routeID)
      .count()
      .get();

      final int? dislikeCount = dislikeSnapshot.count;

      if (likeCount == null || dislikeCount == null) {
        final ErrorState errorState = ErrorState.cloud(
          error: CloudError.aggregrateError, 
          function: function, 
          context: null
        );
        return (errorState,null,null);
      }
      return (ErrorState.none(
        function: function,
        context: 'Route ID: $routeID, Likes: $likeCount, Dislikes: $dislikeCount'), likeCount, dislikeCount);
    
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null,null);
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);
    }
  }

/// Fetches a [BoulderingRouteModel] rating, taking a [routeID] as an argument
/// 
/// Returns the [rating] alongside an [ErrorState]. If an error occurs, the returned
/// [rating] is null
  Future<(ErrorState, double?)> fetchBoulderingRouteRating(String routeID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteRating()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }

    try {

      AggregateQuerySnapshot snapshot = await ff!
      .collection(boulderingRouteReviewsCollectionName)
      .where('route_id', isEqualTo: routeID)
      .aggregate(average('rating'))
      .get();

      double? rating = snapshot.getAverage('rating');

      if (rating == null) {
        final ErrorState errorState = ErrorState.cloud(
          error: CloudError.aggregrateError, 
          function: function, 
          context: null
        );
        return (errorState,0.0);
      }
      return (ErrorState.none(
        function: function,
        context: 'Route ID: $routeID, Rating: $rating'), rating);

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Uploads a [BoulderingRouteModel] like or dislike, taking a [userID], [routeID], and [isLike] as arguments.
/// If [isLike] is true, a like is uploaded, otherwise a dislike is uploaded
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingRouteLikeOrDislike(String userID, String routeID, bool isLike) async {
    const String function = 'FirebaseCloudService.uploadBoulderingRouteLikeOrDislike()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    try {
      String collectionName;

      if (isLike) {
        collectionName = boulderingRouteLikesCollectionName;
      } else {
        collectionName = boulderingRouteDislikesCollectionName;
      }

      String id = generateID();

      await ff!
      .collection(collectionName)
      .doc(id)
      .set({
        'user_id': userID,
        'route_id': routeID
      });
      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Route ID: $routeID'
      );

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return uploadErrorState;
        case 'already-exists':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return uploadErrorState;          
        case 'deadline-exceeded':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return uploadErrorState;          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Uploads a [BoulderingRouteModel] like or dislike to the bouldering_route_likes or
/// bouldering_route_dislikes collection, taking the current session [userID], [routeID], and [isLike] as arguments.
/// If [isLike] is true, a like is uploaded, otherwise a dislike is uploaded
/// 
/// Returns an [ErrorState] 
  Future<ErrorState> uploadCurrentBoulderingRouteLikeOrDislike(String routeID, bool isLike) async {
    const String function = 'FirebaseCloudService.uploadCurrentBoulderingRouteLikeOrDislike()';

    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    if (firebaseUser == null) {
      final errorState = ErrorState.cloud(
        error: CloudError.notLoggedIn, 
        function: function, 
        context: null
      );
      return errorState;
    }

    String userID = firebaseUser.uid;
    return uploadBoulderingRouteLikeOrDislike(userID, routeID, isLike);
  }

/// Checks if a user has liked a [BoulderingRouteModel] in the bouldering_route_likes collection, taking the current session
/// [userID] and [routeID] as arguments
/// 
/// Returns the [likeID] alongside an [ErrorState]. If an error occurs, the returned
/// [likeID] is null
  Future<(ErrorState, String?)> hasLiked(String? routeID) async {
    
    const String function = 'FirebaseCloudService.hasLiked()';
    
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return (userErrorState,null);
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }

    String userID = firebaseUser!.uid;
    try {

      QuerySnapshot snapshot = await ff!
      .collection(boulderingRouteLikesCollectionName)
      .where('route_id', isEqualTo: routeID)
      .where('user_id', isEqualTo: userID)
      .get();

      if (snapshot.docs.isEmpty) {
        return (ErrorState.none(), null);
      }

      final likeID = snapshot.docs.first.id;
      return (ErrorState.none(), likeID);

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        case 'already-exists':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return (exceptionErrorState,null);          
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Checks if a user has disliked a [BoulderingRouteModel] in the bouldering_route_dislikes collection, taking the current session
/// [userID] and [routeID] as arguments
/// 
/// Returns the [dislikeID] alongside an [ErrorState]. If an error occurs, the returned
/// [dislikeID] is null
  Future<(ErrorState, String?)> hasDisliked(String routeID) async {
    
    const String function = 'FirebaseCloudService.hasDisliked()';
    
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return (userErrorState,null);
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }

    String userID = firebaseUser!.uid;
    try {

      QuerySnapshot snapshot = await ff!
      .collection(boulderingRouteDislikesCollectionName)
      .where('route_id', isEqualTo: routeID)
      .where('user_id', isEqualTo: userID)
      .get();

      if (snapshot.docs.isEmpty) {
        return (ErrorState.none(), null);
      }

      final dislikeID = snapshot.docs.first.id;
      return (ErrorState.none(), dislikeID);

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        case 'already-exists':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return (exceptionErrorState,null);          
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Removes a like or dislike from the bouldering_route_likes or bouldering_route_dislikes collection, taking
/// a [likeID] or [dislikeID] and [isLike] as arguments. If [isLike] is true, the bouldering_route_likes collection is searched,
/// otherwise the bouldering_route_dislikes is searched.
/// 
/// Returns an [ErrorState]
  Future<ErrorState> removeLikeOrDislikeByID(String? id, bool isLike) async {
    const String function = 'FirebaseCloudService.removeLikeOrDislikeByID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    try {
      String collectionName;

      if (isLike) {
        collectionName = boulderingRouteLikesCollectionName;
      } else {
        collectionName = boulderingRouteDislikesCollectionName;
      }

      await ff!
      .collection(collectionName)
      .doc(id)
      .delete();

      return ErrorState.none(
        function: function,
        context: 'isLike: $isLike, ID: $id'
      );

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return uploadErrorState;
        case 'already-exists':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'ID: $id'
        );
        return uploadErrorState;          
        case 'deadline-exceeded':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return uploadErrorState;          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Checks if a user has reviewed a [BoulderingRouteModel] in the bouldering_route_reviews collection, taking the current session
/// [userID] and [routeID] as arguments
/// 
/// Returns the [reviewID] alongside an [ErrorState]. If an error occurs, the returned
/// [reviewID] is null
  Future<(ErrorState,String?)> hasReviewed(String routeID) async {
    const String function = 'FirebaseCloudService.hasReviewed()';
    
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return (userErrorState,null);
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return (initErrorState, null);
    }

    String userID = firebaseUser!.uid;
    try {

      QuerySnapshot snapshot = await ff!
      .collection(boulderingRouteReviewsCollectionName)
      .where('route_id', isEqualTo: routeID)
      .where('user_id', isEqualTo: userID)
      .get();

      if (snapshot.docs.isEmpty) {
        return (ErrorState.none(), null);
      }

      final reviewID = snapshot.docs.first.id;
      return (ErrorState.none(), reviewID);

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        case 'already-exists':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return (exceptionErrorState,null);          
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

/// Checks if a user has given a grade for a [BoulderingRouteModel] in the bouldering_route_community_difficulty collection,
/// taking the current session [userID] and [routeID] as arguments
/// 
/// Returns the [id] alongside an [ErrorState]. If an error occurs, the returned [id]
/// is null
  Future<(ErrorState,String?)> hasDifficultyRated(String routeID) async {
      const String function = 'FirebaseCloudService.hasDifficultyRated()';
      
      final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
      if (userErrorState.isNotNull()) {
        return (userErrorState,null);
      }

      final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
      if (initErrorState.isNotNull()) {
        return (initErrorState, null);
      }

      String userID = firebaseUser!.uid;
      try {

        QuerySnapshot snapshot = await ff!
        .collection(boulderingRouteCommunityDifficultyCollectionName)
        .where('route_id', isEqualTo: routeID)
        .where('user_id', isEqualTo: userID)
        .get();

        if (snapshot.docs.isEmpty) {
          return (ErrorState.none(), null);
        }

        final id = snapshot.docs.first.id;
        return (ErrorState.none(), id);

      } on FirebaseException catch (e) {
        switch (e.code) {
          case 'unavailable':
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.cloudUnavailable, 
            function: function, 
            context: null
          );
          return (exceptionErrorState,null);
          case 'already-exists':
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.documentIdAlreadyExists, 
            function: function, 
            context: 'Route ID: $routeID'
          );
          return (exceptionErrorState,null);          
          case 'deadline-exceeded':
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.timeout, 
            function: function, 
            context: null
          );
          return (exceptionErrorState,null);          
          default:
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return (exceptionErrorState,null);
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    }

/// Uploads a user grade for a [BoulderingRouteModel], taking a [userID], [routeID], and
/// [difficultyRating] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingRouteCommunityDifficultyRating(String userID, String routeID, int difficultyRating) async {
    const String function = 'FirebaseCloudService.uploadBoulderingRouteCommunityDifficultyRating()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    try {

      String difficultyID;

      final (
        ErrorState checkErrorState, 
        String? currentDifficultyID
      ) = await hasDifficultyRated(routeID);
      
      if (checkErrorState.isNull() && currentDifficultyID != null) {
        difficultyID = currentDifficultyID;
      } else {
        difficultyID = generateID();
      }

      await ff!
      .collection(boulderingRouteCommunityDifficultyCollectionName)
      .doc(difficultyID)
      .set({
        'user_id': userID,
        'route_id': routeID,
        'difficulty': difficultyRating
      });
      return ErrorState.none(
        function: function,
        context: 'User ID: $userID, Route ID: $routeID, Difficulty rating: $difficultyRating'
      );

    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return uploadErrorState;
        case 'already-exists':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: $routeID'
        );
        return uploadErrorState;          
        case 'deadline-exceeded':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return uploadErrorState;          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

/// Uploads a user grade for a [BoulderingRouteModel], taking the current session [userID], [routeID], and
/// [difficultyRating] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadCurrentBoulderingRouteCommunityDifficultyRating(String routeID, int difficultyRating) async {
    const String function = 'FirebaseCloudService.uploadCurrentBoulderingRouteCommunityDifficultyRating()';
    
    final (ErrorState userErrorState, User? firebaseUser) = await _firebaseAuthService.user;
    if (userErrorState.isNotNull()) {
      return userErrorState;
    }

    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }

    if (firebaseUser == null) {
      final errorState = ErrorState.cloud(
        error: CloudError.notLoggedIn, 
        function: function, 
        context: null
      );
      return errorState;
    }

    String userID = firebaseUser.uid;


    return await uploadBoulderingRouteCommunityDifficultyRating(userID, routeID, difficultyRating);
  }

/// Fetches the [BoulderingDifficultyDistributionModel] of a [BoulderingRouteModel], taking a [routeID] as an argument
/// 
/// Returns the [BoulderingDifficultyDistributionModel] alongside an [ErrorState]. If an error occurs,
/// the returned [BoulderingDifficultyDistributionModel] is null
  Future<(ErrorState, BoulderingDifficultyDistributionModel?)> fetchBoulderingRouteCommunityDifficultyRating(String routeID) async {
    const String function = 'FirebaseCloudService.fetchBoulderingRouteCommunityDifficultyRating()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }

     try {
      final Map<String,dynamic> map = BoulderingDifficultyDistributionModel().toStringKeyMap();

      for (int i = 0; i < 18; i++) {
        AggregateQuerySnapshot snapshot = await ff!
        .collection(boulderingRouteCommunityDifficultyCollectionName)
        .where('route_id', isEqualTo: routeID)
        .where('difficulty', isEqualTo: i)
        .count()
        .get();

        int? count = snapshot.count;
        if (count == null) {
          map['v$i'] = 0;
        } else {
          map['v$i'] = count;
        }
      }
      return (ErrorState.none(
        function: function,
        context: 'Route ID: $routeID'
        ), BoulderingDifficultyDistributionModel.fromMap(map));
      
      } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        case 'deadline-exceeded':
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (exceptionErrorState,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  BOULDERING WALL-------------------------------------------------------------------------------------------------------------------------------

/// Uploads a [BoulderingWallModel] to the bouldering_wall_company_contains collection. If the [BoulderingWallModel]
/// [boulderingWallID] is null, the [generateID] method is called internally
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingWall(BoulderingWallModel boulderingWall) async {
    const String function = 'FirebaseCloudService.uploadBoulderingWall()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    try {
      if (boulderingWall.boulderingWallID == null) {
        String generatedWallID = generateID();
        boulderingWall.boulderingWallID = generatedWallID;
      }
      await ff!.collection(
        boulderingWallCompanyContainsCollectionName).doc(
          boulderingWall.boulderingWallID).set(
            boulderingWall.toMap());
      return ErrorState.none();   
    } on FirebaseException catch (e) {
        switch (e.code) {
          case 'unavailable':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.cloudUnavailable, 
            function: function, 
            context: null
          );
          return uploadErrorState;
          case 'already-exists':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.documentIdAlreadyExists, 
            function: function, 
            context: 'Route ID: ${boulderingWall.boulderingWallID}'
          );
          return uploadErrorState;          
          case 'deadline-exceeded':
          final uploadErrorState = ErrorState.cloud(
            error: CloudError.timeout, 
            function: function, 
            context: null
          );
          return uploadErrorState;          
          default:
          final exceptionErrorState = ErrorState.cloud(
            error: CloudError.exception, 
            function: function, 
            context: '${e.code}\n\n${e.toString()}'
          );
          exceptionErrorState.toLog();
          return exceptionErrorState;
        }
      } on Exception catch (e) {
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: e.toString()
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    }

/// Fetches a list of [BoulderingWallModel] from the bouldering_wall_company_contains collection, taking a [companyID]
/// as an argument
/// 
/// Returns a list of [BoulderingWallModel] alongside an [ErrorState]. If an error occurs, the returned
/// list of [BoulderingWallModel] is null
  Future<(ErrorState,List<BoulderingWallModel>?)> fetchBoulderingWallListByCompanyID(String companyID) async {
    
    const String function = 'FirebaseCloudService.fetchBoulderingWallListByCompanyID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null);
    }
    
    try {
      QuerySnapshot snapshot = await ff!.collection(
        boulderingWallCompanyContainsCollectionName).where(
          'company_id', isEqualTo: companyID).get();
      
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.boulderingWallListNotFound, 
          function: function, 
          context: 'Company ID: $companyID'
        );
        return (queryErrorState,null);
      }
      final List<BoulderingWallModel> boulderingWallModelList = [];
      for (var boulderingWallDoc in snapshot.docs) {
        String boulderingWallID = boulderingWallDoc.id;
        Map<String,dynamic> boulderingWallMap = boulderingWallDoc.data() as Map<String,dynamic>;
        boulderingWallModelList.add(BoulderingWallModel.fromMap(boulderingWallID, boulderingWallMap));
      }
      return (ErrorState.none(), boulderingWallModelList);
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null);
    } 
  }

/// Fetches a list of [BoulderingWallModel] from the bouldering_wall_company_contains collection, taking a [companyName]
/// as an argument
/// 
/// Returns a list of [BoulderingWallModel] alongside an [ErrorState]. If an error occurs, the returned
/// list of [BoulderingWallModel] is null
  Future<(ErrorState,String?,List<BoulderingWallModel>?)> fetchBoulderingWallListByCompanyName(String companyName) async {
    
    const String function = 'FirebaseCloudService.fetchBoulderingWallListByCompanyName()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState,null,null);
    }
    
    try {
      
      final String cleanCompanyName = companyName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
      QuerySnapshot snapshot = await ff!.collection(
        boulderingWallCompanyCollectionName).where(
          'company_name', isEqualTo: cleanCompanyName).limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.companyNotFound, 
          function: function, 
          context: 'Company Name: $companyName'
        );
        return (queryErrorState,null,null);
      }
      
      final String companyID = snapshot.docs.first.id;
      final (ErrorState fetchErrorState, List<BoulderingWallModel>? boulderingWallList) = await fetchBoulderingWallListByCompanyID(companyID);
      
      if (fetchErrorState.isNotNull() || boulderingWallList == null) {
        return (fetchErrorState,null,null);
      }
      
      Map<String,dynamic> companyData = snapshot.docs.first.data() as Map<String,dynamic>;
      final String displayName = companyData['display_name'];
      
      final buffer = StringBuffer();
      buffer.writeln('\n\tCompany name: $displayName');
      
      for (final boulderingWall in boulderingWallList) {
        buffer.writeln('\tBouldering wall ID: ${boulderingWall.boulderingWallID}');
      }
      
      return (ErrorState.none(
        function: function,
        context: buffer.toString()), displayName, boulderingWallList);  
    } on FirebaseException catch (e) {
      switch (e.code) {
        
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null,null);
        
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null,null);
        
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);
    }
  }

/// Fetches a [BoulderingWallModel] and its company name from the bouldering_wall_company_contains collection, taking a [boulderingWallID] as an
/// argument
/// 
/// Returns a [BoulderingWallModel], [displayName], and [ErrorState]. If an error occurs,
/// the returned [BoulderingWallModel] and [displayName]
  Future<(ErrorState,String?,BoulderingWallModel?)> fetchBoulderingWallByBoulderingWallID(String boulderingWallID) async {
    
    const String function = 'FirebaseCloudService.fetchBoulderingWallByBoulderingWallID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, '', BoulderingWallModel.placeholder());
    }

    try {
      QuerySnapshot snapshot = await ff!.collection(
        boulderingWallCompanyContainsCollectionName).where(
          FieldPath.documentId, isEqualTo: boulderingWallID).limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.boulderingWallNotFound, 
          function: function, 
          context: 'Bouldering Wall ID: $boulderingWallID'
        );
        return (queryErrorState,null,null);
      }
      
      final Map<String,dynamic> boulderingWallData = snapshot.docs.first.data() as Map<String,dynamic>;
      final String companyID = boulderingWallData['company_id'];
      final (ErrorState fetchErrorState, String? displayName) = await fetchCompanyDisplayNameByCompanyID(companyID);
      
      if (fetchErrorState.isNotNull() || displayName == null) {
        return (fetchErrorState,null,null);
      }
      
      final BoulderingWallModel boulderingWall = BoulderingWallModel.fromMap(boulderingWallID, boulderingWallData);            
      return (ErrorState.none(function: function), displayName, boulderingWall);

    } on FirebaseException catch (e) {
      switch (e.code) {
        
        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null,null);
        
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null,null);
        
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return (exceptionErrorState,null,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return (exceptionErrorState,null,null);
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  BOULDERING WALL CONTAINS----------------------------------------------------------------------------------------------------------------------

/// Uploads an entry to the bouldering_wall_contains collection, taking a [BoulderingWallModel] and [BoulderingRouteModel] as arguments
/// 
/// Returns an [ErrorState]
  Future<ErrorState> uploadBoulderingWallContains(BoulderingWallModel boulderingWall, BoulderingRouteModel boulderingRoute) async {
    const String function = 'FirebaseCloudService.uploadBoulderingWallContains()'; 
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    if (initErrorState.isNotNull()) {
      return initErrorState;
    }
    try {
      await ff!.collection(
        boulderingWallContainsCollectionName).doc(
          boulderingWall.boulderingWallID).set(
            {'route_id': boulderingRoute.routeID});
      return ErrorState.none();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'unavailable':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return uploadErrorState;
        case 'already-exists':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.documentIdAlreadyExists, 
          function: function, 
          context: 'Route ID: ${boulderingWall.boulderingWallID}'
        );
        return uploadErrorState;          
        case 'deadline-exceeded':
        final uploadErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return uploadErrorState;          
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        exceptionErrorState.toLog();
        return exceptionErrorState;
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      exceptionErrorState.toLog();
      return exceptionErrorState;
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------


//  COMPANY---------------------------------------------------------------------------------------------------------------------------------------

/// Fetches a company display name from the bouldering_wall_company collection, taking a [companyID] as an argument
/// 
/// Returns a [displayName] alongside an [ErrorState]. If an error occurs, the returned [displayName] is null
  Future<(ErrorState,String?)> fetchCompanyDisplayNameByCompanyID(String companyID) async {
    
    const String function = 'FirebaseCloudService.fetchCompanyDisplayNameByCompanyID()';
    final (ErrorState initErrorState, FirebaseFirestore? ff) = firebaseFirestore;
    
    if (initErrorState.isNotNull()) {
      return (initErrorState, '');
    }
    
    try {
      QuerySnapshot snapshot = await ff!.collection(
        boulderingWallCompanyCollectionName).where(
          FieldPath.documentId, isEqualTo: companyID).limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        final queryErrorState = ErrorState.cloud(
          error: CloudError.companyNotFound, 
          function: function, 
          context: 'Company ID: $companyID'
        );
        return (queryErrorState,null);
      }
      
      Map<String,dynamic> companyData = snapshot.docs.first.data() as Map<String,dynamic>;
      final String displayName = companyData['display_name'];
      return (ErrorState.none(
        function: function,
        context: 'Company ID: $companyID'), displayName
      );
    } on FirebaseException catch (e) {
      switch (e.code) {

        case 'unavailable':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.cloudUnavailable, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        
        case 'deadline-exceeded':
        final fetchErrorState = ErrorState.cloud(
          error: CloudError.timeout, 
          function: function, 
          context: null
        );
        return (fetchErrorState,null);
        
        default:
        final exceptionErrorState = ErrorState.cloud(
          error: CloudError.exception, 
          function: function, 
          context: '${e.code}\n\n${e.toString()}'
        );
        return (exceptionErrorState,null);
      }
    } on Exception catch (e) {
      final exceptionErrorState = ErrorState.cloud(
        error: CloudError.exception, 
        function: function, 
        context: e.toString()
      );
      return (exceptionErrorState,null);
    }
  }

//------------------------------------------------------------------------------------------------------------------------------------------------
}










