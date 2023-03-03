import 'package:cached_network_image/cached_network_image.dart';

import 'package:dart_emoji/dart_emoji.dart';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/hejtter_like_button.dart';
import 'package:hejtter/ui/post_screen/picture_preview.dart';
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

  Future<void> _likeComment(BuildContext context) async {
    await hejtoApi.likeComment(
      postSlug: comment.postSlug,
      commentUUID: comment.uuid,
      context: context,
    );
  }

  Future<void> _unlikeComment(BuildContext context) async {
    await hejtoApi.unlikeComment(
      postSlug: comment.postSlug,
      commentUUID: comment.uuid,
      context: context,
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
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  _buildAvatar(context),
                  const SizedBox(width: 10),
                  _buildUsernameAndDate(context),
                  const SizedBox(width: 15),
                ],
              ),
            ),
            HejtterLikeButton(
              author: comment.author?.username,
              likeStatus: comment.isLiked,
              numLikes: comment.numLikes,
              unlikeComment: _unlikeComment,
              likeComment: _likeComment,
              small: true,
            ),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 0),
        _buildContent(context),
        _buildPictures(),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildPictures() {
    final images = comment.images;

    if (images != null && images.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 40),
        child: PicturePreview(
          imageUrl: '${images[0].urls?.the1200X900}',
          imagesUrls: images,
          multiplePics: images.length > 1,
          nsfw: false,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Row _buildContent(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 52),
        Expanded(
            child: MarkdownBody(
          data: _addEmojis(comment.content ?? ''),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
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
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatarUrl = comment.author?.avatar?.urls?.the100X100;

    return GestureDetector(
      onTap: () => _goToUserScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(1),
          color: Colors.white,
          child: SizedBox(
            height: 32,
            width: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: avatarUrl ?? defaultAvatar,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameAndDate(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _goToUserScreen(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    comment.author != null
                        ? comment.author!.username.toString()
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: comment.author?.sponsor == true ? 10 : 0),
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
                const SizedBox(width: 10),
                _buildRankPlate(),
              ],
            ),
            Text(
              comment.createdAt != null
                  ? timeago.format(DateTime.parse(comment.createdAt.toString()),
                      locale: 'pl')
                  : '',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildRankPlate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: comment.author?.currentColor != null
            ? Color(
                int.parse(
                  comment.author!.currentColor!.replaceAll('#', '0xff'),
                ),
              )
            : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        comment.author != null ? comment.author!.currentRank.toString() : '',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }
}
