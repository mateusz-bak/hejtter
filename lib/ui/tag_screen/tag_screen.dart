import 'package:flutter/material.dart';

import 'package:hejtter/models/hejto_tag.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';

import 'package:hejtter/ui/posts_screen/post_card.dart';
import 'package:hejtter/ui/tag_screen/tag_app_bar.dart';
import 'package:hejtter/utils/helpers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({
    super.key,
    required this.tag,
  });

  final String? tag;

  @override
  State<TagScreen> createState() => _TagScreenState();
}

class _TagScreenState extends State<TagScreen> {
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);
  static const _pageSize = 20;

  HejtoTag? hejtoTag;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        tagName: widget.tag,
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

  _changeTagFollowState(bool newState) async {
    if (widget.tag == null) return;

    if (newState) {
      await hejtoApi.followTag(
        context: context,
        tag: widget.tag!,
      );

      await _loadCommunityDetails(true);
    } else {
      await hejtoApi.unfollowTag(
        context: context,
        tag: widget.tag!,
      );

      await _loadCommunityDetails(true);
    }
  }

  _changeTagBlockState(bool newState) async {
    if (widget.tag == null) return;

    if (newState) {
      await hejtoApi.blockTag(
        context: context,
        tag: widget.tag!,
      );

      await _loadCommunityDetails(true);
    } else {
      await hejtoApi.unblockTag(
        context: context,
        tag: widget.tag!,
      );

      await _loadCommunityDetails(true);
    }
  }

  _loadCommunityDetails(bool update) async {
    if (widget.tag == null) return;

    final response = await hejtoApi.getTagDetails(
      context: context,
      tag: widget.tag!,
    );

    if (update) {
      setState(() {
        hejtoTag = response;
      });
    } else {
      hejtoTag = response;
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
    return FutureBuilder<dynamic>(
      future: _loadCommunityDetails(false),
      builder: (context, snapshot) {
        if (hejtoTag == null) {
          return Scaffold(
            body: CustomScrollView(slivers: [
              SliverAppBar.large(
                title: const SizedBox(),
              ),
            ]),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              TagAppBar(
                tag: hejtoTag!,
                changeTagFollowState: _changeTagFollowState,
                changeTagBlockState: _changeTagBlockState,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Text(hejtoTag!.numFollows.toString()),
                      Text(
                        ' obserwujących',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(hejtoTag!.numPosts.toString()),
                      Text(
                        ' wpisów',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCommunityPosts(),
            ],
          ),
        );
      },
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
