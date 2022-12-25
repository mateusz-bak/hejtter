import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/post_screen/post_screen.dart';
import 'package:hejtter/user_screen/user_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class CommentInPostCard extends StatelessWidget {
  const CommentInPostCard({
    required this.comment,
    required this.postItem,
    super.key,
  });

  final Comment comment;
  final PostItem postItem;

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
            _buildLikes(comment.stats?.numLikes),
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
                    item: postItem,
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
          style: const TextStyle(fontSize: 12),
        ),
        const Icon(
          Icons.bolt,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatarUrl = comment.author?.avatar?.urls?.the100X100;
    const defaultAvatarUrl =
        'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserScreen(),
          ),
        );
      },
      child: SizedBox(
        height: 28,
        width: 28,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: CachedNetworkImage(
            imageUrl:
                avatarUrl != null ? avatarUrl.toString() : defaultAvatarUrl,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameAndDate(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserScreen(),
            ),
          );
        },
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
