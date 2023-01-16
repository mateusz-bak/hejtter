import 'package:flutter/material.dart';

import 'package:hejtter/models/communities_response.dart';

import 'package:hejtter/ui/communities_screen/community_app_bar.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/utils/constants.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    required this.community,
  });

  final Community community;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, value) {
          return [
            CommunityAppBar(community: widget.community),
          ];
        },
        body: PostsTabView(
          communitySlug: widget.community.slug,
        ),
      ),
    );
  }
}
