import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class CommentInPostCard extends StatelessWidget {
  const CommentInPostCard({
    required this.comment,
    required this.postItem,
    super.key,
    required this.refreshCallback,
  });

  final CommentItem comment;
  final Post postItem;
  final Function() refreshCallback;

  _goToUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: comment.author?.username,
        ),
      ),
    );
  }

  _setTimeAgoLocale() {
    timeago.setLocaleMessages('pl', timeago.PlMessages());
  }

  String _addEmojis(String text) {
    final parser = EmojiParser();
    return parser.emojify(text);
  }

  @override
  Widget build(BuildContext context) {
    _setTimeAgoLocale();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildAvatar(context),
                  const SizedBox(width: 5),
                  _buildUsernameAndDate(context),
                  const SizedBox(width: 15),
                ],
              ),
            ),
            _buildLikes(comment.numLikes),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(width: 33),
            Expanded(
                child: MarkdownBody(
              data: _addEmojis(comment.content.toString()),
              styleSheet:
                  MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                blockquoteDecoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              selectable: true,
              onTapText: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return PostScreen(
                    post: postItem,
                    refreshCallback: refreshCallback,
                  );
                }));
              },
              onTapLink: (text, href, title) {
                launchUrl(
                  Uri.parse(href.toString()),
                  mode: LaunchMode.externalApplication,
                );
              },
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildLikes(int? numLikes) {
    return Row(
      children: [
        Text(
          numLikes != null ? numLikes.toString() : '0',
          style: TextStyle(
            fontSize: 12,
            color: comment.isLiked == true ? const Color(0xffFFC009) : null,
          ),
        ),
        Icon(
          Icons.bolt,
          size: 20,
          color: comment.isLiked == true ? const Color(0xffFFC009) : null,
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatarUrl = comment.author?.avatar?.urls?.the100X100;

    return GestureDetector(
      onTap: () => _goToUserScreen(context),
      child: SizedBox(
        height: 28,
        width: 28,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: CachedNetworkImage(
            imageUrl: avatarUrl ?? defaultAvatar,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameAndDate(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _goToUserScreen(context),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                comment.author != null
                    ? comment.author!.username.toString()
                    : 'null',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(width: comment.author?.sponsor == true ? 5 : 0),
            comment.author?.sponsor == true
                ? Transform.rotate(
                    angle: 180,
                    child: const Icon(
                      Icons.mode_night_rounded,
                      color: Colors.brown,
                      size: 16,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(width: 5),
            Text(
              comment.createdAt != null
                  ? timeago.format(DateTime.parse(comment.createdAt.toString()),
                      locale: 'pl')
                  : 'null',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
