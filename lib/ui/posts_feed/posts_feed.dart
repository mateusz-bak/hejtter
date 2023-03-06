import 'package:flutter/material.dart';

import 'package:hejtter/models/post.dart';
import 'package:hejtter/ui/posts_feed/widgets/widgets.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PostsFeed extends StatefulWidget {
  const PostsFeed({
    super.key,
    required this.pagingController,
  });

  final PagingController<int, Post> pagingController;

  @override
  State<PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<PostsFeed>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      edgeOffset: MediaQuery.of(context).padding.top,
      color: boltColor,
      onRefresh: () => Future.sync(
        () => widget.pagingController.refresh(),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 30,
              ),
              sliver: PagedSliverList<int, Post>(
                pagingController: widget.pagingController,
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
            ),
          ],
        ),
      ),
    );
  }
}
