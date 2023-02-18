import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/models/user_details_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';
import 'package:hejtter/ui/user_screen/user_action_button.dart';
import 'package:hejtter/ui/user_screen/user_app_bar.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:http/http.dart' as http;

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  static const pageSize = 20;
  String postsType = 'Wpisy dodane';
  String orderType = 'Najnowsze';

  late List<String> postTypes;
  final List<String> orderTypes = ['Najnowsze', 'Najstarsze'];

  late List<DropdownMenuItem<String>> postItems;
  late List<DropdownMenuItem<String>> orderItems;

  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);

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

  _blockUser(String? username) async {
    if (username == null) return;

    final result = await hejtoApi.blockUser(
      username: username,
      context: context,
    );

    if (result) {
      _pagingController.refresh();
      setState(() {});
    }
  }

  _unblockUser(String? username) async {
    if (username == null) return;

    final result = await hejtoApi.unblockUser(
      username: username,
      context: context,
    );

    if (result) {
      _pagingController.refresh();
      setState(() {});
    }
  }

  _blockUserLocally({
    required String? username,
    required List<String>? currentList,
  }) async {
    if (username == null) return;

    if (currentList == null) {
      BlocProvider.of<ProfileBloc>(context).add(
        UpdateUnloggedBlocksProfileEvent(usernames: [username]),
      );
    } else {
      currentList.add(username);
      BlocProvider.of<ProfileBloc>(context).add(
        UpdateUnloggedBlocksProfileEvent(usernames: currentList),
      );
    }
  }

  _unblockUserLocally({
    required String? username,
    required List<String> currentList,
  }) async {
    if (username == null) return;

    currentList.removeWhere((element) {
      return element == username;
    });

    if (currentList.isEmpty) {
      BlocProvider.of<ProfileBloc>(context).add(
        const UpdateUnloggedBlocksProfileEvent(),
      );
    } else {
      BlocProvider.of<ProfileBloc>(context).add(
        UpdateUnloggedBlocksProfileEvent(usernames: currentList),
      );
    }
  }

  _followUser(String? username) async {
    if (username == null) return;

    final result = await hejtoApi.followUser(
      username: username,
      context: context,
    );

    if (result) {
      setState(() {});
    }
  }

  _unfollowUser(String? username) async {
    if (username == null) return;

    final result = await hejtoApi.unfollowUser(
      username: username,
      context: context,
    );

    if (result) {
      setState(() {});
    }
  }

  _reportUser() async {
    if (widget.userName == null) return;

    const firstPart = 'Zgłaszam złamanie regulaminu:\n\n';
    final postUrl = 'Użytkownik ${widget.userName}';
    const lastpart = '\n\nPozdrawiam';

    final Email email = Email(
      body: '$firstPart$postUrl$lastpart',
      subject: 'Złamanie regulaminu',
      recipients: ['support@hejto.pl'],
      isHTML: false,
    );

    FlutterEmailSender.send(email).then((value) {
      const SnackBar snackBar = SnackBar(content: Text('Zgłoszono wpis'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
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
      body: FutureBuilder<UserDetailsResponse>(
        future: hejtoApi.getUserDetails(
          username: widget.userName.toString(),
          context: context,
        ),
        builder: (
          BuildContext context,
          AsyncSnapshot<UserDetailsResponse> snapshot,
        ) {
          if (snapshot.hasData) {
            return BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                late bool isLoggedIn;
                late bool isCurrentUser;

                if (state is ProfilePresentState) {
                  isLoggedIn = true;
                } else {
                  isLoggedIn = false;
                }

                if (state is ProfilePresentState &&
                    state.username == snapshot.data?.username) {
                  _setDropdownValuesForCurrentUser();
                  isCurrentUser = true;
                } else {
                  _setDropdownValuesForOtherUsers();
                  isCurrentUser = false;
                }

                _createDropDownItems();

                return NestedScrollView(
                  headerSliverBuilder: (context, value) {
                    return [
                      UserAppBar(user: snapshot.data!),
                    ];
                  },
                  body: _buildUserScreen(
                    data: snapshot.data!,
                    isLoggedIn: isLoggedIn,
                    isCurrentUser: isCurrentUser,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Text(
                  'Błąd przy pobieraniu informacji o użytkowniku ${widget.userName} - ${snapshot.stackTrace}',
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserScreen({
    required UserDetailsResponse data,
    required bool isLoggedIn,
    required bool isCurrentUser,
  }) {
    return Column(
      children: [
        data.currentRank != null ? _buildRankPlate(data) : const SizedBox(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: _buildUserDetails(data),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUserJoinedDate(data),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            !isCurrentUser
                ? isLoggedIn
                    ? UserActionButton(
                        icon: data.interactions?.isBlocked == true
                            ? Icons.lock_open
                            : Icons.lock_outline,
                        color: data.interactions?.isBlocked == true
                            ? Colors.red
                            : Colors.white,
                        onPressed: data.interactions?.isBlocked == true
                            ? () => _unblockUser(data.username)
                            : () => _blockUser(data.username),
                      )
                    : _buildLocalBlockButton(data)
                : const SizedBox(),
            isLoggedIn && !isCurrentUser
                ? UserActionButton(
                    icon: data.interactions?.isFollowed == true
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white,
                    onPressed: data.interactions?.isFollowed == true
                        ? () => _unfollowUser(data.username)
                        : () => _followUser(data.username),
                  )
                : const SizedBox(),
            !isCurrentUser
                ? UserActionButton(
                    icon: Icons.report,
                    color: Colors.yellow,
                    onPressed: _reportUser,
                  )
                : const SizedBox(),
          ],
        ),
        const SizedBox(height: 5),
        _buildDropDowns(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(
              () {
                _pagingController.refresh();
                setState(() {});
              },
            ),
            child: PagedListView<int, Post>(
              pagingController: _pagingController,
              padding: const EdgeInsets.all(10),
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) => PostCard(item: item),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocalBlockButton(UserDetailsResponse data) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileAbsentState) {
          if (state.blockedUsers != null) {
            if (state.blockedUsers!.contains(data.username)) {
              return UserActionButton(
                icon: Icons.lock_open,
                color: Colors.red,
                onPressed: () => _unblockUserLocally(
                  username: data.username,
                  currentList: state.blockedUsers!,
                ),
              );
            } else {
              return UserActionButton(
                icon: Icons.lock_outline,
                color: Colors.white,
                onPressed: () => _blockUserLocally(
                  username: data.username,
                  currentList: state.blockedUsers!,
                ),
              );
            }
          } else {
            return UserActionButton(
              icon: Icons.lock_outline,
              color: Colors.white,
              onPressed: () => _blockUserLocally(
                username: data.username,
                currentList: null,
              ),
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildUserJoinedDate(UserDetailsResponse data) {
    if (data.createdAt == null) {
      return const SizedBox();
    }

    final joinYear = data.createdAt!.year;
    final joinMonth = data.createdAt!.month;
    final joinDay = data.createdAt!.day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Dołączył/a: ',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          '$joinDay.$joinMonth.$joinYear',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
        Row(
          children: [
            Icon(
              Icons.text_snippet_sharp,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numPosts}'),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            Icon(
              Icons.comment,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numComments}'),
          ],
        ),
        const SizedBox(width: 15),
        Row(
          children: [
            Icon(
              Icons.person,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 5),
            Text('${data.stats?.numFollows}'),
          ],
        ),
      ],
    );
  }

  Widget _buildRankPlate(UserDetailsResponse data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: data.currentColor != null
              ? Color(
                  int.parse(
                    data.currentColor!.replaceAll('#', '0xff'),
                  ),
                )
              : Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          data.currentRank!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
