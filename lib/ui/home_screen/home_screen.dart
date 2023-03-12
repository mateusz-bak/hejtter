import 'package:animated_widgets/animated_widgets.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/new_notificationsbloc/new_notifications_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';
import 'package:hejtter/models/communities_response.dart';

import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/models/poll_to_be_created.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/add_post_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/widgets/widgets.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/notifications_screen/notifications_screen.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/posts_feed/posts_feed.dart';
import 'package:hejtter/ui/search_screen/search_screen.dart';
import 'package:hejtter/ui/settings_screen/widgets/widgets.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:hejtter/utils/helpers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int bottomNavBarIndex = 0;

  static const _pageSize = 20;

  final _pageViewController = PageController();

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
      _pagingController.error = error;

      await Future.delayed(const Duration(seconds: 1));
      _pagingController.retryLastFailedRequest();
    }

    BlocProvider.of<NewNotificationsBloc>(context).add(
      GetNotificationsEvent(context: context),
    );
  }

  Future<String?> _addPost(
    String content,
    bool isNsfw,
    String communitySlug,
    List<PhotoToUpload>? images,
    PostType postType,
    String? title,
    String? link,
    PollToBeCreated? poll,
  ) async {
    final result = await hejtoApi.createPost(
      context: context,
      content: content,
      isNsfw: isNsfw,
      communitySlug: communitySlug,
      images: images,
      postType: postType,
      title: title,
      link: link,
      poll: poll,
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

  _navigateToPosts() {
    setState(() {
      bottomNavBarIndex = 0;
    });

    _pageViewController.animateToPage(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
  }

  _navigateToNotifications(ProfileState state) {
    BlocProvider.of<NewNotificationsBloc>(context).add(
      GetNotificationsEvent(context: context),
    );

    if (state is ProfilePresentState) {
      setState(() {
        bottomNavBarIndex = 1;
      });

      _pageViewController.animateToPage(
        1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.ease,
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return const LoginScreen();
      }));
    }
  }

  _navigateToProfile(ProfileState state) {
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

  _setDefaultConfiguration() {
    final preferencesState = context.read<PreferencesBloc>().state;

    if (preferencesState is PreferencesSet) {
      discussionsNavCubit.changeCurrentHejtoPage(preferencesState.defaultPage);
      discussionsNavCubit.changeCurrentPostsCategoryPage(
        preferencesState.defaultPostsCategory,
      );
    }
  }

  @override
  void initState() {
    _openPostFromDeepLink();

    _setDefaultConfiguration();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _showDonateSnackbar();

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (bottomNavBarIndex == 1) {
              _navigateToPosts();

              return false;
            }

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

  Future _updateDonateReminder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'update_donate_reminder', DateTime.now().toIso8601String());
  }

  _showDonateSnackbar() async {
    final prefs = await SharedPreferences.getInstance();
    final String? updateDonateReminder = prefs.getString(
      'update_donate_reminder',
    );

    final lastReminderTime = updateDonateReminder != null
        ? DateTime.parse(updateDonateReminder)
        : null;

    if (lastReminderTime != null) {
      final daysDiference = DateTime.now().difference(lastReminderTime).inDays;

      if (daysDiference < 14) {
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    late Flushbar flush;
    flush = Flushbar(
      flushbarStyle: FlushbarStyle.FLOATING,
      titleText: const Text(
        'Donate dla developera aplikacji za dobrą robotę',
        style: TextStyle(fontSize: 16),
      ),
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () async {
              await _updateDonateReminder();
              flush.dismiss();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: onPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(width: 1, color: dividerColor),
              ),
            ),
            child: const Text('Nope'),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () async {
              flush.dismiss();

              await _updateDonateReminder();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                builder: (context) {
                  return const DonateModal();
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: boltColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(width: 1, color: dividerColor),
              ),
            ),
            child: const Text('Jasne'),
          ),
        ],
      ),
      backgroundColor: backgroundSecondaryColor,
      borderColor: dividerColor,
      borderWidth: 1,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 30),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      isDismissible: false,
      animationDuration: const Duration(milliseconds: 250),
      borderRadius: BorderRadius.circular(10),
      icon: ShakeAnimatedWidget(
        duration: const Duration(seconds: 2),
        shakeAngle: Rotation.deg(z: 30),
        curve: Curves.bounceInOut,
        child: const Icon(
          FontAwesomeIcons.sackDollar,
          color: boltColor,
          size: 28,
        ),
      ),
    );

    flush.show(context);
  }

  Widget _buildScaffoldBody() {
    return PageView(
      controller: _pageViewController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StreamBuilder<HejtoPage>(
          stream: discussionsNavCubit.currentHejtoPageFetcher,
          builder: (context, pageSnapshot) {
            return StreamBuilder<PostsCategory>(
              stream: discussionsNavCubit.currentPostsCategoryFetcher,
              builder: (context, categorySnapshot) {
                if (pageSnapshot.data != null &&
                    categorySnapshot.data != null) {
                  return PostsFeed(
                    pagingController: _pagingController,
                  );
                } else {
                  return const SizedBox();
                }
              },
            );
          },
        ),
        NotificationsScreen(
          updateCounter: (_) {},
        ),
      ],
    );
  }

  AppBar? _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor.withOpacity(0.8),
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          bottomNavBarIndex == 1
              ? const Text(
                  'Powiadomienia',
                  style: TextStyle(fontSize: 20),
                )
              : const SizedBox(),
          Expanded(
            child: SizedBox(
              width: bottomNavBarIndex == 1 ? 0 : null,
              height: bottomNavBarIndex == 1 ? 0 : null,
              child: Row(
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
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return HejtoPagesMenu(
                                  onPressed: (option) {
                                    Navigator.of(context).pop();

                                    discussionsNavCubit
                                        .changeCurrentHejtoPage(option);

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
                              isScrollControlled: true,
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
            ),
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
        if (index == 0) {
          if (bottomNavBarIndex == 0) {
            _pagingController.refresh();
          } else {
            _navigateToPosts();
          }
        }

        if (index == 1) {
          _navigateToNotifications(state);
        }

        if (index == 2) {
          _navigateToProfile(state);
        }
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
        NavigationDestination(
          icon: BlocBuilder<NewNotificationsBloc, NewNotificationsState>(
            builder: (context, state) {
              if (state is NewNotificationsPresent) {
                return Stack(
                  children: const [
                    Icon(Icons.notifications_none_outlined),
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              } else {
                return const Icon(Icons.notifications_none_outlined);
              }
            },
          ),
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
        return _buildNewPostFAB();
      case 1:
        return _buildReadNotificationsFAB();
      default:
        return null;
    }
  }

  Widget _buildNewPostFAB() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return FloatingActionButton(
            backgroundColor: primaryColor,
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
      backgroundColor: primaryColor,
      onPressed: () async {
        await hejtoApi.markAllNotificationsAsRead(context: context);

        BlocProvider.of<NewNotificationsBloc>(context).add(
          GetNotificationsEvent(context: context),
        );

        setState(() {});
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
