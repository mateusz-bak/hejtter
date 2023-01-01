import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc.dart';
import 'package:hejtter/main.dart';
import 'package:hejtter/models/posts_response.dart';

final hejtoApi = HejtoApi();

class HejtoApi {
  var cookieJar = CookieJar();
  var client = HttpClient();

  Future<dynamic> getProviders() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/providers',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    return stringData;
  }

  Future<dynamic> getCSRFToken() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/csrf',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    final token = jsonDecode(stringData)['csrfToken'];

    return token;
  }

  Future<dynamic> postCredentials(
    String csrfToken,
    String username,
    String password,
  ) async {
    final body = {
      'username': username,
      'password': password,
      'redirect': 'false',
      'json': 'true',
      'callbackUrl':
          'https://www.hejto.pl/wpis/czolem-kasie-i-tomki-wlasnie-wydalem-wersje-0-0-2-hejttera-niestety-dalej-bez-lo',
      'csrfToken': csrfToken,
    };

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/callback/credentials',
      ),
    );

    final cookies = await cookieJar.loadForRequest(
      Uri.https('www.hejto.pl'),
    );

    request.cookies.addAll(cookies);

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    return stringData;
  }

  Future<dynamic> getSession() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/session',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    return stringData;
  }

  Future<String?> _getAccessToken(BuildContext context) async {
    final state = context.read<AuthBloc>().state;

    if (state is AuthorizedAuthState) {
      return await secureStorage.read(key: 'accessToken');
    } else {
      return null;
    }
  }

  Future<bool> likePost({
    required String postSlug,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.postUrl(Uri.https(
      'api.hejto.pl',
      '/posts/$postSlug/likes',
    ));

    request.cookies.addAll(await cookieJar.loadForRequest(
      Uri.https('www.hejto.pl'),
    ));

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, 'api.hejto.pl');

    HttpClientResponse response = await request.close();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> unlikePost({
    required String postSlug,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(Uri.https(
      'api.hejto.pl',
      '/posts/$postSlug/likes',
    ));

    request.cookies.addAll(await cookieJar.loadForRequest(
      Uri.https('www.hejto.pl'),
    ));

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, 'api.hejto.pl');

    HttpClientResponse response = await request.close();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future getPostDetails({
    required String? postSlug,
    required BuildContext context,
  }) async {
    if (postSlug == null) return;
    final accessToken = await _getAccessToken(context);

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'api.hejto.pl',
        '/posts/$postSlug',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.hostHeader, 'api.hejto.pl');

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
      Uri.https('www.hejto.pl'),
      response.cookies,
    );

    return PostItem.fromJson(json.decode(stringData));
  }
}
