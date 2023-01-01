import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';

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
}
