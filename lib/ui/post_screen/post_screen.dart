import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/comment_in_post_screen.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/ui/post_screen/picture_full_screen.dart';
import 'package:hejtter/models/posts_response.dart';
import 'package:hejtter/ui/posts_screen/posts_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class PostScreen extends StatefulWidget {
  const PostScreen({
    required this.item,
    required this.refreshCallback,
    Key? key,
  }) : super(key: key);

  final PostItem item;
  final Function() refreshCallback;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final client = http.Client();
  static const _pageSize = 20;

  late PostItem item;

  final PagingController<int, CommentItem> _pagingController = PagingController(
    firstPageKey: 1,
  );

  _goToUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: item.author?.username,
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

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getComments(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        commentsHref: item.links!.comments!.href!,
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future _refreshPostAndComments() async {
    _refreshPost();
    _refreshComments();
  }

  Future _refreshPost() async {
    final refreshedPost = await hejtoApi.getPostDetails(
      postSlug: item.slug,
      context: context,
    );

    if (refreshedPost != null) {
      setState(() {
        item = refreshedPost;
      });
    }
  }

  Future _refreshComments() async {
    Future.sync(
      () => _pagingController.refresh(),
    );
  }

  _likePost() async {
    if (item.slug == null) return;

    final postLiked = await hejtoApi.likePost(
      postSlug: item.slug!,
      context: context,
    );

    if (postLiked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: item.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          item = refreshedPost;
        });
      }

      widget.refreshCallback();
    }
  }

  _unlikePost() async {
    if (item.slug == null) return;

    final postUnliked = await hejtoApi.unlikePost(
      postSlug: item.slug!,
      context: context,
    );

    if (postUnliked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: item.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          item = refreshedPost;
        });
      }

      widget.refreshCallback();
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    item = widget.item;

    _refreshPost();
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
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _refreshPostAndComments(),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              child: Card(
                elevation: 5,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
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
                          const SizedBox(width: 15),
                          Text(
                            item.numLikes != null
                                ? item.numLikes.toString()
                                : 'null',
                            style: TextStyle(
                              color: item.isLiked == true
                                  ? const Color(0xffFFC009)
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bolt),
                            color: item.isLiked == true
                                ? const Color(0xffFFC009)
                                : null,
                            onPressed:
                                item.isLiked == true ? _unlikePost : _likePost,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: PagedListView<int, CommentItem>(
        shrinkWrap: true,
        reverse: true,
        clipBehavior: Clip.antiAlias,
        physics: const NeverScrollableScrollPhysics(),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CommentItem>(
          noItemsFoundIndicatorBuilder: (context) => const SizedBox(),
          itemBuilder: (context, item, index) {
            if (item.content != null) {
              return CommentInPostScreen(comment: item);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTags() {
    if (item.tags != null && item.tags!.isNotEmpty) {
      List<Widget> tags = List.empty(growable: true);

      for (var tag in item.tags!) {
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
    if (item.images != null && item.images!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: GestureDetector(
                    child: item.images![0].urls?.the1200X900 != null
                        ? CachedNetworkImage(
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: '${item.images![0].urls?.the1200X900}',
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : const SizedBox(),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return PictureFullScreen(
                          imageUrl: '${item.images![0].urls?.the1200X900}',
                        );
                      }));
                    }),
              ),
            ),
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
        data: _addEmojis(item.content.toString()),
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
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = item.author?.avatar?.urls?.the100X100;
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
                    item.author != null
                        ? item.author!.username.toString()
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

  Container _buildRankPlate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        item.author != null ? item.author!.currentRank.toString() : 'null',
        style: TextStyle(
          fontSize: 12,
          color: item.author?.currentColor != null
              ? Color(
                  int.parse(
                    item.author!.currentColor!.replaceAll('#', '0xff'),
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
              if (item.community?.name == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostsScreen(
                    communityName: item.community!.name!,
                  ),
                ),
              );
            }),
            child: Text(
              item.community?.name != null
                  ? item.community!.name.toString()
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
          item.createdAt != null
              ? timeago.format(DateTime.parse(item.createdAt.toString()),
                  locale: 'pl')
              : 'null',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
