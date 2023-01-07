import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';

import 'package:hejtter/models/user_details_response.dart';
import 'package:hejtter/utils/constants.dart';

class UserAppBar extends StatelessWidget {
  const UserAppBar({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UserDetailsResponse user;

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
            Text(
              '${user.username}',
              style: const TextStyle(fontSize: 28, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 0.7,
            ),
            user.sponsor == true
                ? Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Transform.rotate(
                      angle: 180,
                      child: const Icon(
                        Icons.mode_night_rounded,
                        color: Colors.brown,
                        size: 20,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        centerTitle: true,
        background: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: expandedHeight - collapsedHeight - 20,
                child: user.background?.urls?.the1200X900 != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: user.background!.urls!.the1200X900!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox(),
              ),
            ),
            Positioned(
              bottom: collapsedHeight + 20,
              left: MediaQuery.of(context).size.width / 2 - 70,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                      height: 136,
                      width: 136,
                      fit: BoxFit.cover,
                      imageUrl: user.avatar?.urls?.the250X250 != null
                          ? user.avatar!.urls!.the250X250!
                          : 'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
