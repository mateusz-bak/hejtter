import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:like_button/like_button.dart';

class HejtterLikeButton extends StatelessWidget {
  const HejtterLikeButton({
    super.key,
    required this.likeStatus,
    required this.numLikes,
    required this.unlikeComment,
    required this.likeComment,
    required this.author,
  });

  final bool? likeStatus;
  final int? numLikes;
  final String? author;
  final Future Function(BuildContext) unlikeComment;
  final Future Function(BuildContext) likeComment;

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      size: 30,
      isLiked: likeStatus,
      countPostion: CountPostion.left,
      padding: const EdgeInsets.fromLTRB(5, 10, 15, 10),
      circleColor: const CircleColor(
        start: boltColor,
        end: boltColor,
      ),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: boltColor,
        dotSecondaryColor: boltColor,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.bolt,
          color: isLiked == true ? boltColor : null,
          size: 24,
        );
      },
      likeCount: numLikes,
      countBuilder: (int? numLikes, bool isLiked, String text) {
        var color = isLiked == true ? boltColor : null;

        return Text(
          text,
          style: TextStyle(color: color),
        );
      },
      onTap: (isLiked) async {
        final profileState = context.read<ProfileBloc>().state;
        if (profileState is ProfilePresentState) {
          if (profileState.username != author) {
            if (isLiked) {
              await unlikeComment(context);
            } else {
              await likeComment(context);
            }
            return !isLiked;
          }
          return isLiked;
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const LoginScreen();
          }));
        }
        return isLiked;
      },
    );
  }
}
