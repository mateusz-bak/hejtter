import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';

import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/add_post_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/home_screen/post_categories_menu.dart';
import 'package:hejtter/ui/home_screen/post_types_button.dart';
import 'package:hejtter/ui/home_screen/hejto_pages_menu.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/notifications_screen/notifications_screen.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/posts_screen/posts_feed.dart';
import 'package:hejtter/ui/search_screen/search_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:hejtter/utils/helpers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  late int bottomNavBarIndex;

  static const _pageSize = 20;

  final _hejtoPages = const [
    HejtoPage.all,
    HejtoPage.articles,
    HejtoPage.discussions,
  ];

  final _postCategories = const [
    PostsCategory.all,
    null,
    PostsCategory.hotThreeHours,
    PostsCategory.hotSixHours,
    PostsCategory.hotTwelveHours,
    PostsCategory.hotTwentyFourHours,
    null,
    PostsCategory.topSevenDays,
    PostsCategory.topThirtyDays,
    null,
    PostsCategory.followed,
  ];

  final PagingController<int, Post> _pagingController = PagingController(
    firstPageKey: 1,
  );

  Future<List<String>> _decidePostsTypes() async {
    final currentPage = await discussionsNavCubit.currentHejtoPageFetcher.first;

    if (currentPage == HejtoPage.articles) {
      return ['article', 'link', 'offer'];
    } else if (currentPage == HejtoPage.discussions) {
      return ['discussion'];
    } else {
      return ['article', 'link', 'discussion', 'offer'];
    }
  }

  Future<String> _decidePostsOrder() async {
    final currentPage =
        await discussionsNavCubit.currentPostsCategoryFetcher.first;

    if (currentPage == PostsCategory.hotThreeHours ||
        currentPage == PostsCategory.hotSixHours ||
        currentPage == PostsCategory.hotTwelveHours ||
        currentPage == PostsCategory.hotTwentyFourHours) {
      return 'p.hotness';
    } else if (currentPage == PostsCategory.topSevenDays ||
        currentPage == PostsCategory.topThirtyDays) {
      return 'p.numLikes';
    } else {
      return 'p.createdAt';
    }
  }

  Future<PostsPeriod> _decidePostsPeriod() async {
    final currentPage =
        await discussionsNavCubit.currentPostsCategoryFetcher.first;

    if (currentPage == PostsCategory.hotThreeHours) {
      return PostsPeriod.threeHours;
    } else if (currentPage == PostsCategory.hotSixHours) {
      return PostsPeriod.sixHours;
    } else if (currentPage == PostsCategory.hotTwelveHours) {
      return PostsPeriod.twelveHours;
    } else if (currentPage == PostsCategory.hotTwentyFourHours) {
      return PostsPeriod.twentyFourHours;
    } else if (currentPage == PostsCategory.topSevenDays) {
      return PostsPeriod.sevenDays;
    } else if (currentPage == PostsCategory.topThirtyDays) {
      return PostsPeriod.thirtyDays;
    } else {
      return PostsPeriod.all;
    }
  }

  Future<bool?> _decidePostsFollowed() async {
    final currentPage =
        await discussionsNavCubit.currentPostsCategoryFetcher.first;
    log(currentPage.toString());

    if (currentPage == PostsCategory.followed) {
      return true;
    } else {
      return null;
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
          pageKey: pageKey,
          pageSize: _pageSize,
          context: context,
          orderBy: await _decidePostsOrder(),
          postsPeriod: await _decidePostsPeriod(),
          types: await _decidePostsTypes(),
          followed: await _decidePostsFollowed());

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _pagingController.appendLastPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_pagingController, newItems),
            context,
          ),
        );
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _pagingController.appendPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_pagingController, newItems),
            context,
          ),
          nextPageKey,
        );
      }
    } catch (error) {
      log(error.toString());
      _pagingController.error = error;
    }
  }

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
            communitySlug: widget.navigateToCommunity,
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

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

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
            backgroundColor: backgroundColor,
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
            floatingActionButton: _buildFab(),
            body: _buildScaffoldBody(),
            bottomNavigationBar: _buildBottomNavigationBar(state),
          ),
        );
      },
    );
  }

  Widget _buildScaffoldBody() {
    return StreamBuilder<HejtoPage>(
      stream: discussionsNavCubit.currentHejtoPageFetcher,
      builder: (context, pageSnapshot) {
        return StreamBuilder<PostsCategory>(
          stream: discussionsNavCubit.currentPostsCategoryFetcher,
          builder: (context, categorySnapshot) {
            if (pageSnapshot.data != null && categorySnapshot.data != null) {
              return PostsFeed(
                pagingController: _pagingController,
              );
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }

  AppBar? _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor.withOpacity(0.8),
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          const Spacer(),
          StreamBuilder<HejtoPage>(
              stream: discussionsNavCubit.currentHejtoPageFetcher,
              builder: (context, snapshot) {
                return PostTypesButton(
                  positionedOnLeft: true,
                  text: snapshot.data,
                  mainAxisAlignment: MainAxisAlignment.start,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return HejtoPagesMenu(
                          onPressed: (option) {
                            Navigator.of(context).pop();

                            discussionsNavCubit.changeCurrentHejtoPage(option);

                            _pagingController.refresh();
                          },
                          options: _hejtoPages,
                        );
                      },
                    );
                  },
                );
              }),
          StreamBuilder<PostsCategory>(
              stream: discussionsNavCubit.currentPostsCategoryFetcher,
              builder: (context, snapshot) {
                return PostTypesButton(
                  positionedOnLeft: false,
                  text: snapshot.data,
                  mainAxisAlignment: MainAxisAlignment.start,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return PostCategoriesMenu(
                          onPressed: (option) {
                            Navigator.of(context).pop();

                            discussionsNavCubit
                                .changeCurrentPostsCategoryPage(option);

                            _pagingController.refresh();
                          },
                          options: _postCategories,
                        );
                      },
                    );
                  },
                );
              }),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(ProfileState state) {
    return NavigationBar(
      selectedIndex: bottomNavBarIndex,
      height: 50,
      backgroundColor: backgroundColor,
      elevation: 0,
      onDestinationSelected: (int index) {
        if (index == 2) {
          if (state is ProfilePresentState) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserScreen(
                  userName: state.username,
                ),
              ),
            );
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return const LoginScreen();
            }));
          }
        }
        // else {
        //   setState(() {
        //     bottomNavBarIndex = index;
        //   });
        // }
      },
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      destinations: <Widget>[
        const NavigationDestination(
          icon: Icon(Icons.newspaper_outlined),
          selectedIcon: Icon(Icons.newspaper_rounded),
          label: 'Wpisy',
        ),
        // NavigationDestination(
        //   icon: Icon(Icons.forum_outlined),
        //   selectedIcon: Icon(Icons.forum_rounded),
        //   label: 'Wiadomości',
        // ),
        const NavigationDestination(
          icon: Icon(Icons.notifications_none_outlined),
          selectedIcon: Icon(Icons.notifications_none_rounded),
          label: 'Powiadomienia',
        ),
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfilePresentState) {
              return NavigationDestination(
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    color: dividerColor,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        height: 22,
                        width: 22,
                        imageUrl: state.avatar ?? defaultAvatar,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                label: state.username,
              );
            }
            return const NavigationDestination(
              icon: Icon(Icons.person_2_outlined),
              selectedIcon: Icon(Icons.person_2_rounded),
              label: 'Profil',
            );
          },
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
}
