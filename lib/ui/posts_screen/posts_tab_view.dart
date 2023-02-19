import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/posts_search_bar.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_bar_view.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:hejtter/utils/helpers.dart';

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
        types: _decidePostsTypes(),
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _hotPagingController.appendLastPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_hotPagingController, newItems),
            context,
          ),
        );
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _hotPagingController.appendPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_hotPagingController, newItems),
            context,
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
        types: _decidePostsTypes(),
      );

      if (newItems == null) return;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _topPagingController.appendLastPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_topPagingController, newItems),
            context,
          ),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _topPagingController.appendPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_topPagingController, newItems),
            context,
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
        types: _decidePostsTypes(),
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _newPagingController.appendLastPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_newPagingController, newItems),
            context,
          ),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _newPagingController.appendPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_newPagingController, newItems),
            context,
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
        types: _decidePostsTypes(),
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

  List<String> _decidePostsTypes() {
    switch (widget.fiterPosts) {
      case HejtoPage.articles:
        return ['article', 'link'];
      case HejtoPage.discussions:
        return ['discussion'];
      default:
        return ['article', 'link', 'discussion', 'offer'];
    }
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
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 3,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
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
          return Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 3,
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
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
