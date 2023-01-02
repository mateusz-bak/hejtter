import 'package:flutter/material.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/utils/enums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
      drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
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
