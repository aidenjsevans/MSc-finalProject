class BoulderingWallLinkModel {

  String userID;
  String boulderingWallID;
  String displayName;
  String city;
  String postcode;
  String street;

  BoulderingWallLinkModel({
    required this.userID,
    required this.boulderingWallID,
    required this.displayName,
    required this.city,
    required this.postcode,
    required this.street
  });

  Map<String,dynamic> toMap() {
    return {
      'bw_id': boulderingWallID,
      'user_id': userID,
      'display_name': displayName,
      'city': city,
      'postcode': postcode,
      'street': street
    };
  }

  factory BoulderingWallLinkModel.fromMap(Map<String,dynamic> map) {
    String boulderingWallID = map['bw_id'];
    String userID = map['user_id'];
    String displayName = map['display_name'];
    String city = map['city'];
    String postcode = map['postcode'];
    String street = map['street'];
    return BoulderingWallLinkModel(
      userID: userID, 
      boulderingWallID: boulderingWallID,
      displayName: displayName,
      city: city,
      postcode: postcode,
      street: street
    );
  }
}