import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/hejto_tag.dart';
import 'package:hejtter/models/hejto_users_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/communities_screen/community_card.dart';
import 'package:hejtter/ui/search_screen/tag_card.dart';
import 'package:hejtter/ui/search_screen/user_card.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _selectedSearchType = SearchType.tag;
  static const _pageSize = 20;
  String searchQuery = '';

  // final PagingController<int, Post> _postsPagingController =
  //     PagingController(firstPageKey: 1);
  final PagingController<int, HejtoTag> _tagsPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, HejtoUser> _usersPagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Community> _communitiesPagingController =
      PagingController(firstPageKey: 1);

  // Future<void> _fetchPostsPage(int pageKey) async {
  //   try {
  //     final newItems = await hejtoApi.getPosts(
  //       pageKey: pageKey,
  //       pageSize: _pageSize,
  //       context: context,
  //       query: searchQuery,
  //       orderBy: 'p.createdAt',
  //       types: ['article', 'link', 'discussion', 'offer'],
  //     );

  //     if (newItems == null) return;

  //     final isLastPage = newItems.length < _pageSize;
  //     if (isLastPage) {
  //       if (!mounted) return;
  //       _postsPagingController.appendLastPage(
  //         filterLocallyBlockedUsers(
  //           removeDoubledPosts(_postsPagingController, newItems),
  //           context,
  //         ),
  //       );
  //     } else {
  //       if (!mounted) return;
  //       final nextPageKey = pageKey + 1;
  //       _postsPagingController.appendPage(
  //         filterLocallyBlockedUsers(
  //           removeDoubledPosts(_postsPagingController, newItems),
  //           context,
  //         ),
  //         nextPageKey,
  //       );
  //     }
  //   } catch (error) {
  //     _postsPagingController.error = error;
  //   }
  // }

  Future<void> _fetchTagsPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getTags(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        query: searchQuery,
        orderBy: 't.numPosts',
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _tagsPagingController.appendLastPage(newItems);
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _tagsPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _tagsPagingController.error = error;
    }
  }

  Future<void> _fetchUsersPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getUsers(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        query: searchQuery,
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        if (!mounted) return;
        _usersPagingController.appendLastPage(newItems);
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _usersPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _usersPagingController.error = error;
    }
  }

  Future<void> _fetchCommunitiesPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getCommunities(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        query: searchQuery,
      );

      if (newItems == null) return;

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _communitiesPagingController.appendLastPage(newItems);
      } else {
        if (!mounted) return;
        final nextPageKey = pageKey + 1;
        _communitiesPagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _communitiesPagingController.error = error;
    }
  }

  @override
  void initState() {
    // _postsPagingController.addPageRequestListener((pageKey) {
    //   _fetchPostsPage(pageKey);
    // });
    _tagsPagingController.addPageRequestListener((pageKey) {
      _fetchTagsPage(pageKey);
    });
    _usersPagingController.addPageRequestListener((pageKey) {
      _fetchUsersPage(pageKey);
    });
    _communitiesPagingController.addPageRequestListener((pageKey) {
      _fetchCommunitiesPage(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    // _postsPagingController.dispose();
    _tagsPagingController.dispose();
    _usersPagingController.dispose();
    _communitiesPagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        titleTextStyle: const TextStyle(fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: '...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });

                  switch (_selectedSearchType) {
                    // case SearchType.post:
                    //   _postsPagingController.refresh();
                    //   break;
                    case SearchType.tag:
                      _tagsPagingController.refresh();
                      break;
                    case SearchType.user:
                      _usersPagingController.refresh();
                      break;
                    case SearchType.community:
                      _communitiesPagingController.refresh();
                      break;
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: SearchTypeHeader(
                      onSelectionChanged: (Set<SearchType> newSelection) {
                        setState(() {
                          _selectedSearchType = newSelection.first;
                        });
                      },
                      selectedSearchType: _selectedSearchType,
                    ),
                    pinned: false,
                    floating: true,
                  ),
                  searchQuery.isNotEmpty
                      ? _buildSearchContent()
                      : const SliverToBoxAdapter(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSearchContent() {
    switch (_selectedSearchType) {
      // case SearchType.post:
      //   return PagedSliverList<int, Post>(
      //     pagingController: _postsPagingController,
      //     builderDelegate: PagedChildBuilderDelegate<Post>(
      //       itemBuilder: (context, item, index) => PostCard(item: item),
      //       firstPageProgressIndicatorBuilder: (context) =>
      //           LoadingAnimationWidget.fourRotatingDots(
      //         color: Theme.of(context).colorScheme.primary,
      //         size: 36,
      //       ),
      //       newPageProgressIndicatorBuilder: (context) =>
      //           LoadingAnimationWidget.fourRotatingDots(
      //         color: Theme.of(context).colorScheme.primary,
      //         size: 36,
      //       ),
      //     ),
      //   );
      case SearchType.tag:
        return PagedSliverList<int, HejtoTag>(
          pagingController: _tagsPagingController,
          builderDelegate: PagedChildBuilderDelegate<HejtoTag>(
            itemBuilder: (context, item, index) => TagCard(tag: item),
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
      case SearchType.user:
        return PagedSliverList<int, HejtoUser>(
          pagingController: _usersPagingController,
          builderDelegate: PagedChildBuilderDelegate<HejtoUser>(
            itemBuilder: (context, item, index) => UserCard(user: item),
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
      case SearchType.community:
        return PagedSliverList<int, Community>(
          pagingController: _communitiesPagingController,
          builderDelegate: PagedChildBuilderDelegate<Community>(
            itemBuilder: (context, item, index) => CommunityCard(item: item),
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

  Widget _buildAppBarTitle() {
    const duration = Duration(milliseconds: 20);

    switch (_selectedSearchType) {
      // case SearchType.post:
      //   return SizedBox(
      //     key: Key(_selectedSearchType.toString()),
      //     child: AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
      //       TyperAnimatedText('Szukaj wpisu', speed: duration),
      //     ]),
      //   );
      case SearchType.tag:
        return SizedBox(
          key: Key(_selectedSearchType.toString()),
          child: AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
            TyperAnimatedText('Szukaj tagu', speed: duration),
          ]),
        );
      case SearchType.user:
        return SizedBox(
          key: Key(_selectedSearchType.toString()),
          child: AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
            TyperAnimatedText('Szukaj użytkownika', speed: duration),
          ]),
        );
      case SearchType.community:
        return SizedBox(
          key: Key(_selectedSearchType.toString()),
          child: AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
            TyperAnimatedText('Szukaj społeczności', speed: duration),
          ]),
        );
    }
  }
}

class SearchTypeHeader extends SliverPersistentHeaderDelegate {
  const SearchTypeHeader({
    required this.selectedSearchType,
    required this.onSelectionChanged,
  });

  final SearchType selectedSearchType;
  final Function(Set<SearchType>)? onSelectionChanged;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surface,
      child: SegmentedButton<SearchType>(
        selected: <SearchType>{selectedSearchType},
        segments: const [
          // ButtonSegment(
          //   value: SearchType.post,
          //   label: FittedBox(child: Text('Wpisy')),
          // ),
          ButtonSegment(
            value: SearchType.tag,
            label: FittedBox(child: Text('Tagi')),
          ),
          ButtonSegment(
            value: SearchType.user,
            label: FittedBox(child: Text('Użytkownicy')),
          ),
          ButtonSegment(
            value: SearchType.community,
            label: FittedBox(child: Text('Społeczności')),
          ),
        ],
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
