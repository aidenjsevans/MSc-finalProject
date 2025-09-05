class BoulderingRouteReview {

  final String reviewID;
  final String userID;
  final String routeID;
  final int rating;
  final String? text;

  BoulderingRouteReview({
    required this.reviewID,
    required this.userID,
    required this.routeID,
    required this.rating,
    this.text
  });
}