import 'package:flutter/material.dart';

import 'package:hejtter/models/post.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostsTabBarView extends StatefulWidget {
  const PostsTabBarView({
    super.key,
    required this.controller,
    this.topDropdown,
  });

  final PagingController<int, Post> controller;
  final Widget? topDropdown;

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
            widget.topDropdown != null
                ? SliverPersistentHeader(
                    delegate:
                        PeriodDropdownHeader(dropdown: widget.topDropdown!),
                    pinned: false,
                    floating: true,
                  )
                : const SliverToBoxAdapter(),
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

class PeriodDropdownHeader extends SliverPersistentHeaderDelegate {
  const PeriodDropdownHeader({
    required this.dropdown,
  });

  final Widget dropdown;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return dropdown;
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
