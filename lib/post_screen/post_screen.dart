import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/post_screen/comment_in_post_screen.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/post_screen/picture_full_screen.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/posts_screen/posts_screen.dart';
import 'package:hejtter/user_screen/user_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatefulWidget {
  const PostScreen({
    required this.item,
    Key? key,
  }) : super(key: key);

  final PostItem item;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final client = http.Client();
  static const _pageSize = 20;

  final PagingController<int, CommentItem> _pagingController =
      PagingController(firstPageKey: 1);

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

  Future<List<CommentItem>?> _getComments(int pageKey, int pageSize) async {
    final queryParameters = {
      'limit': '$pageSize',
      'page': '$pageKey',
    };
    print(
        'widget.item.links?.comments?.href: ${widget.item.links?.comments?.href}');

    var response = await client.get(
      Uri.https(
        'api.hejto.pl',
        '${widget.item.links?.comments?.href}',
        queryParameters,
      ),
    );
    // print('response.body: ${response.body}');

    return commentsResponseFromJson(response.body).embedded?.items;
  }

  Future<void> _fetchPage(int pageKey) async {
    print('_fetchPage pageKey: ${pageKey}');

    try {
      final newItems = await _getComments(pageKey, _pageSize);
      // print('newItems!.length: ${newItems!.length}');
      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        print('_fetchPage isLastPage: true');

        _pagingController.appendLastPage(newItems);
      } else {
        print('_fetchPage isLastPage: false');

        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setTimeAgoLocale();

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Material(
            child: Card(
              elevation: 5,
              clipBehavior: Clip.antiAlias,
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
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContent(),
                        _buildTags(),
                        _buildPicture(),
                        const SizedBox(height: 40),
                        _buildComments(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComments() {
    return PagedListView<int, CommentItem>(
      shrinkWrap: true,
      reverse: true,
      clipBehavior: Clip.antiAlias,
      physics: const NeverScrollableScrollPhysics(),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<CommentItem>(
          itemBuilder: (context, item, index) {
        if (item.content != null) {
          return CommentInPostScreen(comment: item);
        } else {
          return const SizedBox();
        }
      }),
    );
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
        padding: const EdgeInsets.only(top: 10),
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
      return Column(
        children: [
          const SizedBox(height: 15),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: GestureDetector(
                  child: widget.item.images![0].urls?.the500X500 != null
                      ? CachedNetworkImage(
                          width: double.infinity,
                          fit: BoxFit.cover,
                          imageUrl:
                              '${widget.item.images![0].urls?.the500X500}',
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : const SizedBox(),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return PictureFullScreen(
                        imageUrl: '${widget.item.images![0].urls?.the1200X900}',
                      );
                    }));
                  }),
            ),
          ),
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

  Widget _buildUsernameAndRank() {
    return GestureDetector(
      onTap: _goToUserScreen,
      child: Row(
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
