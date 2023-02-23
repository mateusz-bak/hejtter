import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'package:hejtter/main.dart';
import 'package:hejtter/models/session.dart';
import 'package:hejtter/services/hejto_api.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(const UnauthorizedAuthState()) {
    on<LogInAuthEvent>((event, emit) async {
      await _getProviders();
      final token = await _getCsrfToken();
      final login = await _postCreds(token, event.username, event.password);

      if (login == null) {
        emit(const UnauthorizedAuthState());
        event.onFailure();
        return;
      }

      final session = Session.fromJson(jsonDecode(await _getSession()));

      if (_validateSession(session)) {
        await _saveUsernameAndPassword(event.username, event.password);
        await _saveAccessToken(session.accessToken!);

        emit(AuthorizedAuthState(
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
      await _clearSecureStorage();
      emit(const UnauthorizedAuthState());
    });
    on<LogInWithSavedCredentialsAuthEvent>((event, emit) async {
      final username = await _readUsername();
      final password = await _readPassword();

      if (username == null || password == null) {
        emit(const UnauthorizedAuthState());
        return;
      }

      await _getProviders();
      final token = await _getCsrfToken();
      final login = await _postCreds(token, username, password);

      if (login == null) {
        emit(const UnauthorizedAuthState());
        return;
      }

      final session = Session.fromJson(jsonDecode(await _getSession()));

      if (_validateSession(session)) {
        await _saveAccessToken(session.accessToken!);

        emit(AuthorizedAuthState(
          accessTokenExpiry: session.accessTokenExpiry!,
          expires: session.expires!,
        ));
      } else {
        emit(const UnauthorizedAuthState());
        return;
      }
    });
  }

  bool _validateSession(Session session) {
    if (session.accessToken == null) return false;
    if (session.accessTokenExpiry == null) return false;
    if (session.expires == null) return false;

    return true;
  }

  _getProviders() async {
    await hejtoApi.getProviders();
  }

  Future<String> _getCsrfToken() async {
    return await hejtoApi.getCSRFToken();
  }

  Future<String?> _postCreds(
    String csrfToken,
    String username,
    String password,
  ) async {
    return await hejtoApi.postCredentials(
      csrfToken,
      username,
      password,
    );
  }

  Future<dynamic> _getSession() async {
    return await hejtoApi.getSession();
  }

  _saveUsernameAndPassword(String username, String password) async {
    await secureStorage.write(
      key: 'user_name',
      value: username,
    );

    await secureStorage.write(
      key: 'user_password',
      value: password,
    );
  }

  Future<String?> _readUsername() async {
    return await secureStorage.read(
      key: 'user_name',
    );
  }

  Future<String?> _readPassword() async {
    return await secureStorage.read(
      key: 'user_password',
    );
  }

  _clearSecureStorage() async {
    await secureStorage.write(
      key: 'accessToken',
      value: null,
    );

    await secureStorage.write(
      key: 'user_name',
      value: null,
    );

    await secureStorage.write(
      key: 'user_password',
      value: null,
    );
  }

  _saveAccessToken(String accessToken) async {
    await secureStorage.write(
      key: 'accessToken',
      value: accessToken,
    );
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    final authorized = json['authorized'] as bool;
    final accessTokenExpiry = json['access_token_expiry'] as int?;
    final expires = json['expires'] as String?;
    final loginSkipped = json['login_skipped'] as bool?;

    if (authorized == true && accessTokenExpiry != null && expires != null) {
      return AuthorizedAuthState(
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
        'access_token_expiry': state.accessTokenExpiry,
        'expires': state.expires.toIso8601String(),
        'login_skipped': false,
      };
    } else if (state is LoginSkippedAuthState) {
      return {
        'authorized': false,
        'access_token_expiry': null,
        'expires': null,
        'login_skipped': true,
      };
    } else {
      return {
        'authorized': false,
        'access_token_expiry': null,
        'expires': null,
        'login_skipped': false,
      };
    }
  }
}
