import 'package:flutter/material.dart';

import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
    this.communityName,
    this.communitySlug,
    this.tagName,
  });

  final String? communityName;
  final String? communitySlug;
  final String? tagName;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.communityName ?? '#${widget.tagName}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: PostsTabView(
        communitySlug: widget.communitySlug,
        tagName: widget.tagName,
        focusNode: focusNode,
      ),
    );
  }
}
