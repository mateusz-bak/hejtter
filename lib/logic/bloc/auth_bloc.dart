import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hejtter/models/session.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const UnauthorizedAuthState()) {
    on<LogInAuthEvent>((event, emit) async {
      await hejtoApi.getProviders();

      final csrfToken = await hejtoApi.getCSRFToken();

      await hejtoApi.postCredentials(
        csrfToken,
        event.username,
        event.password,
      );

      final session = Session.fromJson(
        jsonDecode(await hejtoApi.getSession()),
      );

      if (_validateSession(session)) {
        emit(AuthorizedAuthState(
          accessToken: session.accessToken!,
          accessTokenExpiry: session.accessTokenExpiry!,
          expires: session.expires!,
        ));

        event.onSuccess();
      } else {
        emit(const UnauthorizedAuthState());
        event.onFailure();
      }
    });
    on<SkipLoginAuthEvent>((event, emit) async {
      event.onSuccess();
      emit(const LoginSkippedAuthState());
    });
    on<LogOutAuthEvent>((event, emit) async {
      emit(const UnauthorizedAuthState());
    });
  }

  bool _validateSession(Session session) {
    if (session.accessToken == null) return false;
    if (session.accessTokenExpiry == null) return false;
    if (session.expires == null) return false;

    return true;
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    final authorized = json['authorized'] as bool;
    final accessToken = json['access_token'] as String?;
    final accessTokenExpiry = json['access_token_expiry'] as int?;
    final expires = json['expires'] as String?;
    final loginSkipped = json['login_skipped'] as bool?;

    if (authorized == true &&
        accessToken != null &&
        accessTokenExpiry != null &&
        expires != null) {
      return AuthorizedAuthState(
        accessToken: accessToken,
        accessTokenExpiry: accessTokenExpiry,
        expires: DateTime.parse(expires),
      );
    } else {
      if (loginSkipped == true) {
        return const LoginSkippedAuthState();
      } else {
        return const UnauthorizedAuthState();
      }
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthorizedAuthState) {
      return {
        'authorized': true,
        'access_token': state.accessToken,
        'access_token_expiry': state.accessTokenExpiry,
        'expires': state.expires.toIso8601String(),
        'login_skipped': false,
      };
    } else if (state is LoginSkippedAuthState) {
      return {
        'authorized': false,
        'access_token': null,
        'access_token_expiry': null,
        'expires': null,
        'login_skipped': true,
      };
    } else {
      return {
        'authorized': false,
        'access_token': null,
        'access_token_expiry': null,
        'expires': null,
        'login_skipped': false,
      };
    }
  }
}
