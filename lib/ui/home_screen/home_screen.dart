import 'package:flutter/material.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';

import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/ui/web_login_screen/web_login_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<String> _getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode focusNode = FocusNode();
  var _showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hejtter'),
        actions: [_buildSearchButton(context)],
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
            ListTile(
              title: const Text('Zaloguj się w aplikacji'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            ListTile(
              title: const Text('Zaloguj się przez przeglądarkę'),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const WebLoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const Expanded(
              child: SizedBox(),
            ),
            ListTile(
              title: const Text('Github'),
              onTap: () {
                launchUrl(
                  Uri.parse('https://github.com/mateusz-bak/hejtter'),
                  mode: LaunchMode.externalApplication,
                );
              },
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
      body: PostsTabView(
        showSearchBar: _showSearchBar,
        focusNode: focusNode,
      ),
    );
  }

  IconButton _buildSearchButton(BuildContext context) {
    return IconButton(
      onPressed: (() {
        setState(() {
          _showSearchBar = !_showSearchBar;
          searchCubit.changeString('');

          if (_showSearchBar) {
            FocusScope.of(context).requestFocus(focusNode);
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        });
      }),
      icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
    );
  }
}
