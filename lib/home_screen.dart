import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/communities_screen.dart';
import 'package:hejtter/posts_response.dart';
import 'package:hejtter/post_card.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final client = http.Client();
  String _postsOrder = 'p.hot';
  static const _pageSize = 5;

  final List<String> items = [
    '6h',
    '12h',
    '24h',
    'tydzień',
    'od początku',
  ];
  String _postsPeriod = '6h';

  final PagingController<int, PostItem> _pagingController =
      PagingController(firstPageKey: 1);

  Future<List<PostItem>?> _getPosts(int pageKey, int pageSize) async {
    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
      'orderBy': _postsOrder,
    };

    if (_postsOrder == 'numLikes') {
      switch (_postsPeriod) {
        case '6h':
          queryParameters.addEntries(<String, String>{
            'period': '6h',
          }.entries);
          break;
        case '12h':
          queryParameters.addEntries(<String, String>{
            'period': '12h',
          }.entries);
          break;
        case '24h':
          queryParameters.addEntries(<String, String>{
            'period': '24h',
          }.entries);
          break;
        case 'tydzień':
          queryParameters.addEntries(<String, String>{
            'period': 'week',
          }.entries);
          break;
        default:
          break;
      }
    }

    var response = await client.get(
      Uri.https('api.hejto.pl', '/posts', queryParameters),
    );

    return postFromJson(response.body).embedded?.items;
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
        child: ListView(
          padding: EdgeInsets.zero,
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
              onTap: () {},
            ),
            ListTile(
              title: const Text('Społeczności'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunitiesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          Row(
            children: [
              const SizedBox(width: 15),
              _buildHotButton(),
              const SizedBox(width: 10),
              _buildTopButton(),
              _buildTopDropdown(),
              const SizedBox(width: 10),
              _buildNewButton(),
            ],
          ),
          const SizedBox(height: 5),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _pagingController.refresh(),
              ),
              child: PagedListView<int, PostItem>(
                pagingController: _pagingController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                builderDelegate: PagedChildBuilderDelegate<PostItem>(
                  itemBuilder: (context, item, index) => PostCard(item: item),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildNewButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _postsOrder == 'p.createdAt' ? Colors.black54 : null,
      ),
      onPressed: () {
        setState(() {
          _postsOrder = 'p.createdAt';
        });

        Future.sync(
          () => _pagingController.refresh(),
        );
      },
      child: const Text(
        'Nowe',
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  ElevatedButton _buildTopButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _postsOrder == 'numLikes' ? Colors.black54 : null,
      ),
      onPressed: () {
        setState(() {
          _postsOrder = 'numLikes';
        });

        Future.sync(
          () => _pagingController.refresh(),
        );
      },
      child: const Text(
        'Top',
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  ElevatedButton _buildHotButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _postsOrder == 'p.hot' ? Colors.black54 : null,
      ),
      onPressed: () {
        setState(() {
          _postsOrder = 'p.hot';
        });

        Future.sync(
          () => _pagingController.refresh(),
        );
      },
      child: const Text(
        'Gorące',
        style: TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildTopDropdown() {
    return _postsOrder == 'numLikes'
        ? Row(
            children: [
              const SizedBox(width: 10),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  hint: Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                  value: _postsPeriod,
                  onChanged: (value) {
                    setState(() {
                      _postsPeriod = value as String;
                    });

                    Future.sync(
                      () => _pagingController.refresh(),
                    );
                  },
                  // buttonHeight: 40,
                  // buttonWidth: 140,
                  // itemHeight: 40,
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
