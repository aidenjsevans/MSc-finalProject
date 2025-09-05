class ProjectLibraryModel {

    final String userID;
    final int projectLibraryID;
    final String name;
    final String? date;
    final String? tag;

    ProjectLibraryModel({
        required this.userID,
        required this.projectLibraryID,
        required this.name,
        required this.date,
        required this.tag,
    });

    factory ProjectLibraryModel.fromMap(Map<String,dynamic> map) {
      return ProjectLibraryModel(
        userID: map['user_id'], 
        name: map['name'],
        projectLibraryID: map['pl_id'],
        date: map['date'],
        tag: map['tag']
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'user_id': userID,
        'name': name,
        'pl_id': projectLibraryID,
        'date': date,
        'tag': tag,
      };   
    }
}
