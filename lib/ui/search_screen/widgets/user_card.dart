import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/models/hejto_users_response.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
  });

  final HejtoUser user;

  Widget _buildUserJoinedDate(HejtoUser user) {
    if (user.createdAt == null) {
      return const SizedBox();
    }

    final joinDate = DateTime.parse(user.createdAt!);

    final joinYear = joinDate.year;
    final joinMonth = joinDate.month;
    final joinDay = joinDate.day;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          'Dołączył/a: ',
          style: TextStyle(fontSize: 14),
        ),
        Text(
          '$joinDay.$joinMonth.$joinYear',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRankPlate(HejtoUser? user) {
    if (user == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: user.currentColor != null
            ? Color(
                int.parse(
                  user.currentColor!.replaceAll('#', '0xff'),
                ),
              )
            : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        user.currentRank!,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserScreen(
                userName: user.username,
              ),
            ),
          );
        },
        child: Card(
          color: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: dividerColor,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(1),
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl:
                                  user.avatar?.urls?.s250x250 ?? defaultAvatar,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return LoadingAnimationWidget.threeArchedCircle(
                                    color: boltColor, size: 14);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${user.username}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          _buildRankPlate(user),
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 10),
                const SizedBox(height: 10),
                Wrap(
                  children: [
                    Text(
                      '${user.stats?.numPosts} wpisów',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${user.stats?.numComments} komentarzy',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${user.stats?.numFollows} obserwujących',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Expanded(
                      child: _buildUserJoinedDate(user),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
