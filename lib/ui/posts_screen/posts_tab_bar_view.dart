import 'package:flutter/material.dart';

import 'package:hejtter/models/post.dart';
import 'package:hejtter/ui/posts_screen/post_card.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
      child: Column(
        children: [
          widget.topDropdown,
          Expanded(
            child: PagedListView<int, Post>(
              pagingController: widget.controller,
              padding: const EdgeInsets.all(5),
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, item, index) => PostCard(item: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
