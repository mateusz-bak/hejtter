import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';

import 'package:hejtter/utils/constants.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({
    Key? key,
    required this.community,
  }) : super(key: key);

  final Community community;

  @override
  Widget build(BuildContext context) {
    const expandedHeight = 300.0;
    const collapsedHeight = 60.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      pinned: true,
      backgroundColor: backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 50),
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                    height: 32,
                    width: 32,
                    fit: BoxFit.cover,
                    imageUrl: community.avatar?.urls?.the250X250 != null
                        ? community.avatar!.urls!.the250X250!
                        : 'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                '${community.name}',
                style: const TextStyle(fontSize: 28, color: Colors.white),
                textScaleFactor: 0.7,
              ),
            ),
          ],
        ),
        centerTitle: true,
        background: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: expandedHeight - collapsedHeight - 0,
                child: community.background?.urls?.the1200X900 != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: community.background!.urls!.the1200X900!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
            // Positioned(
            //   bottom: collapsedHeight + 20,
            //   left: MediaQuery.of(context).size.width / 2 - 70,
            //   child: Container(
            //     padding: const EdgeInsets.all(2),
            //     decoration: BoxDecoration(
            //       color: Colors.white38,
            //       borderRadius: BorderRadius.circular(20),
            //     ),
            //     child: ClipRRect(
            //       borderRadius: BorderRadius.circular(18),
            //       child: CachedNetworkImage(
            //           height: 136,
            //           width: 136,
            //           fit: BoxFit.cover,
            //           imageUrl: community.avatar?.urls?.the250X250 != null
            //               ? community.avatar!.urls!.the250X250!
            //               : 'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75'),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
