class BoulderingWallFacilitiesModel {

  bool hasToilet;
  bool hasShower;
  bool hasGym;
  bool hasFood;
  bool hasParking;

  BoulderingWallFacilitiesModel({
    this.hasToilet = false,
    this.hasShower = false,
    this.hasGym = false,
    this.hasFood = false,
    this.hasParking = false
  });

  Map<String,dynamic> toMap() {
    return {
      'has_toilet': hasToilet,
      'has_shower': hasShower,
      'has_gym': hasGym,
      'has_food': hasFood,
      'has_parking': hasParking
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }

  factory BoulderingWallFacilitiesModel.fromMap(Map<String,dynamic> map) {
    bool hasToilet = map['has_toilet'];
    bool hasShower = map['has_shower'];
    bool hasGym = map['has_gym'];
    bool hasFood = map['has_food'];
    bool hasParking = map['has_parking'];
    return BoulderingWallFacilitiesModel(
      hasToilet: hasToilet,
      hasShower: hasShower,
      hasGym: hasGym,
      hasFood: hasFood,
      hasParking: hasParking
    );
  }
}