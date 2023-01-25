import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/main.dart';
import 'package:hejtter/models/account.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/models/user_details_response.dart';
import 'package:hejtter/utils/constants.dart';

final hejtoApi = HejtoApi();

class HejtoApi {
  var cookieJar = CookieJar();
  var client = HttpClient();

  _showSnackBar(String msg) {
    SnackBar snackBar = SnackBar(content: Text(msg));
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  _showFlushBar(BuildContext context, String msg) {
    late Flushbar flush;
    flush = Flushbar(
      message: msg,
      duration: const Duration(seconds: 8),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(
        Icons.error,
        color: Colors.red,
      ),
      animationDuration: const Duration(milliseconds: 500),
      mainButton: TextButton(
        onPressed: () {
          flush.dismiss(true);
        },
        child: const Text(
          "OK",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    flush.show(context);
  }

  Future<HttpClientRequest> _addCookiesToRequest(
    HttpClientRequest request,
  ) async {
    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https(hejtoUrl),
      ),
    );

    return request;
  }

  _saveCookiesFromResponse(
    HttpClientResponse response,
  ) async {
    await cookieJar.saveFromResponse(
      Uri.https(hejtoUrl),
      response.cookies,
    );
  }

  Future<dynamic> getProviders() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoUrl,
        '/api/auth/providers',
      ),
    );

