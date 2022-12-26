import 'package:flutter/material.dart';
import 'package:hejtter/posts_screen/post_card.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hejtter/models/posts_response.dart';

class NewPostsTabBarView extends StatefulWidget {
  const NewPostsTabBarView({
    super.key,
    required this.controller,
    this.topDropdown = const SizedBox(),
  });

  final PagingController<int, PostItem> controller;
  final Widget topDropdown;

  @override
  State<NewPostsTabBarView> createState() => _NewPostsTabBarViewState();
}

class _NewPostsTabBarViewState extends State<NewPostsTabBarView>
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
            child: PagedListView<int, PostItem>(
              pagingController: widget.controller,
              padding: const EdgeInsets.all(10),
              builderDelegate: PagedChildBuilderDelegate<PostItem>(
                itemBuilder: (context, item, index) => PostCard(item: item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
