import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/communities_screen/community_card.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';

import 'package:hejtter/utils/enums.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final client = http.Client();
  static const _pageSize = 10;

  final PagingController<int, Community> _pagingController =
      PagingController(firstPageKey: 1);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getCommunities(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Społeczności'),
      ),
      drawer: const HejtoDrawer(currentScreen: CurrentScreen.communities),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _pagingController.refresh(),
              ),
              child: PagedListView<int, Community>(
                pagingController: _pagingController,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                builderDelegate: PagedChildBuilderDelegate<Community>(
                  itemBuilder: (context, item, index) =>
                      CommunityCard(item: item),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
