import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/communities_screen/community_card.dart';
import 'package:hejtter/home_screen/home_screen.dart';
import 'package:hejtter/login_screen/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final client = http.Client();
  static const _pageSize = 10;

  final PagingController<int, Item> _pagingController =
      PagingController(firstPageKey: 1);

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<List<Item>?> _getPosts(int pageKey, int pageSize) async {
    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderBy': 'numMembers',
      'orderDir': 'desc',
    };

    var response = await client.get(
      Uri.https('api.hejto.pl', '/communities', queryParameters),
    );

    return communitiesResponseFromJson(response.body).embedded?.items;
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _getPosts(pageKey, _pageSize);
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
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Strona główna'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            ListTile(
              title: const Text('Społeczności'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Zaloguj się'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const Expanded(
              child: SizedBox(),
            ),
            FutureBuilder(
              future: _getAppVersion(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return ListTile(
                    title: Text(snapshot.data.toString()),
                    onTap: () {},
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _pagingController.refresh(),
              ),
              child: PagedListView<int, Item>(
                pagingController: _pagingController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                builderDelegate: PagedChildBuilderDelegate<Item>(
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
