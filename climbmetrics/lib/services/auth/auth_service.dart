
//  The use of am AuthService abstract class means that there is a blueprint from which
//  various authentication service subclasses can inherit. This means that implementation of, 
//  for example, Google and Apple authentication will be easier in the future.

abstract class AuthService {

  bool isInitialized = false;

  void initialize() {
    isInitialized = true;
  }

  void getCurrentUser() {}

  void register(String email, String password) {}

  void logIn(String email, String password) {}

  void logOut() {}

  void sendEmailVerification() {}

  void reload() {}
}



