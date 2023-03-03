import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/utils/constants.dart';

class HejtterLikeButton extends StatefulWidget {
  const HejtterLikeButton({
    super.key,
    required this.likeStatus,
    required this.numLikes,
    required this.unlikeComment,
    required this.likeComment,
    required this.author,
    this.small = false,
  });

  final bool? likeStatus;
  final bool small;
  final int? numLikes;
  final String? author;
  final Future Function(BuildContext) unlikeComment;
  final Future Function(BuildContext) likeComment;

  @override
  State<HejtterLikeButton> createState() => _HejtterLikeButtonState();
}

class _HejtterLikeButtonState extends State<HejtterLikeButton> {
  bool isLikeChanging = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.all(widget.small ? 4 : 6),
        backgroundColor: widget.likeStatus == true ? boltColor : null,
        foregroundColor:
            widget.likeStatus == true ? Colors.black : onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: !isLikeChanging
          ? Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  widget.numLikes.toString(),
                  style: TextStyle(fontSize: widget.small ? 14 : 16),
                ),
                Icon(
                  Icons.bolt,
                  size: widget.small ? 16 : 20,
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 8,
              ),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  color: widget.likeStatus == true ? Colors.black : boltColor,
                ),
              ),
            ),
      onPressed: () async {
        setState(() {
          isLikeChanging = true;
        });

        final profileState = context.read<ProfileBloc>().state;
        if (profileState is ProfilePresentState) {
          if (profileState.username != widget.author) {
            if (widget.likeStatus == true) {
              await widget.unlikeComment(context);
            } else {
              await widget.likeComment(context);
            }
          }
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const LoginScreen();
          }));
        }
        setState(() {
          isLikeChanging = false;
        });
      },
    );
  }
}
