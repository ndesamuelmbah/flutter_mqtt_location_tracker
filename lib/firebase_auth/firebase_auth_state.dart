part of 'firebase_auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthUnknown extends AuthState {}

class Authenticated extends AuthState {
  final FirebaseAuthUser firebaseAuthUser;

  Authenticated(this.firebaseAuthUser) {
    getIt<GeneralBox>()
        .put(Keys.authenticatedTime, DateTime.now().millisecondsSinceEpoch);
  }
}

class AuthRefreshing extends Authenticated {
  AuthRefreshing(FirebaseAuthUser firebaseAuthUser) : super(firebaseAuthUser);
}

class UnAuthenticated extends AuthState {}
