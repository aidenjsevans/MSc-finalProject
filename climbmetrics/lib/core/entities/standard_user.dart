class StandardUser {
  
  final String userID;
  final String email;
  final String? username;

  StandardUser({
    required this.userID,
    required this.email,
    this.username
  });
}