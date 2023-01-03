import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/models/user_details_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';
import 'package:hejtter/ui/user_screen/user_app_bar.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
    required this.userName,
  });

  final String? userName;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final client = http.Client();
  static const pageSize = 10;
  String postsType = 'Wpisy dodane';
  String orderType = 'Najnowsze';

  late List<String> postTypes;
  final List<String> orderTypes = ['Najnowsze', 'Najstarsze'];

  late List<DropdownMenuItem<String>> postItems;
  late List<DropdownMenuItem<String>> orderItems;

  final PagingController<int, PostItem> _pagingController =
      PagingController(firstPageKey: 1);

  Future<UserDetailsResponse> _getUser() async {
    var response = await client.get(
      Uri.https('api.hejto.pl', '/users/${widget.userName}'),
    );

    return userDetailsResponseFromJson(response.body);
  }

  void _setDropdownValuesForCurrentUser() {
    postTypes = <String>[
      'Wpisy dodane',
      'Wpisy komentowane',
      'Wpisy ulubione',
    ];
  }

  void _setDropdownValuesForOtherUsers() {
    postTypes = <String>[
      'Wpisy dodane',
      'Wpisy komentowane',
    ];
  }

  void _createDropDownItems() {
    postItems = postTypes
        .map(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();

    orderItems = orderTypes
        .map(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();
  }

  Future<void> _fetchPosts(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: pageSize,
        author: postsType == 'Wpisy dodane' ? widget.userName : null,
        context: context,
        orderBy: 'p.createdAt',
        commentedBy: postsType == 'Wpisy komentowane' ? widget.userName : null,
        favorited: postsType == 'Wpisy ulubione' ? true : null,
        orderDir: orderType == 'Najnowsze' ? 'desc' : 'asc',
      );

      final isLastPage = newItems!.length < pageSize;
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
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder<UserDetailsResponse>(
        future: _getUser(),
        builder: (
          BuildContext context,
          AsyncSnapshot<UserDetailsResponse> snapshot,
        ) {
          if (snapshot.hasData) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfilePresentState &&
                    state.username == snapshot.data?.username) {
                  _setDropdownValuesForCurrentUser();
                } else {
                  _setDropdownValuesForOtherUsers();
                }

                _createDropDownItems();

                return NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      UserAppBar(user: snapshot.data!),
                    ];
                  },
                  body: _buildUserPosts(snapshot.data!),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Błąd przy pobieraniu informacji o użytkowniku ${widget.userName}',
                ),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserPosts(UserDetailsResponse data) {
    return Column(
      children: [
        _buildUserDetails(data),
        const SizedBox(height: 10),
        _buildDropDowns(),
        Expanded(
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
        ),
      ],
    );
  }

  Padding _buildDropDowns() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              items: postItems,
              value: postsType,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  postsType = value;
                });

                _pagingController.refresh();
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              items: orderItems,
              value: orderType,
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  orderType = value;
                });

                _pagingController.refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(UserDetailsResponse data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        data.currentRank != null ? _buildRankPlate(data) : const SizedBox(),
        const SizedBox(width: 15),
        Row(
          children: [
            const Icon(
              Icons.text_snippet_sharp,
              size: 20,
              color: primaryColor,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numPosts}'),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            const Icon(
              Icons.comment,
              size: 20,
              color: primaryColor,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numComments}'),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            const Icon(
              Icons.person,
              size: 20,
              color: primaryColor,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numFollows}'),
          ],
        ),
      ],
    );
  }

  Widget _buildRankPlate(UserDetailsResponse data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        data.currentRank!,
        style: TextStyle(
          color: data.currentColor != null
              ? Color(
                  int.parse(
                    data.currentColor!.replaceAll('#', '0xff'),
                  ),
                )
              : null,
        ),
      ),
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
