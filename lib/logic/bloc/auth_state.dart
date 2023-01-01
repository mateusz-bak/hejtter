part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthorizedAuthState extends AuthState {
  final int accessTokenExpiry;
  final DateTime expires;

  const AuthorizedAuthState({
    required this.accessTokenExpiry,
    required this.expires,
  });

  @override
  List<Object?> get props => [
        accessTokenExpiry,
        expires,
      ];
}

class UnauthorizedAuthState extends AuthState {
  const UnauthorizedAuthState();

  @override
  List<Object?> get props => [];
}

class LoginSkippedAuthState extends AuthState {
  const LoginSkippedAuthState();

  @override
  List<Object?> get props => [];
}
