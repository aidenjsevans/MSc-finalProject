class ProjectLibraryContainsModel {

  final String userID;
  final String routeID;
  final int projectLibraryID;

  ProjectLibraryContainsModel({
    required this.userID,
    required this.routeID,
    required this.projectLibraryID
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userID,
      'route_id': routeID,
      'pl_id': projectLibraryID 
    };   
  }
}