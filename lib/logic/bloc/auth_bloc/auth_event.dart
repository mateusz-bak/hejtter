part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class LogInAuthEvent extends AuthEvent {
  const LogInAuthEvent({
    required this.username,
    required this.password,
    required this.onSuccess,
    required this.onFailure,
  });

  final String username;
  final String password;
  final Function() onSuccess;
  final Function() onFailure;

  @override
  List<Object?> get props => [
        username,
        password,
        onSuccess,
      ];
}

class LogInWithSavedCredentialsAuthEvent extends AuthEvent {
  const LogInWithSavedCredentialsAuthEvent();

  @override
  List<Object?> get props => [];
}

class LogOutAuthEvent extends AuthEvent {
  const LogOutAuthEvent();

  @override
  List<Object?> get props => [];
}

class SkipLoginAuthEvent extends AuthEvent {
  const SkipLoginAuthEvent({
    required this.onSuccess,
  });

  final Function() onSuccess;

  @override
  List<Object?> get props => [];
}
