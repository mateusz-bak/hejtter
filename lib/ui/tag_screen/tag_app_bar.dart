import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/hejto_tag.dart';
import 'package:hejtter/utils/constants.dart';

class TagAppBar extends StatelessWidget {
  TagAppBar({
    Key? key,
    required this.tag,
    required this.changeTagFollowState,
    required this.changeTagBlockState,
  }) : super(key: key);

  final HejtoTag tag;
  final Function(bool) changeTagFollowState;
  final Function(bool) changeTagBlockState;

  late final Set<String> moreButtonOptions;
  final moreButtonOptionsFollowed = {'Przestań obserwować'};
  final moreButtonOptionsNotFollowed = {'Obserwuj'};

  _preparePopMenuOptions() {
    if (tag.isFollowed == true) {
      moreButtonOptions = moreButtonOptionsFollowed;
    } else {
      moreButtonOptions = moreButtonOptionsNotFollowed;
    }

    if (tag.isBlocked == true) {
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
                        if (choice == 'Przestań obserwować') {
                          changeTagFollowState(false);
                        } else if (choice == 'Obserwuj') {
                          changeTagFollowState(true);
                        } else if (choice == 'Odblokuj') {
                          changeTagBlockState(false);
                        } else if (choice == 'Zablokuj') {
                          changeTagBlockState(true);
                        }
                      },
                    );
                  }).toList();
                },
              )
            : const SizedBox(),
      ],
      title: Text(
        '#${tag.name}',
        softWrap: false,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}
