import 'dart:convert';
import 'package:climbmetrics/models/bouldering/bouldering_difficulty_distribution_model.dart';
import 'package:climbmetrics/models/bouldering/bouldering_style_model.dart';

class BoulderingRouteModel {

  String? routeID;
  final String name;
  final String setter;
  final bool isSetterAnonymous;
  final int officialDifficultyRating;
  BoulderingDifficultyDistributionModel communityDifficultyRating;
  final String colour;
  int likes;
  int dislikes;
  double rating;
  int attempts;
  BoulderingStylesModel styles;
  bool isCurrent;
  final String dateSet;

  BoulderingRouteModel({
    this.routeID,
    required this.name,
    required this.setter,
    required this.isSetterAnonymous,
    required this.officialDifficultyRating,
    required this.communityDifficultyRating,
    required this.colour,
    this.likes = 0,
    this.dislikes = 0,
    this.rating = 0,
    this.attempts = 0,
    required this.styles,
    required this.isCurrent,
    required this.dateSet
  });
 
  Map<String,dynamic> toMap({String? routeID}) {
    if (routeID == null) {
      return {
        "name": name,
        "setter": setter,
        "is_setter_anonymous": isSetterAnonymous,
        "official_difficulty_rating": officialDifficultyRating,
        "community_difficulty_rating": communityDifficultyRating.toStringKeyMap(),
        "colour": colour,
        "likes": likes,
        "dislikes": dislikes,
        "rating": rating,
        "attempts": attempts,
        "styles": styles.toMap(),
        "is_current": isCurrent,
        "date_set": dateSet
      };
    } else {
      return {
        "route_id": routeID,
        "name": name,
        "setter": setter,
        "is_setter_anonymous": isSetterAnonymous,
        "official_difficulty_rating": officialDifficultyRating,
        "community_difficulty_rating": communityDifficultyRating.toStringKeyMap(),
        "colour": colour,
        "likes": likes,
        "dislikes": dislikes,
        "rating": rating,
        "attempts": attempts,
        "styles": styles.toMap(),
        "is_current": isCurrent,
        "date_set": dateSet
      };      
    }
  }

  Map<String,dynamic> toSQLMap() {
    return {
      "route_id": routeID,
      "name": name,
      "setter": setter,
      "is_setter_anonymous": boolToInt(isSetterAnonymous),
      "official_difficulty_rating": officialDifficultyRating,
      "community_difficulty_rating": jsonEncode(communityDifficultyRating.toStringKeyMap()),
      "colour": colour,
      "likes": likes,
      "dislikes": dislikes,
      "rating": rating,
      "attempts": attempts,
      "styles": jsonEncode(styles.toMap()),
      "is_current": boolToInt(isCurrent),
      "date_set": dateSet
    }; 
  }

  factory BoulderingRouteModel.fromMap(String routeID, Map<String,dynamic> map) {
    final String name = map['name'];
    final String setter = map['setter'];
    final bool isSetterAnonymous = map['is_setter_anonymous'];
    final int officialDifficultyRating = map['official_difficulty_rating'];
    final communityDifficultyRating = BoulderingDifficultyDistributionModel.fromMap(map['community_difficulty_rating']);
    final String colour = map['colour'];
    final int likes = map['likes'];
    final int dislikes = map['dislikes'];
    final double rating = map['rating'];
    final int attempts = map['attempts'];
    final styles = BoulderingStylesModel.fromMap(map['styles']);
    final bool isCurrent = map['is_current'];
    final String dateSet = map['date_set'];
    return BoulderingRouteModel(
      routeID: routeID,
      name: name,
      setter: setter, 
      isSetterAnonymous: isSetterAnonymous, 
      officialDifficultyRating: officialDifficultyRating, 
      communityDifficultyRating: communityDifficultyRating, 
      colour: colour,
      likes: likes,
      dislikes: dislikes,
      rating: rating,
      attempts: attempts,
      styles: styles, 
      isCurrent: isCurrent, 
      dateSet: dateSet
    );
  }

  factory BoulderingRouteModel.fromSQLmap(Map<String,dynamic> map) {
    final String routeID = map['route_id'];    
    final String name = map['name'];
    final String setter = map['setter'];
    final int isSetterAnonymous = map['is_setter_anonymous'];
    final int officialDifficultyRating = map['official_difficulty_rating'];
    final communityDifficultyRating = BoulderingDifficultyDistributionModel.fromMap(jsonDecode(map['community_difficulty_rating']));
    final String colour = map['colour'];
    final int likes = map['likes'];
    final int dislikes = map['dislikes'];
    final double rating = map['rating'];
    final int attempts = map['attempts'];
    final styles = BoulderingStylesModel.fromMap(jsonDecode(map['styles']));
    final int isCurrent = map['is_current'];
    final String dateSet = map['date_set'];
    return BoulderingRouteModel(
      routeID: routeID,
      name: name,
      setter: setter, 
      isSetterAnonymous: (isSetterAnonymous == 1), 
      officialDifficultyRating: officialDifficultyRating, 
      communityDifficultyRating: communityDifficultyRating, 
      colour: colour,
      likes: likes,
      dislikes: dislikes,
      rating: rating,
      attempts: attempts,
      styles: styles, 
      isCurrent: (isCurrent == 1), 
      dateSet: dateSet
    );    
  }

  factory BoulderingRouteModel.placeholder() {
    return BoulderingRouteModel(
      routeID: '',
      name: '', 
      setter: '', 
      isSetterAnonymous: false, 
      officialDifficultyRating: 0, 
      communityDifficultyRating: BoulderingDifficultyDistributionModel(), 
      colour: '', 
      styles: BoulderingStylesModel(), 
      isCurrent: false, 
      dateSet: ''
    );
  }

  int boolToInt(bool val) {
    if (val == true) {
      return 1;
    } else {
      return 0;
    }
  }

  bool intToBool (int val) {
    if (val == 0) {
      return false;
    } else {
      return true;
    }
  }
}
