import 'package:flutter/material.dart';

import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/community_screen/widgets/widgets.dart';
import 'package:hejtter/ui/posts_feed/widgets/widgets.dart';

import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/helpers.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    required this.communitySlug,
  });

  final String? communitySlug;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);
  static const _pageSize = 20;

  Community? community;

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getPosts(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        communitySlug: widget.communitySlug,
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

  _changeCommunityMembership(bool newState) async {
    if (widget.communitySlug == null) return;

    if (newState) {
      await hejtoApi.joinCommunity(
        context: context,
        communitySlug: widget.communitySlug!,
      );

      await _loadCommunityDetails(true);
    } else {
      await hejtoApi.leaveCommunity(
        context: context,
        communitySlug: widget.communitySlug!,
      );

      await _loadCommunityDetails(true);
    }
  }

  _changeCommunityBlockState(bool newState) async {
    if (widget.communitySlug == null) return;

    if (newState) {
      await hejtoApi.blockCommunity(
        context: context,
        communitySlug: widget.communitySlug!,
      );

      await _loadCommunityDetails(true);
    } else {
      await hejtoApi.unblockCommunity(
        context: context,
        communitySlug: widget.communitySlug!,
      );

      await _loadCommunityDetails(true);
    }
  }

  _loadCommunityDetails(bool update) async {
    if (widget.communitySlug == null) return;

    final response = await hejtoApi.getCommunityDetails(
      context: context,
      communitySlug: widget.communitySlug!,
    );

    if (update) {
      setState(() {
        community = response;
      });
    } else {
      community = response;
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
        if (community == null) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: CustomScrollView(slivers: [
              SliverAppBar.large(
                backgroundColor: backgroundColor,
                title: const SizedBox(),
              ),
            ]),
          );
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
              CommunityAppBar(
                community: community!,
                changeCommunityMembership: _changeCommunityMembership,
                changeCommunityBlockState: _changeCommunityBlockState,
              ),
            ],
            body: RefreshIndicator(
              color: boltColor,
              onRefresh: () async {
                _pagingController.refresh();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(community!.numMembers.toString()),
                        Text(
                          ' członków',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(community!.numPosts.toString()),
                        Text(
                          ' wpisów',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCommunityPosts(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityPosts() {
    return Expanded(
      child: PagedListView<int, Post>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, item, index) => PostCard(item: item),
          firstPageProgressIndicatorBuilder: (context) =>
              LoadingAnimationWidget.threeArchedCircle(
            color: boltColor,
            size: 36,
          ),
          newPageProgressIndicatorBuilder: (context) =>
              LoadingAnimationWidget.threeArchedCircle(
            color: boltColor,
            size: 36,
          ),
        ),
      ),
    );
  }
}
