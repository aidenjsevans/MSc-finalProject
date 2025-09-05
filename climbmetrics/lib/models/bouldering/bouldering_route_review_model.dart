class BoulderingRouteReviewModel {
  
  final String? reviewID;
  final String userID;
  final String routeID;
  final double rating;
  final String? text;

  BoulderingRouteReviewModel({
    required this.reviewID,
    required this.userID,
    required this.routeID,
    required this.rating,
    this.text
  });

  Map<String,dynamic> toCloudMap() {
    return {
      'user_id': userID,
      'route_id': routeID,
      'rating': rating,
      'text': text
    };
  }

  factory BoulderingRouteReviewModel.fromFirestoreMap(String reviewID, Map<String,dynamic> map) {
    final String userID = map['user_id'];
    final String routeID = map['route_id'];
    final double rating = map['rating'];
    final String text = map['text'];
    return BoulderingRouteReviewModel(
      reviewID: reviewID,
      userID: userID, 
      routeID: routeID, 
      rating: rating,
      text: text
    );
  }
}