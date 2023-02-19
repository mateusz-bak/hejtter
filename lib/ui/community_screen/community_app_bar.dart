import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({
    Key? key,
    required this.community,
  }) : super(key: key);

  final Community community;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      pinned: true,
      title: Row(
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: community.background?.urls?.the1200X900 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: CachedNetworkImage(
                      imageUrl: community.background!.urls!.the1200X900!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 10),
          Text('${community.name}'),
        ],
      ),
    );
  }
}
