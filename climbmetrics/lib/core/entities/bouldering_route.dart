
import 'package:climbmetrics/core/entities/bouldering_difficulty_distribution.dart';
import 'package:climbmetrics/models/bouldering/bouldering_style_model.dart';

class BoulderingRoute {

  String? routeID;
  final String? name;
  final String setter;
  final int isSetterAnonymous;
  final int officialDifficultyRating;
  final BoulderingDifficultyDistribution communityDifficultyRating;
  final String colour;
  final int likes;
  final int dislikes;
  final double rating;
  final int attempts;
  final BoulderingStylesModel styles;
  final int isCurrent;
  final String dateSet;

  BoulderingRoute({
    this.routeID,
    this.name,
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
}