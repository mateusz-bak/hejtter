import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/add_post_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/notifications_screen/notifications_screen.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/enums.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    this.navigateToPost,
    this.navigateToUser,
    this.navigateToCommunity,
  });

  String? navigateToPost;
  String? navigateToUser;
  String? navigateToCommunity;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode focusNode = FocusNode();
  var _showSearchBar = false;
  late int bottomNavBarIndex;
  int _notificationsCounter = 0;

  Future<String?> _addPost(
    String content,
    bool isNsfw,
    String communitySlug,
    List<PhotoToUpload>? images,
  ) async {
    final result = await hejtoApi.createPost(
      context: context,
      content: content,
      isNsfw: isNsfw,
      communitySlug: communitySlug,
      images: images,
    );

    if (result != null && mounted) {
      Navigator.pop(context);
    }

    return result;
  }

  _openPostFromDeepLink() async {
    await Future.delayed(const Duration(milliseconds: 0));

    if (widget.navigateToPost != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(
            slug: widget.navigateToPost,
          ),
        ),
      );
    } else if (widget.navigateToUser != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserScreen(
            userName: widget.navigateToUser,
          ),
        ),
      );
    } else if (widget.navigateToCommunity != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityScreen(
            community: Community(name: widget.navigateToCommunity),
          ),
        ),
      );
    }
  }

  _loadDefaultHomePage() {
    final state = context.read<PreferencesBloc>().state;
    if (state is PreferencesSet) {
      switch (state.defaultPage) {
        case HejtoPage.articles:
          bottomNavBarIndex = 1;
          break;
        case HejtoPage.discussions:
          bottomNavBarIndex = 2;
          break;
        default:
          bottomNavBarIndex = 0;
          break;
      }
    }
  }

  @override
  void initState() {
    _loadDefaultHomePage();
    _openPostFromDeepLink();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            // if (bottomNavBarIndex == 1) {
            //   setState(() {
            //     bottomNavBarIndex = 0;
            //   });
            //   return false;
            // }

            return true;
          },
          child: Scaffold(
            appBar: _buildAppBar(),
            drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
            floatingActionButton: _buildFab(),
            body: _buildScaffoldBody(state),
            bottomNavigationBar: _buildBottomNavigationBar(state),
          ),
        );
      },
    );
  }

  Widget _buildScaffoldBody(ProfileState state) {
    switch (bottomNavBarIndex) {
      case 0:
        return PostsTabView(
          showSearchBar: _showSearchBar,
          focusNode: focusNode,
          fiterPosts: HejtoPage.all,
          showFollowedTab: state is ProfilePresentState,
        );
      case 1:
        return PostsTabView(
          showSearchBar: _showSearchBar,
          focusNode: focusNode,
          fiterPosts: HejtoPage.articles,
          showFollowedTab: state is ProfilePresentState,
        );
      case 2:
        return PostsTabView(
          showSearchBar: _showSearchBar,
          focusNode: focusNode,
          fiterPosts: HejtoPage.discussions,
          showFollowedTab: state is ProfilePresentState,
        );
      case 3:
        return NotificationsScreen(updateCounter: (newValue) {
          setState(() {
            _notificationsCounter = newValue;
          });
        });
      default:
        return const SizedBox();
    }
  }

  AppBar? _buildAppBar() {
    const textStyle = TextStyle(fontSize: 18);

    switch (bottomNavBarIndex) {
      case 0:
        return AppBar(title: const Text('Hejto', style: textStyle));
      case 1:
        return AppBar(title: const Text('Artykuły', style: textStyle));
      case 2:
        return AppBar(title: const Text('Dyskusje', style: textStyle));
      case 3:
        return AppBar(title: const Text('Powiadomienia', style: textStyle));
      default:
        return null;
    }
  }

  Widget _buildBottomNavigationBar(ProfileState state) {
    return NavigationBar(
      selectedIndex: bottomNavBarIndex,
      height: 60,
      onDestinationSelected: (int index) {
        if (index == 2) {
          if (state is ProfilePresentState) {
            setState(() {
              bottomNavBarIndex = index;
            });
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const LoginScreen();
            }));
          }
        } else {
          setState(() {
            bottomNavBarIndex = index;
          });
        }
      },
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.all_inclusive),
          label: 'Wszystko',
        ),
        NavigationDestination(
          icon: Icon(Icons.newspaper),
          label: 'Artykuły',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.forum),
          icon: Icon(Icons.forum_outlined),
          label: 'Dyskusje',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.notifications_rounded),
          icon: Icon(Icons.notifications_none),
          label: 'Powiadomienia',
        ),
      ],
    );
  }

  Widget? _buildFab() {
    switch (bottomNavBarIndex) {
      case 0:
        return _buildNewArticleAndPostFAB();
      case 1:
        return _buildNewArticleFAB();
      case 2:
        return _buildNewPostFAB();
      case 3:
        return _buildReadNotificationsFAB();
      default:
        return null;
    }
  }

  // TODO: Do Article adding
  Widget _buildNewArticleAndPostFAB() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return FloatingActionButton(
            onPressed: _openAddPostDialog,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  // TODO: Do Article adding
  Widget _buildNewArticleFAB() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return FloatingActionButton(
            onPressed: _openAddPostDialog,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildNewPostFAB() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return FloatingActionButton(
            onPressed: _openAddPostDialog,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildReadNotificationsFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        await hejtoApi.markAllNotificationsAsRead(context: context);
      },
      isExtended: true,
      icon: const Icon(Icons.task_alt),
      label: const Text('Odczytaj wszystkie'),
    );
  }

  _openAddPostDialog() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AddPostScreen(addPost: _addPost);
    }));
  }

  IconButton _buildSearchButton(BuildContext context) {
    return IconButton(
      onPressed: (() {
        setState(() {
          _showSearchBar = !_showSearchBar;
          searchCubit.changeString('');

          if (_showSearchBar) {
            FocusScope.of(context).requestFocus(focusNode);
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        });
      }),
      icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
    );
  }
}
