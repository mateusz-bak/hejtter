import 'package:flutter/material.dart';
import 'package:hejtter/posts_screen/posts_tab_view.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({
    super.key,
    this.communityName,
    this.tagName,
  });

  final String? communityName;
  final String? tagName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(communityName ?? '#$tagName'),
      ),
      body: PostsTabView(
        communityName: communityName,
        tagName: tagName,
      ),
    );
  }
}
