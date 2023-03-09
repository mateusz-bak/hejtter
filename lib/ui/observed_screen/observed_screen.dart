import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/hejto_tag.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/communities_screen/widgets/widgets.dart';
import 'package:hejtter/ui/search_screen/widgets/widgets.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ObservedScreen extends StatefulWidget {
  const ObservedScreen({
    super.key,
    this.getCommunities,
    this.getBlockedCommunities,
    this.getTags,
    this.getBlockedTags,
  });

  final bool? getCommunities;
  final bool? getBlockedCommunities;
  final bool? getTags;
  final bool? getBlockedTags;

  @override
  State<ObservedScreen> createState() => _ObservedScreenState();
}

class _ObservedScreenState extends State<ObservedScreen> {
  static const _pageSize = 20;

  final PagingController<int, Community> _communitiesPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, HejtoTag> _tagsPagingController =
      PagingController(firstPageKey: 1);

  Future<void> _fetchCommunities(int pageKey) async {
    try {
      final newItems = await hejtoApi.getCommunities(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        belonged: widget.getCommunities,
        blocked: widget.getBlockedCommunities,
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _communitiesPagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _communitiesPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _communitiesPagingController.error = error;
    }
  }

  Future<void> _fetchTags(int pageKey) async {
    try {
      final newItems = await hejtoApi.getTags(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        orderBy: 't.numPosts',
        followed: widget.getTags,
        blocked: widget.getBlockedTags,
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _tagsPagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _tagsPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _tagsPagingController.error = error;
    }
  }

  @override
  void initState() {
    if (widget.getCommunities == true || widget.getBlockedCommunities == true) {
      _communitiesPagingController.addPageRequestListener((pageKey) {
        _fetchCommunities(pageKey);
      });
    }
    if (widget.getTags == true || widget.getBlockedTags == true) {
      _tagsPagingController.addPageRequestListener((pageKey) {
        _fetchTags(pageKey);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _communitiesPagingController.dispose();
    _tagsPagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: (widget.getCommunities == true ||
              widget.getBlockedCommunities == true)
          ? Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: boltColor,
                    onRefresh: () => Future.sync(
                      () => _communitiesPagingController.refresh(),
                    ),
                    child: PagedListView<int, Community>(
                      pagingController: _communitiesPagingController,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      builderDelegate: PagedChildBuilderDelegate<Community>(
                        itemBuilder: (context, item, index) =>
                            CommunityCard(item: item),
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
                )
              ],
            )
          : (widget.getTags == true || widget.getBlockedTags == true)
              ? Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: boltColor,
                        onRefresh: () => Future.sync(
                          () => _communitiesPagingController.refresh(),
                        ),
                        child: PagedListView<int, HejtoTag>(
                          pagingController: _tagsPagingController,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          builderDelegate: PagedChildBuilderDelegate<HejtoTag>(
                            itemBuilder: (context, item, index) =>
                                TagCard(tag: item),
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
                    )
                  ],
                )
              : const SizedBox(),
    );
  }
}
