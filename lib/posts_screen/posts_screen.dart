import 'package:flutter/material.dart';
import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/posts_screen/posts_tab_view.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
    this.communityName,
    this.tagName,
  });

  final String? communityName;
  final String? tagName;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  FocusNode focusNode = FocusNode();
  var _showSearchBar = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName ?? '#${widget.tagName}'),
        actions: [
          _buildSearchButton(context),
        ],
      ),
      body: PostsTabView(
        communityName: widget.communityName,
        tagName: widget.tagName,
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
