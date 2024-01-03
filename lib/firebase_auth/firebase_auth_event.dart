part of 'firebase_auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AutoLogin extends AuthEvent {}

class Login extends AuthEvent {
  final FirebaseAuthUser firebaseAuthUser;
  Login(this.firebaseAuthUser);
}

class Logout extends AuthEvent {}

class Refresh extends AuthEvent {}

class UpdateUser extends AuthEvent {
  final FirebaseAuthUser firebaseAuthUser;
  UpdateUser(this.firebaseAuthUser);
}
