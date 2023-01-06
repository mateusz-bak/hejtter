import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
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
      _showSnackBar('Logowanie nieudane (${response.statusCode})');
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

    return Post.fromJson(json.decode(stringData));
  }

  Future<List<Post>?> getPosts({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
    String? communitySlug,
    String? tagName,
    String? author,
    String? commentedBy,
    bool? favorited,
    bool? followed,
    String query = '',
    required String orderBy,
    String? orderDir,
    String? postsPeriod,
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

  Map<String, String> _addPostsPeriod(
    Map<String, String> queryParameters,
    String? postsPeriod,
  ) {
    switch (postsPeriod) {
      case '6h':
        queryParameters.addEntries(<String, String>{
          'period': '6h',
        }.entries);
        break;
      case '12h':
        queryParameters.addEntries(<String, String>{
          'period': '12h',
        }.entries);
        break;
      case '24h':
        queryParameters.addEntries(<String, String>{
          'period': '24h',
        }.entries);
        break;
      case 'tydzień':
        queryParameters.addEntries(<String, String>{
          'period': 'week',
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
    required String commentsHref,
  }) async {
    final accessToken = await _getAccessToken(context);

    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
    };

    HttpClientRequest request = await client.getUrl(
      Uri.https(
        hejtoApiUrl,
        commentsHref,
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

    return accountFromJson(stringData);
  }

  Future<bool> addComment({
    required String? slug,
    required String content,
    required BuildContext context,
  }) async {
    if (slug == null) return false;

    final accessToken = await _getAccessToken(context);
    if (accessToken == null) return false;

    final body = {
      'content': content,
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
      _showSnackBar('Dodanie komentarza nieudane (${response.statusCode})');
      return false;
    }

    return true;
  }

  Future<List<Community>?> getCommunities({
    required int pageKey,
    required int pageSize,
    required BuildContext context,
  }) async {
    final accessToken = await _getAccessToken(context);

    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderBy': 'numMembers',
      'orderDir': 'desc',
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
      return false;
    }
  }
}
