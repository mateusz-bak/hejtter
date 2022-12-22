import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/comment_in_post_card.dart';
import 'package:hejtter/picture_full_screen.dart';
import 'package:hejtter/post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  final Item item;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  double _maxLines = 150;

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
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  const SizedBox(width: 10),
                  Text(
                    widget.item.stats?.numLikes != null
                        ? widget.item.stats!.numLikes.toString()
                        : 'null',
                  ),
                  const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.bolt),
                  )
                ],
              ),
              const SizedBox(height: 15),
              _buildContent(),
              _buildTags(),
              _buildPicture(),
              _buildComments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComments() {
    if (widget.item.comments != null && widget.item.comments!.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(height: 15),
          CommentInPostCard(comment: widget.item.comments![0]),
          SizedBox(height: widget.item.comments!.length > 1 ? 10 : 0),
          widget.item.comments!.length > 1
              ? CommentInPostCard(comment: widget.item.comments![1])
              : const SizedBox(),
          SizedBox(height: widget.item.comments!.length > 2 ? 10 : 0),
          widget.item.comments!.length > 2
              ? CommentInPostCard(comment: widget.item.comments![1])
              : const SizedBox(),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildTags() {
    if (widget.item.tags != null && widget.item.tags!.isNotEmpty) {
      String tags = '';

      for (var tag in widget.item.tags!) {
        tags = '$tags#${tag.name} ';
      }

      return Column(
        children: [
          const SizedBox(height: 10),
          Text(
            tags,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              // color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildPicture() {
    if (widget.item.images != null && widget.item.images!.isNotEmpty) {
      return Column(
        children: [
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: GestureDetector(
                child: Hero(
                  tag: '${widget.item.images![0].urls?.the500X500}',
                  child: CachedNetworkImage(
                    imageUrl: '${widget.item.images![0].urls?.the500X500}',
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return PictureFullScreen(
                      imageUrl: '${widget.item.images![0].urls?.the1200X900}',
                    );
                  }));
                }),
          )
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildContent() {
    return MarkdownBody(
      data: _addEmojis(widget.item.content.toString()),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        blockquoteDecoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      selectable: true,
      onTapLink: (text, href, title) {
        launchUrl(
          Uri.parse(href.toString()),
          mode: LaunchMode.externalApplication,
        );
      },
    );
  }

  SizedBox _buildAvatar() {
    return SizedBox(
      height: 36,
      width: 36,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: '${widget.item.author?.avatar?.urls?.the100X100}',
          errorWidget: (context, url, error) => CachedNetworkImage(
            imageUrl:
                'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75',
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }

  Row _buildUsernameAndRank() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
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
              const SizedBox(width: 5),
              Text(
                widget.item.author != null
                    ? widget.item.author!.currentRank.toString()
                    : 'null',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.item.author?.currentColor != null
                      ? Color(
                          int.parse(
                            widget.item.author!.currentColor!
                                .replaceAll('#', '0xff'),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row _buildCommunityAndDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('w '),
        Flexible(
          child: Text(
            widget.item.community?.name != null
                ? widget.item.community!.name.toString()
                : 'null',
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
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
