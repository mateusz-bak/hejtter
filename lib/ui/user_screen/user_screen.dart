import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/models/user_details_response.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
    required this.userName,
  });

  final String? userName;
  static const _pageSize = 10;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final client = http.Client();

  final PagingController<int, PostItem> _pagingController =
      PagingController(firstPageKey: 1);

  Future<UserDetailsResponse> _getUser() async {
    var response = await client.get(
      Uri.https('api.hejto.pl', '/users/${widget.userName}'),
    );

    return userDetailsResponseFromJson(response.body);
  }

  Future<List<PostItem>?> _getUserPosts(int pageKey, int pageSize) async {
    var queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'users[]': widget.userName,
      'orderBy': 'p.createdAt',
    };

    var response = await client.get(
      Uri.https('api.hejto.pl', '/posts', queryParameters),
    );

    return postFromJson(response.body).embedded?.items;
  }

  Future<void> _fetchPosts(int pageKey) async {
    try {
      final newItems = await _getUserPosts(pageKey, UserScreen._pageSize);
      final isLastPage = newItems!.length < UserScreen._pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPosts(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDetailsResponse>(
      future: _getUser(),
      builder:
          (BuildContext context, AsyncSnapshot<UserDetailsResponse> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
            appBar: AppBar(title: const Text('User')),
            body: _buildUserScreen(snapshot.data!),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          Scaffold(
            appBar: AppBar(),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Błąd przy pobieraniu informacji o użytkowniku ${widget.userName}',
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(),
          body: const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserScreen(UserDetailsResponse data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(data.avatar?.urls?.the250X250),
                      const SizedBox(width: 10),
                      _buildUserDetails(data),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildUserPosts(),
      ],
    );
  }

  Widget _buildUserPosts() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView<int, PostItem>(
          pagingController: _pagingController,
          padding: const EdgeInsets.all(10),
          builderDelegate: PagedChildBuilderDelegate<PostItem>(
            itemBuilder: (context, item, index) => PostCard(item: item),
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(UserDetailsResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            data.username != null
                ? Text(
                    data.username!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  )
                : const SizedBox(),
            SizedBox(width: data.sponsor == true ? 5 : 0),
            data.sponsor == true
                ? Transform.rotate(
                    angle: 180,
                    child: const Icon(
                      Icons.mode_night_rounded,
                      color: Colors.brown,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        const SizedBox(height: 5),
        data.currentRank != null
            ? Text(
                data.currentRank!,
                style: TextStyle(
                  fontSize: 16,
                  color: data.currentColor != null
                      ? Color(
                          int.parse(
                            data.currentColor!.replaceAll('#', '0xff'),
                          ),
                        )
                      : null,
                ),
              )
            : const SizedBox(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.text_snippet_sharp, size: 20),
                const SizedBox(width: 5),
                Text('${data.stats?.numPosts}'),
              ],
            ),
            const SizedBox(width: 15),
            Row(
              children: [
                const Icon(Icons.comment, size: 20),
                const SizedBox(width: 5),
                Text('${data.stats?.numComments}'),
              ],
            ),
            const SizedBox(width: 15),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 5),
                Text('${data.stats?.numFollows}'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl) {
    const defaultAvatarUrl =
        'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75';

    return SizedBox(
      height: 120,
      width: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: avatarUrl != null ? avatarUrl.toString() : defaultAvatarUrl,
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
