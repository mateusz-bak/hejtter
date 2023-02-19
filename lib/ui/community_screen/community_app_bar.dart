import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:hejtter/models/communities_response.dart';

class CommunityAppBar extends StatelessWidget {
  const CommunityAppBar({
    Key? key,
    required this.community,
    required this.changeCommunityMembership,
    required this.changingMembershipState,
  }) : super(key: key);

  final Community community;
  final Function(bool) changeCommunityMembership;
  final bool changingMembershipState;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      pinned: true,
      actions: [
        community.memberRole == 'owner'
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(right: 16),
                child: community.isMember == true
                    ? FilledButton.tonal(
                        onPressed: () => changeCommunityMembership(false),
                        child: changingMembershipState
                            ? const SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Opuść'),
                      )
                    : FilledButton(
                        onPressed: () => changeCommunityMembership(true),
                        child: changingMembershipState
                            ? const SizedBox(
                                height: 12,
                                width: 12,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Dołącz'),
                      ),
              ),
      ],
      title: Row(
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: community.background?.urls?.the1200X900 != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      color: Theme.of(context).colorScheme.onSurface,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CachedNetworkImage(
                          imageUrl: community.background!.urls!.the1200X900!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${community.name}',
              softWrap: false,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}
