import 'package:flutter/material.dart';

import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';

import 'package:hejtter/ui/community_screen/community_app_bar.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';
import 'package:hejtter/utils/helpers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    required this.community,
  });

  final Community community;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);
  static const _pageSize = 20;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        communitySlug: widget.community.slug,
        orderBy: 'p.createdAt',
        types: ['article', 'link', 'discussion', 'offer'],
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _pagingController.appendLastPage(
          filterLocallyBlockedUsers(
            removeDoubledPosts(_pagingController, newItems),
            context,
          ),
        );
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
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
    }
  }

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CommunityAppBar(community: widget.community),
          _buildCommunityPosts(),
        ],
      ),
    );
  }

  _buildCommunityPosts() {
    return PagedSliverList<int, Post>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Post>(
        itemBuilder: (context, item, index) => PostCard(item: item),
        firstPageProgressIndicatorBuilder: (context) =>
            LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        newPageProgressIndicatorBuilder: (context) =>
            LoadingAnimationWidget.fourRotatingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
      ),
    );
  }
}
