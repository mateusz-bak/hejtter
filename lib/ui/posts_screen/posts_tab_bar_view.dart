import 'package:flutter/material.dart';

import 'package:hejtter/models/post.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostsTabBarView extends StatefulWidget {
  const PostsTabBarView({
    super.key,
    required this.controller,
    this.topDropdown = const SizedBox(),
  });

  final PagingController<int, Post> controller;
  final Widget topDropdown;

  @override
  State<PostsTabBarView> createState() => _PostsTabBarViewState();
}

class _PostsTabBarViewState extends State<PostsTabBarView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => widget.controller.refresh(),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: widget.topDropdown,
            ),
            PagedSliverList<int, Post>(
              pagingController: widget.controller,
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
            ),
          ],
        ),
      ),
    );
  }
}