    request = await _addCookiesToRequest(request);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    return stringData;
  }

  Future<dynamic> getCSRFToken() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoUrl,
        '/api/auth/csrf',
      ),
    );

    request = await _addCookiesToRequest(request);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    final token = jsonDecode(stringData)['csrfToken'];

    return token;
  }

  Future<String?> postCredentials(
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
        hejtoUrl,
        '/api/auth/callback/credentials',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showSnackBar(
        'Logowanie nieudane (${response.statusCode} - ${response.reasonPhrase})',
      );
      return null;
    }

    return stringData;
  }

  Future<dynamic> getSession() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoUrl,
        '/api/auth/session',
      ),
    );

    request = await _addCookiesToRequest(request);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

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
      hejtoApiUrl,
      '/posts/$postSlug/likes',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas piorunowania wpisu: ${response.statusCode}',
      );

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
      hejtoApiUrl,
      '/posts/$postSlug/likes',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas odpiorunowywania wpisu: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<Post?> getPostDetails({
    required String? postSlug,
    required BuildContext context,
  }) async {
    if (postSlug == null) return null;
    final accessToken = await _getAccessToken(context);

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$postSlug',
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania wpisu: ${response.statusCode}',
      );
    }

    return Post.fromJson(json.decode(stringData));
  }

  Future<List<Post>?> getPosts({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
    String? type,
    String? communitySlug,
    String? tagName,
    String? author,
    String? commentedBy,
    bool? favorited,
    bool? followed,
    String query = '',
    required String orderBy,
    String? orderDir,
    PostsPeriod? postsPeriod,
  }) async {
    final accessToken = await _getAccessToken(context);

    var queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderBy': orderBy,
    };

    queryParameters = _addCommunityFilter(queryParameters, communitySlug);
    queryParameters = _addTagFilter(queryParameters, tagName);
    queryParameters = _addSearchQuery(queryParameters, query);
    queryParameters = _addPostsPeriod(queryParameters, postsPeriod);
    queryParameters = _addPostsType(queryParameters, type);
    queryParameters = _addPostsAuthor(queryParameters, author);
    queryParameters = _addPostsCommenter(queryParameters, commentedBy);
    queryParameters = _addPostsFavorited(queryParameters, favorited);
    queryParameters = _addPostsOrderDir(queryParameters, orderDir);
    queryParameters = _addPostsFollowed(queryParameters, followed);

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/',
        queryParameters,
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        _showFlushBar(
          context,
          'Sesja wygasła :( przekierowanie na stronę logowania',
        );

        await Future.delayed(const Duration(seconds: 3));

        BlocProvider.of<AuthBloc>(context).add(
          const LogOutAuthEvent(),
        );

        BlocProvider.of<ProfileBloc>(context).add(
          const ClearProfileEvent(),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        _showFlushBar(
          context,
          'Błąd podczas pobierania wpisów: ${response.statusCode}',
        );
      }
    }

    return postFromJson(stringData).embedded?.items;
  }

  Map<String, String> _addCommunityFilter(
    Map<String, String> queryParameters,
    String? communityName,
  ) {
    if (communityName != null) {
      queryParameters.addEntries(
        <String, String>{'community': communityName}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addTagFilter(
    Map<String, String> queryParameters,
    String? tagName,
  ) {
    if (tagName != null) {
      queryParameters.addEntries(
        <String, String>{'tags[]': tagName}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addSearchQuery(
    Map<String, String> queryParameters,
    String query,
  ) {
    if (query.isNotEmpty) {
      queryParameters.addEntries(
        <String, String>{'query': query}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsAuthor(
    Map<String, String> queryParameters,
    String? author,
  ) {
    if (author != null) {
      queryParameters.addEntries(
        <String, String>{'users[]': author}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsCommenter(
    Map<String, String> queryParameters,
    String? commentedBy,
  ) {
    if (commentedBy != null) {
      queryParameters.addEntries(
        <String, String>{'commentedBy': commentedBy}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsOrderDir(
    Map<String, String> queryParameters,
    String? orderDir,
  ) {
    if (orderDir != null) {
      queryParameters.addEntries(
        <String, String>{'orderDir': orderDir}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsFavorited(
    Map<String, String> queryParameters,
    bool? favorited,
  ) {
    if (favorited == true) {
      queryParameters.addEntries(
        <String, String>{'favorited': '1'}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsFollowed(
    Map<String, String> queryParameters,
    bool? followed,
  ) {
    if (followed == true) {
      queryParameters.addEntries(
        <String, String>{'followed': '1'}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsType(
    Map<String, String> queryParameters,
    String? type,
  ) {
    if (type != null) {
      queryParameters.addEntries(
        <String, String>{'type[]': type}.entries,
      );
    }

    return queryParameters;
  }

  Map<String, String> _addPostsPeriod(
    Map<String, String> queryParameters,
    PostsPeriod? postsPeriod,
  ) {
    switch (postsPeriod) {
      case PostsPeriod.threeHours:
        queryParameters.addEntries(<String, String>{
          'period': '3h',
        }.entries);
        break;
      case PostsPeriod.sixHours:
        queryParameters.addEntries(<String, String>{
          'period': '6h',
        }.entries);
        break;
      case PostsPeriod.twelveHours:
        queryParameters.addEntries(<String, String>{
          'period': '12h',
        }.entries);
        break;
      case PostsPeriod.twentyFourHours:
        queryParameters.addEntries(<String, String>{
          'period': '24h',
        }.entries);
        break;
      case PostsPeriod.sevenDays:
        queryParameters.addEntries(<String, String>{
          'period': 'week',
        }.entries);
        break;
      case PostsPeriod.thirtyDays:
        queryParameters.addEntries(<String, String>{
          'period': 'month',
        }.entries);
        break;
      case PostsPeriod.all:
        queryParameters.addEntries(<String, String>{
          'period': 'all',
        }.entries);
        break;

      default:
        queryParameters.addEntries(<String, String>{
          'period': 'all',
        }.entries);
        break;
    }

    return queryParameters;
  }

  Future<List<CommentItem>?> getComments({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
    required String? slug,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (slug == null) return null;

    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderDir': 'asc',
    };

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$slug/comments',
        queryParameters,
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania komentarzy: ${response.statusCode}',
      );
    }

    return commentsResponseFromJson(stringData).embedded?.items;
  }

  Future<bool> likeComment({
    required String? postSlug,
    required String? commentUUID,
    required BuildContext context,
  }) async {
    if (postSlug == null || commentUUID == null) return false;

    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.postUrl(Uri.https(
      hejtoApiUrl,
      '/posts/$postSlug/comments/$commentUUID/likes',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas piorunowania komentarza: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> unlikeComment({
    required String? postSlug,
    required String? commentUUID,
    required BuildContext context,
  }) async {
    if (postSlug == null || commentUUID == null) return false;

    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(Uri.https(
      hejtoApiUrl,
      '/posts/$postSlug/comments/$commentUUID/likes',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas odpiorunowywania komentarza: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<CommentItem?> getCommentDetails({
    required String? postSlug,
    required String? commentUUID,
    required BuildContext context,
  }) async {
    if (postSlug == null || commentUUID == null) return null;

    final accessToken = await _getAccessToken(context);

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$postSlug/comments/$commentUUID',
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania komentarza: ${response.statusCode}',
      );
    }

    return CommentItem.fromJson(json.decode(stringData));
  }

  Future<Account?> getAccount({
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return null;

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/account',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania konta: ${response.statusCode}',
      );
    }
    return accountFromJson(stringData);
  }

  Future<bool> addComment({
    required String? slug,
    required String content,
    required BuildContext context,
    List<PhotoToUpload>? images,
  }) async {
    if (slug == null) return false;

    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    final body = {
      'content': content,
      'images': images,
    };

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$slug/comments',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 201) {
      _showFlushBar(
        context,
        'Błąd podczas dodawania komentarza: ${response.statusCode}',
      );

      return false;
    }

    return true;
  }

  Future<List<Community>?> getCommunities({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
    String query = '',
  }) async {
    final accessToken = await _getAccessToken(context);

    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderBy': 'numMembers',
      'orderDir': 'desc',
      'query': query,
    };

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/communities',
        queryParameters,
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania społeczności: ${response.statusCode}',
      );
    }

    return communitiesResponseFromJson(stringData).embedded?.items;
  }

  Future<UserDetailsResponse> getUserDetails({
    required BuildContext context,
    required String username,
  }) async {
    final accessToken = await _getAccessToken(context);

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/users/$username',
      ),
    );

    request = await _addCookiesToRequest(request);

    if (accessToken != null) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      _showFlushBar(
        context,
        'Błąd podczas pobierania użytkownika: ${response.statusCode}',
      );
    }

    return userDetailsResponseFromJson(stringData);
  }

  Future<bool> blockUser({
    required String username,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/users/$username/blocks',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas blokowania użytkownika: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> unblockUser({
    required String username,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(
      Uri.https(
        hejtoApiUrl,
        '/users/$username/blocks',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas odblokowywania użytkownika: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> followUser({
    required String username,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/users/$username/follows',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas obserwowania użytkownika: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> unfollowUser({
    required String username,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(
      Uri.https(
        hejtoApiUrl,
        '/users/$username/follows',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas odobserwowywania użytkownika: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> addPostToFavorites({
    required String postSlug,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$postSlug/favorites',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas dodawania wpisu do ulubionych: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> removePostFromFavorites({
    required String postSlug,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts/$postSlug/favorites',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas usuwania wpisu z ulubionych: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> updateAccountSettings({
    required BuildContext context,
    required ProfilePresentState current,
    bool? showNsfw,
    bool? showControversial,
    bool? blurNsfw,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    final body = {
      'show_nsfw': showNsfw ?? current.showNsfw,
      'show_controversial': showControversial ?? current.showControversial,
      'blur_nsfw': blurNsfw ?? current.blurNsfw,
    };

    HttpClientRequest request = await client.patchUrl(
      Uri.https(
        hejtoApiUrl,
        '/account/settings',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas aktualizacji ustawień konta: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<String?> createPost({
    required String content,
    required String communitySlug,
    required BuildContext context,
    required bool isNsfw,
    List<PhotoToUpload>? images,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return null;

    final body = {
      'type': 'discussion',
      'community': communitySlug,
      'content': content,
      'tags': [],
      'images': images,
      'nsfw': isNsfw,
    };

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/posts',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 201) {
      final location = response.headers['location'];
      return location?[0].replaceAll('/posts/', '');
    } else if (response.statusCode == 429) {
      _showFlushBar(context, 'Przekroczono limit');
      return null;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas dodawania posta: ${response.statusCode}',
      );
      return null;
    }
  }

  // Below method needs a multipart request
  // which is missing in HttpClient library
  Future<String?> createUpload({
    required BuildContext context,
    required Uint8List picture,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return null;

    final queryParameters = {
      'target': 'post',
      'source': 'file',
    };

    final uri = Uri.https(hejtoApiUrl, '/uploads', queryParameters);
    var request = http.MultipartRequest('POST', uri);

    final httpImage = http.MultipartFile.fromBytes(
      'image',
      picture,
      filename: 'image',
    );

    request.files.add(httpImage);

    request.headers.addAll({
      "content-type": "application/json; charset=utf-8",
      "Authorization": 'Bearer $accessToken',
    });

    final response = await request.send();
    final responseString = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(responseString)['uuid'];
    } else if (response.statusCode == 429) {
      _showFlushBar(context, 'Przekroczono limit');
      return null;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas dodawania zdjęcia: ${response.statusCode}',
      );
      return null;
    }
  }

  Future<bool> removePost({
    required String postSlug,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(Uri.https(
      hejtoApiUrl,
      '/posts/$postSlug',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas usuwania posta: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> removeComment({
    required String postSlug,
    required String uuid,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.deleteUrl(Uri.https(
      hejtoApiUrl,
      '/posts/$postSlug/comments/$uuid',
    ));

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas usuwania komentarza: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<List<HejtoNotification>?> getNotifications({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
    required String? type,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return null;

    var queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'type': type,
      'offset': '0',
      'orderDir': 'desc',
    };

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/account/notifications',
        queryParameters,
      ),
    );

    request = await _addCookiesToRequest(request);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    _saveCookiesFromResponse(response);

    if (response.statusCode != 200) {
      if (response.statusCode == 401) {
        _showFlushBar(
          context,
          'Sesja wygasła :( przekierowanie na stronę logowania',
        );

        await Future.delayed(const Duration(seconds: 3));

        BlocProvider.of<AuthBloc>(context).add(
          const LogOutAuthEvent(),
        );

        BlocProvider.of<ProfileBloc>(context).add(
          const ClearProfileEvent(),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        _showFlushBar(
          context,
          'Błąd podczas pobierania powiadomień: ${response.statusCode}',
        );
      }
    }

    return userNotificationFromJson(stringData).embedded?.items;
  }

  Future<bool> getNotificationDetails({
    required String uuid,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        '/account/notifications/$uuid',
      ),
    );
    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 200) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas pobierania powiadomienia: ${response.statusCode}',
      );

      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead({
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    HttpClientRequest request = await client.putUrl(
      Uri.https(
        hejtoApiUrl,
        '/account/notifications/all/read',
      ),
    );
    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);

    if (response.statusCode == 204) {
      return true;
    } else {
      _showFlushBar(
        context,
        'Błąd podczas oznaczania powiadomień jako przeczytane: ${response.statusCode}',
      );
      return false;
    }
  }

  Future<bool> createPollVote({
    required String uuid,
    required int option,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    final body = {
      'option': '$option',
    };

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        hejtoApiUrl,
        '/polls/$uuid/votes',
      ),
    );

    request = await _addCookiesToRequest(request);

    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $accessToken');
    request.headers.set(HttpHeaders.hostHeader, hejtoApiUrl);
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();

    _saveCookiesFromResponse(response);
    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 429) {
      _showFlushBar(context, 'Przekroczono limit');
      return false;
    } else {
      _showFlushBar(context, 'Błąd głosowania: ${response.statusCode}');
      return false;
    }
  }
}
