import 'package:flutter/material.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_bar_view.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class FollowedScreen extends StatefulWidget {
  const FollowedScreen({super.key});

  @override
  State<FollowedScreen> createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen> {
  final PagingController<int, Post> _followedPagingController =
      PagingController(firstPageKey: 1);
  static const _pageSize = 20;

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

  @override
  void initState() {
    super.initState();

    _followedPagingController.addPageRequestListener((pageKey) {
      _fetchFollowedPage(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: const Text('Obserwowane'),
      ),
      body: PostsTabBarView(
        controller: _followedPagingController,
      ),
    );
  }
}
