import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/posts_screen/posts_search_bar.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_bar_view.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class PostsTabView extends StatefulWidget {
  const PostsTabView({
    super.key,
    this.showSearchBar = false,
    this.focusNode,
    this.communitySlug,
    this.tagName,
  });

  final bool showSearchBar;
  final String? communitySlug;
  final String? tagName;
  final FocusNode? focusNode;

  @override
  State<PostsTabView> createState() => _PostsTabViewState();
}

class _PostsTabViewState extends State<PostsTabView> {
  static const _pageSize = 20;
  String query = '';

  final List<String> items = [
    '6h',
    '12h',
    '24h',
    'Tydzień',
    'Od początku',
  ];
  String _postsPeriod = '6h';

  final PagingController<int, Post> _hotPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Post> _topPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Post> _newPagingController =
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
        orderBy: 'p.hot',
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _hotPagingController.appendLastPage(
          _removeDoubledPosts(_newPagingController, newItems),
        );
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _hotPagingController.appendPage(
          _removeDoubledPosts(_newPagingController, newItems),
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
        postsPeriod: _postsPeriod,
      );

      if (newItems == null) return;
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _topPagingController.appendLastPage(
          _removeDoubledPosts(_newPagingController, newItems),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _topPagingController.appendPage(
          _removeDoubledPosts(_newPagingController, newItems),
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
          _removeDoubledPosts(_newPagingController, newItems),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _newPagingController.appendPage(
          _removeDoubledPosts(_newPagingController, newItems),
          nextPageKey,
        );
      }
    } catch (error) {
      _newPagingController.error = error;
    }
  }

  List<Post> _removeDoubledPosts(
    PagingController<int, dynamic> controller,
    List<Post> items,
  ) {
    final checkedItems = List<Post>.empty(growable: true);
    final currentList = controller.itemList;

    for (var item in items) {
      if (currentList?.contains(item) != true) {
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

    super.initState();
  }

  @override
  void dispose() {
    _hotPagingController.dispose();
    _topPagingController.dispose();
    _newPagingController.dispose();

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
              length: 3,
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
                          children: [
                            PostsTabBarView(controller: _hotPagingController),
                            PostsTabBarView(
                              controller: _topPagingController,
                              topDropdown: _buildTopDropdown(),
                            ),
                            PostsTabBarView(controller: _newPagingController),
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
        indicatorColor: const Color(0xff2295F3),
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
        tabs: [
          _buildTab(context, 0, 'Gorące'),
          _buildTab(context, 1, 'Top'),
          _buildTab(context, 2, 'Nowe'),
        ],
      );
    });
  }

  Tab _buildTab(BuildContext context, int index, String text) {
    return Tab(
      child: GestureDetector(
        onTap: (() {
          if (DefaultTabController.of(context)?.index == index) {
            switch (index) {
              case 0:
                _hotPagingController.refresh();
                break;
              case 1:
                _topPagingController.refresh();
                break;
              case 2:
                _newPagingController.refresh();
                break;
            }
          } else {
            DefaultTabController.of(context)?.animateTo(index);
          }
        }),
        child: Text(text),
      ),
    );
  }

  Widget _buildTopDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            buttonWidth: MediaQuery.of(context).size.width,
            hint: Text(
              'Wybierz pozycję',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ))
                .toList(),
            value: _postsPeriod,
            onChanged: (value) {
              setState(() {
                _postsPeriod = value as String;
              });

              Future.sync(
                () => _topPagingController.refresh(),
              );
            },
          ),
        ),
      ),
    );
  }
}
