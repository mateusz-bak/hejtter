import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/utils/constants.dart';

class CommunityAppBar extends StatelessWidget {
  CommunityAppBar({
    Key? key,
    required this.community,
    required this.changeCommunityMembership,
    required this.changeCommunityBlockState,
  }) : super(key: key);

  final Community community;
  final Function(bool) changeCommunityMembership;
  final Function(bool) changeCommunityBlockState;

  late final Set<String> moreButtonOptions;
  final moreButtonOptionsMember = {'Opuść'};
  final moreButtonOptionsNotAMember = {'Dołącz'};

  _preparePopMenuOptions() {
    if (community.isMember == true) {
      moreButtonOptions = moreButtonOptionsMember;
    } else {
      moreButtonOptions = moreButtonOptionsNotAMember;
    }

    if (community.isBlocked == true) {
      moreButtonOptions.add('Odblokuj');
    } else {
      moreButtonOptions.add('Zablokuj');
    }
  }

  @override
  Widget build(BuildContext context) {
    _preparePopMenuOptions();

    return SliverAppBar.large(
      backgroundColor: backgroundColor,
      scrolledUnderElevation: 0,
      elevation: 0,
      pinned: true,
      actions: [
        (context.read<ProfileBloc>().state is ProfilePresentState)
            ? PopupMenuButton<String>(
                onSelected: (_) {},
                itemBuilder: (BuildContext context) {
                  return moreButtonOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                      onTap: () {
                        if (choice == 'Opuść') {
                          changeCommunityMembership(false);
                        } else if (choice == 'Dołącz') {
                          changeCommunityMembership(true);
                        } else if (choice == 'Odblokuj') {
                          changeCommunityBlockState(false);
                        } else if (choice == 'Zablokuj') {
                          changeCommunityBlockState(true);
                        }
                      },
                    );
                  }).toList();
                },
              )
            : const SizedBox(),
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
