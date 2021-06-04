import 'package:get/get.dart';

class Credentials {
  final String userName;

  Credentials({
    required this.userName,
  });
}

class LoginState {
  final Rx<bool> isLoggedIn;
  final Rx<Credentials?> credentials;

  LoginState({
    bool isLoggedIn = true,
    Credentials? credentials,
  })
      : isLoggedIn = isLoggedIn.obs
      , credentials = credentials.obs;
}
