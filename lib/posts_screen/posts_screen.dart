import 'package:flutter/material.dart';
import 'package:hejtter/posts_screen/posts_tab_view.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({
    super.key,
    required this.communityName,
  });

  final String communityName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(communityName),
      ),
      body: PostsTabView(
        communityName: communityName,
      ),
    );
  }
}
