import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/period_button.dart';
import 'package:hejtter/ui/posts_screen/posts_search_bar.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_bar_view.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostsTabView extends StatefulWidget {
  const PostsTabView({
    super.key,
    this.showSearchBar = false,
    this.focusNode,
    this.communitySlug,
    this.tagName,
    this.showFollowedTab = false,
  });

  final bool showSearchBar;
  final bool showFollowedTab;
  final String? communitySlug;
  final String? tagName;
  final FocusNode? focusNode;

  @override
  State<PostsTabView> createState() => _PostsTabViewState();
}

class _PostsTabViewState extends State<PostsTabView>
    with TickerProviderStateMixin {
  int _currentTab = 0;
  int _selectedPeriod = 0;

  static const _pageSize = 20;
  String query = '';

  late AnimationController _periodButtonsAnimationController;
  late Animation<double> _periodButtonsAnimation;

  late TabController _tabController;

  final List<String> periodItems = [
    '6h',
    '12h',
    '24h',
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

  _animatePeriodButtons(bool show) {
    if (show) {
      _periodButtonsAnimationController.forward();
    } else {
      _periodButtonsAnimationController.animateBack(
        0,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

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
        postsPeriod: _selectedPeriod,
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
        postsPeriod: _selectedPeriod,
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
      );

      final isLastPage = newItems!.length < _pageSize;
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
      );

      final isLastPage = newItems!.length < _pageSize;
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

    _periodButtonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: 1,
    );

    _periodButtonsAnimation = CurvedAnimation(
      parent: _periodButtonsAnimationController,
      curve: Curves.easeIn,
    );

    _tabController = TabController(
      length: widget.showFollowedTab ? 4 : 3,
      vsync: this,
    );

    _tabController.addListener(() {
      final index = _tabController.index;

      if (index == 0 || index == 1) {
        _animatePeriodButtons(true);
      } else {
        _animatePeriodButtons(false);
      }
    });
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
    return Column(
      children: [
        PostsSearchBar(
          show: widget.showSearchBar,
          focusNode: widget.focusNode,
        ),
        Expanded(
          child: Container(
            color: backgroundColor,
            child: DefaultTabController(
              length: widget.showFollowedTab ? 4 : 3,
              child: Column(
                children: [
                  _buildTabBar(),
                  _buildPerdionButtons(),
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
                                  PostsTabBarView(
                                    controller: _hotPagingController,
                                  ),
                                  PostsTabBarView(
                                    controller: _topPagingController,
                                  ),
                                  PostsTabBarView(
                                    controller: _newPagingController,
                                  ),
                                  PostsTabBarView(
                                    controller: _followedPagingController,
                                  ),
                                ]
                              : [
                                  PostsTabBarView(
                                    controller: _hotPagingController,
                                  ),
                                  PostsTabBarView(
                                    controller: _topPagingController,
                                  ),
                                  PostsTabBarView(
                                    controller: _newPagingController,
                                  ),
                                ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
            setState(() {
              _currentTab = value;
            });
          }
        },
        indicatorColor: const Color(0xff2295F3),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: widget.showFollowedTab
            ? [
                _buildTab(context, 0, 'Gorące'),
                _buildTab(context, 1, 'Top'),
                _buildTab(context, 2, 'Nowe'),
                _buildTab(context, 3, 'Obserwowane')
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

  Widget _buildPerdionButtons() {
    return SizeTransition(
      sizeFactor: _periodButtonsAnimation,
      axis: Axis.vertical,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildPeriodButton(0),
                    _buildPeriodButton(1),
                    _buildPeriodButton(2),
                    _buildPeriodButton(3),
                    _buildPeriodButton(4),
                    _buildPeriodButton(5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(int index) {
    return PeriodButton(
      period: periodItems[index],
      selected: _selectedPeriod == index,
      onPressed: () {
        setState(() {
          _selectedPeriod = index;
        });

        _hotPagingController.refresh();
        _topPagingController.refresh();
      },
    );
  }
}
