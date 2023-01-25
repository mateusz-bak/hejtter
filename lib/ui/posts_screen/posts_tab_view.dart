import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/posts_search_bar.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_bar_view.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostsTabView extends StatefulWidget {
  const PostsTabView({
    super.key,
    this.showSearchBar = false,
    this.focusNode,
    this.fiterPosts,
    this.communitySlug,
    this.tagName,
    this.showFollowedTab = false,
  });

  final bool showSearchBar;
  final bool showFollowedTab;
  final HejtoPage? fiterPosts;
  final String? communitySlug;
  final String? tagName;
  final FocusNode? focusNode;

  @override
  State<PostsTabView> createState() => _PostsTabViewState();
}

class _PostsTabViewState extends State<PostsTabView>
    with TickerProviderStateMixin {
  int _currentTab = 0;

  static const _pageSize = 20;
  String query = '';

  late PostsPeriod _hotPostsPeriod;
  var _topPostsPeriod = PostsPeriod.sevenDays;

  late TabController _tabController;

  final List<String> _hotPeriods = [
    '3h',
    '6h',
    '12h',
    '24h',
  ];

  final List<String> _topPeriods = [
    '7d',
    '30d',
    'Od początku',
  ];

  final PagingController<int, Post> _hotPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Post> _topPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Post> _newPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Post> _followedPagingController =
      PagingController(firstPageKey: 1);

  List<Post> _filterLocallyBlockedUsers(List<Post> list) {
    final state = BlocProvider.of<ProfileBloc>(context).state;
    if (state is ProfileAbsentState) {
      if (state.blockedUsers == null) return list;

      list.removeWhere((element) {
        return state.blockedUsers!.contains(element.author?.username);
      });

      return list;
    } else {
      return list;
    }
  }

  Future<void> _fetchHotPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        communitySlug: widget.communitySlug,
        tagName: widget.tagName,
        query: query,
        orderBy: 'p.hotness',
        postsPeriod: _hotPostsPeriod,
        type: widget.fiterPosts == HejtoPage.articles
            ? 'article'
            : widget.fiterPosts == HejtoPage.discussions
                ? 'discussion'
                : null,
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _hotPagingController.appendLastPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
        );
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _hotPagingController.appendPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
          nextPageKey,
        );
      }
    } catch (error) {
      _hotPagingController.error = error;
    }
  }

  Future<void> _fetchTopPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        communitySlug: widget.communitySlug,
        tagName: widget.tagName,
        query: query,
        orderBy: 'p.numLikes',
        postsPeriod: _topPostsPeriod,
        type: widget.fiterPosts == HejtoPage.articles
            ? 'article'
            : widget.fiterPosts == HejtoPage.discussions
                ? 'discussion'
                : null,
      );

      if (newItems == null) return;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _topPagingController.appendLastPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _topPagingController.appendPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
          nextPageKey,
        );
      }
    } catch (error) {
      _topPagingController.error = error;
    }
  }

  Future<void> _fetchNewPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        communitySlug: widget.communitySlug,
        tagName: widget.tagName,
        query: query,
        orderBy: 'p.createdAt',
        type: widget.fiterPosts == HejtoPage.articles
            ? 'article'
            : widget.fiterPosts == HejtoPage.discussions
                ? 'discussion'
                : null,
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _newPagingController.appendLastPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _newPagingController.appendPage(
          _filterLocallyBlockedUsers(
            _removeDoubledPosts(_newPagingController, newItems),
          ),
          nextPageKey,
        );
      }
    } catch (error) {
      _newPagingController.error = error;
    }
  }

  Future<void> _fetchFollowedPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        orderBy: 'p.createdAt',
        followed: true,
        type: widget.fiterPosts == HejtoPage.articles
            ? 'article'
            : widget.fiterPosts == HejtoPage.discussions
                ? 'discussion'
                : null,
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _followedPagingController.appendLastPage(newItems);
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _followedPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _followedPagingController.error = error;
    }
  }

  List<Post> _removeDoubledPosts(
    PagingController<int, Post> controller,
    List<Post> items,
  ) {
    final checkedItems = List<Post>.empty(growable: true);
    final currentList = controller.itemList;
    if (currentList == null) {
      return items;
    }

    for (var item in items) {
      if (!currentList.any((element) => element.slug == item.slug)) {
        checkedItems.add(item);
      }
    }

    return checkedItems;
  }

  _refreshAllControllers() async {
    Future.delayed(Duration.zero, () async {
      Future.sync(
        () {
          _hotPagingController.refresh();
          _topPagingController.refresh();
          _newPagingController.refresh();
          _followedPagingController.refresh();
        },
      );
    });
  }

  @override
  void initState() {
    _hotPagingController.addPageRequestListener((pageKey) {
      _fetchHotPage(pageKey);
    });

    _topPagingController.addPageRequestListener((pageKey) {
      _fetchTopPage(pageKey);
    });

    _newPagingController.addPageRequestListener((pageKey) {
      _fetchNewPage(pageKey);
    });

    if (widget.showFollowedTab) {
      _followedPagingController.addPageRequestListener((pageKey) {
        _fetchFollowedPage(pageKey);
      });
    }

    super.initState();

    _tabController = TabController(
      length: widget.showFollowedTab ? 4 : 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hotPagingController.dispose();
    _topPagingController.dispose();
    _newPagingController.dispose();
    _followedPagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, state) {
        if (state is PreferencesSet) {
          _hotPostsPeriod = state.defaultHotPeriod;
          discussionsNavCubit.changeHotTabPeriod(state.defaultHotPeriod);

          return Column(
            children: [
              PostsSearchBar(
                show: widget.showSearchBar,
                focusNode: widget.focusNode,
              ),
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: Column(
                    children: [
                      _buildTabBar(),
                      StreamBuilder<String>(
                        stream: searchCubit.searchString,
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data != query) {
                              query = snapshot.data!;

                              _refreshAllControllers();
                            }
                          }
                          return Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: widget.showFollowedTab
                                  ? [
                                      _buildHotPostsTabBarView(),
                                      _buildTopPostsTabBarView(),
                                      _buildNewPostsTabBarView(),
                                      _buildFollowedPostsTabBarView(),
                                    ]
                                  : [
                                      _buildHotPostsTabBarView(),
                                      _buildTopPostsTabBarView(),
                                      _buildNewPostsTabBarView(),
                                    ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildHotPostsTabBarView() {
    return StreamBuilder<PostsPeriod>(
        stream: discussionsNavCubit.hotTabPeriod,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _hotPostsPeriod = snapshot.data!;
            _refreshAllControllers();
          }

          return PostsTabBarView(
            controller: _hotPagingController,
            topDropdown: _buildHotDropdown(),
          );
        });
  }

  Widget _buildTopPostsTabBarView() {
    return StreamBuilder<PostsPeriod>(
        stream: discussionsNavCubit.topTabPeriod,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _topPostsPeriod = snapshot.data!;
            _refreshAllControllers();
          }

          return PostsTabBarView(
            controller: _topPagingController,
            topDropdown: _buildTopDropdown(),
          );
        });
  }

  Widget _buildNewPostsTabBarView() {
    return PostsTabBarView(
      controller: _newPagingController,
    );
  }

  Widget _buildFollowedPostsTabBarView() {
    return PostsTabBarView(
      controller: _followedPagingController,
    );
  }

  Widget _buildHotDropdown() {
    final dropdownItems = _hotPeriods
        .map(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();

    return StreamBuilder<PostsPeriod>(
      stream: discussionsNavCubit.hotTabPeriod,
      builder: (BuildContext context, AsyncSnapshot<PostsPeriod> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                alignment: Alignment.center,
                items: dropdownItems,
                value: _getPostsPeriodString(snapshot.data),
                onChanged: (value) {
                  switch (value) {
                    case '3h':
                      discussionsNavCubit
                          .changeHotTabPeriod(PostsPeriod.threeHours);
                      break;
                    case '6h':
                      discussionsNavCubit
                          .changeHotTabPeriod(PostsPeriod.sixHours);
                      break;
                    case '12h':
                      discussionsNavCubit
                          .changeHotTabPeriod(PostsPeriod.twelveHours);
                      break;
                    case '24h':
                      discussionsNavCubit
                          .changeHotTabPeriod(PostsPeriod.twentyFourHours);
                      break;
                  }
                },
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTopDropdown() {
    final dropdownItems = _topPeriods
        .map(
          (String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
        .toList();

    return StreamBuilder<PostsPeriod>(
      stream: discussionsNavCubit.topTabPeriod,
      builder: (BuildContext context, AsyncSnapshot<PostsPeriod> snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                alignment: Alignment.center,
                items: dropdownItems,
                value: _getPostsPeriodString(snapshot.data),
                onChanged: (value) {
                  switch (value) {
                    case '7d':
                      discussionsNavCubit
                          .changeTopTabPeriod(PostsPeriod.sevenDays);
                      break;
                    case '30d':
                      discussionsNavCubit
                          .changeTopTabPeriod(PostsPeriod.thirtyDays);
                      break;
                    case 'Od początku':
                      discussionsNavCubit.changeTopTabPeriod(PostsPeriod.all);
                      break;
                  }
                },
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  String _getPostsPeriodString(PostsPeriod? postsPeriod) {
    switch (postsPeriod) {
      case PostsPeriod.threeHours:
        return '3h';
      case PostsPeriod.sixHours:
        return '6h';
      case PostsPeriod.twelveHours:
        return '12h';
      case PostsPeriod.twentyFourHours:
        return '24h';
      case PostsPeriod.sevenDays:
        return '7d';
      case PostsPeriod.thirtyDays:
        return '30d';
      case PostsPeriod.all:
        return 'Od początku';

      default:
        return '6h';
    }
  }

  Widget _buildTabBar() {
    return Builder(builder: (context) {
      return TabBar(
        controller: _tabController,
        onTap: (value) {
          if (value == _currentTab) {
            switch (value) {
              case 0:
                _hotPagingController.refresh();
                break;
              case 1:
                _topPagingController.refresh();
                break;
              case 2:
                _newPagingController.refresh();
                break;
              case 3:
                _followedPagingController.refresh();
                break;
            }
          } else {
            _currentTab = value;
          }
        },
        indicatorColor: primaryColor,
        labelColor: primaryColor,
        tabs: widget.showFollowedTab
            ? [
                _buildTab(context, 0, 'Gorące'),
                _buildTab(context, 1, 'Top'),
                _buildTab(context, 2, 'Nowe'),
                _buildTab(context, 3, 'Obserwowane'),
              ]
            : [
                _buildTab(context, 0, 'Gorące'),
                _buildTab(context, 1, 'Top'),
                _buildTab(context, 2, 'Nowe'),
              ],
      );
    });
  }

  Tab _buildTab(BuildContext context, int index, String text) {
    return Tab(
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}
