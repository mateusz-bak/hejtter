import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/ui/posts_screen/comment_in_post_card.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/ui/posts_screen/posts_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  final PostItem item;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  _goToUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: widget.item.author?.username,
        ),
      ),
    );
  }

  String _addEmojis(String text) {
    final parser = EmojiParser();
    return parser.emojify(text);
  }

  _setTimeAgoLocale() {
    timeago.setLocaleMessages('pl', timeago.PlMessages());
  }

  @override
  Widget build(BuildContext context) {
    _setTimeAgoLocale();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PostScreen(
              item: widget.item,
            );
          }));
        },
        child: Material(
          child: Card(
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUsernameAndRank(),
                            const SizedBox(height: 3),
                            _buildCommunityAndDate(),
                          ],
                        ),
                      ),
                      _buildHotIcon(),
                      const SizedBox(width: 10),
                      Text(
                        widget.item.numLikes != null
                            ? widget.item.numLikes.toString()
                            : 'null',
                      ),
                      const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.bolt),
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildContent(),
                    _buildTags(),
                    _buildPicture(),
                    const SizedBox(height: 20),
                    _buildComments(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotIcon() {
    return Column(
      children: [
        SizedBox(width: widget.item.hot == true ? 5 : 0),
        widget.item.hot == true
            ? const Icon(
                Icons.local_fire_department_outlined,
                color: Color(0xff2295F3),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildComments() {
    if (widget.item.comments != null && widget.item.comments!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(50),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            CommentInPostCard(
              comment: widget.item.comments![0],
              postItem: widget.item,
            ),
            SizedBox(height: widget.item.comments!.length > 1 ? 10 : 0),
            widget.item.comments!.length > 1
                ? CommentInPostCard(
                    comment: widget.item.comments![1],
                    postItem: widget.item,
                  )
                : const SizedBox(),
            SizedBox(height: widget.item.comments!.length > 2 ? 10 : 0),
            widget.item.comments!.length > 2
                ? CommentInPostCard(
                    comment: widget.item.comments![2],
                    postItem: widget.item,
                  )
                : const SizedBox(),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildTags() {
    if (widget.item.tags != null && widget.item.tags!.isNotEmpty) {
      List<Widget> tags = List.empty(growable: true);

      for (var tag in widget.item.tags!) {
        if (tag.name != null) {
          tags.add(GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostsScreen(
                    tagName: tag.name!,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
              child: Text(
                '#${tag.name!} ',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ));
        }
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Wrap(
          children: tags,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildPicture() {
    if (widget.item.images != null && widget.item.images!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: '${widget.item.images![0].urls?.the500X500}',
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MarkdownBody(
        data: _addEmojis(widget.item.content.toString()),
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
              item: widget.item,
            );
          }));
        },
        onTapLink: (text, href, title) {
          launchUrl(
            Uri.parse(href.toString()),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = widget.item.author?.avatar?.urls?.the100X100;
    const defaultAvatarUrl =
        'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75';

    return GestureDetector(
      onTap: _goToUserScreen,
      child: SizedBox(
        height: 36,
        width: 36,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl:
                avatarUrl != null ? avatarUrl.toString() : defaultAvatarUrl,
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameAndRank() {
    return GestureDetector(
      onTap: _goToUserScreen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.item.author != null
                        ? widget.item.author!.username.toString()
                        : 'null',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(width: widget.item.author?.sponsor == true ? 5 : 0),
                widget.item.author?.sponsor == true
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
                _buildRankPlate(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankPlate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        widget.item.author != null
            ? widget.item.author!.currentRank.toString()
            : 'null',
        style: TextStyle(
          fontSize: 11,
          color: widget.item.author?.currentColor != null
              ? Color(
                  int.parse(
                    widget.item.author!.currentColor!.replaceAll('#', '0xff'),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Row _buildCommunityAndDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('w '),
        Flexible(
          child: GestureDetector(
            onTap: (() {
              if (widget.item.community?.name == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostsScreen(
                    communityName: widget.item.community!.name!,
                  ),
                ),
              );
            }),
            child: Text(
              widget.item.community?.name != null
                  ? widget.item.community!.name.toString()
                  : 'null',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          widget.item.createdAt != null
              ? timeago.format(DateTime.parse(widget.item.createdAt.toString()),
                  locale: 'pl')
              : 'null',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
