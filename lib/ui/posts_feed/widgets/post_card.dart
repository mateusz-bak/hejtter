import 'package:cached_network_image/cached_network_image.dart';

import 'package:dart_emoji/dart_emoji.dart';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/models/comments_response.dart';

import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/post_screen/widgets.dart/widgets.dart';
import 'package:hejtter/ui/posts_feed/widgets/widgets.dart';
import 'package:hejtter/ui/tag_screen/tag_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/helpers.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:url_launcher/url_launcher.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  final Post item;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  late Post? item;
  Size? _contentSize;

  int? _votingOnOption;

  List<CommentItem>? _comments;

  _goToUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: item?.author?.username,
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

  _refreshPost() async {
    final newItem = await hejtoApi.getPostDetails(
      postSlug: item?.slug,
      context: context,
    );

    setState(() {
      item = newItem?.slug != null ? newItem : null;
    });
  }

  _refreshComment(String? uuid, bool newValue) async {
    if (_comments != null && _comments!.isNotEmpty) {
      final oldCommentIndex = _comments!.indexWhere(
        (element) => element.uuid == uuid,
      );

      final oldComment = _comments![oldCommentIndex];

      final newComments = _comments;

      newComments![oldCommentIndex] = CommentItem(
        postSlug: oldComment.postSlug,
        content: oldComment.content,
        contentPlain: oldComment.contentPlain,
        author: oldComment.author,
        images: oldComment.images,
        numLikes: oldComment.numLikes != null
            ? oldComment.numLikes! + (newValue ? 1 : -1)
            : null,
        interactions: oldComment.interactions,
        createdAt: oldComment.createdAt,
        uuid: oldComment.uuid,
        links: oldComment.links,
        isLiked: newValue,
      );

      setState(() {
        _comments = newComments;
      });
    }
  }

  Future<void> _likePost(BuildContext context) async {
    if (item?.slug == null) return;

    final postLiked = await hejtoApi.likePost(
      postSlug: item!.slug!,
      context: context,
    );

    if (postLiked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: item!.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          item = refreshedPost;
        });
      }
    }
  }

  Future<void> _unlikePost(BuildContext context) async {
    if (item?.slug == null) return;

    final postUnliked = await hejtoApi.unlikePost(
      postSlug: item!.slug!,
      context: context,
    );

    if (postUnliked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: item!.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          item = refreshedPost;
        });
      }
    }
  }

  Future<void> _voteOnPoll(uuid, option) async {
    setState(() {
      _votingOnOption = option;
    });

    final result = await hejtoApi.createPollVote(
      uuid: uuid,
      option: option,
      context: context,
    );

    setState(() {
      _votingOnOption = null;
    });

    if (result) {
      _refreshPost();
    }
  }

  String _decideNumberOfCommentsText(int numComments) {
    if (numComments == 0) {
      return 'komentarzy';
    } else if (numComments == 1) {
      return 'komentarz';
    }

    final numVotesString = numComments.toString();
    final lastChar = numVotesString[numVotesString.length - 1];

    if (lastChar == '2' || lastChar == '3' || lastChar == '4') {
      return 'komentarze';
    } else {
      return 'komentarzy';
    }
  }

  @override
  void initState() {
    super.initState();
    item = widget.item;

    _comments = widget.item.comments;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _setTimeAgoLocale();

    if (item == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (item == null) return;

          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return PostScreen(
                post: item!,
                refreshCallback: _refreshPost,
                refreshCommentCallback: _refreshComment);
          }));
        },
        child: Card(
          elevation: 0,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: const BoxDecoration(
                  color: backgroundSecondaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
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
                              _buildUsername(),
                              const SizedBox(height: 3),
                              _buildRankPlate(),
                            ],
                          ),
                        ),
                        _buildHotIcon(),
                        const SizedBox(width: 5),
                        HejtterLikeButton(
                          author: item?.author?.username,
                          likeStatus: item?.isLiked,
                          numLikes: item?.numLikes,
                          unlikeComment: _unlikePost,
                          likeComment: _likePost,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    _buildCommunityAndDate(),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildTitle(),
                  SizedBox(
                      height: item?.type == 'article' || item?.type == 'link'
                          ? 10
                          : 0),
                  item?.type == 'article' || item?.type == 'link'
                      ? _buildContentPreviewAndPicture()
                      : const SizedBox(),
                  SizedBox(
                      height: item?.type == 'article' || item?.type == 'link'
                          ? 10
                          : 0),
                  item?.type != 'article' && item?.type != 'link'
                      ? _buildContent()
                      : const SizedBox(),
                  // _buildTags(),
                  _buildPoll(),
                  item?.type != 'article' && item?.type != 'link'
                      ? _buildPicture()
                      : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildNumberOfComments(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  item?.type != 'article' && item?.type != 'link'
                      ? _buildComments()
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberOfComments() {
    return item?.numComments != null
        ? Padding(
            padding: const EdgeInsets.only(right: 10, top: 5),
            child: Text(
              '${item!.numComments} ${_decideNumberOfCommentsText(item!.numComments!)}',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildPicture() {
    if (item == null ||
        item!.images == null ||
        item!.images!.isEmpty ||
        item!.images![0].urls?.the1200X900 == null) {
      return const SizedBox();
    }

    final bool multiplePics = item!.images!.length > 1;

    return PicturePreview(
      imageUrl: item!.images![0].urls!.the1200X900!,
      multiplePics: multiplePics,
      nsfw: item!.nsfw ?? false,
      imagesUrls: item!.images,
    );
  }

  Widget _buildContentPreviewAndPicture() {
    if (item == null ||
        item!.images == null ||
        item!.images!.isEmpty ||
        item!.images![0].urls?.the1200X900 == null) {
      return const SizedBox();
    }

    final bool multiplePics = item!.images!.length > 1;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 120,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(),
                child: MarkdownBody(
                  data: item?.content ?? '',
                  selectable: true,
                  styleSheet:
                      MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    blockquoteDecoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onTapText: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return PostScreen(
                          post: item!,
                          refreshCallback: _refreshPost,
                          refreshCommentCallback: _refreshComment);
                    }));
                  },
                  onTapLink: (text, href, title) {
                    if (text[0] == ('#')) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TagScreen(
                            tag: text.replaceFirst('#', ''),
                          ),
                        ),
                      );
                    }

                    launchUrl(
                      Uri.parse(href.toString()),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ),
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (item?.type == 'link' && item?.link != null) {
                    launchUrl(
                      Uri.parse(item!.link!),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: PicturePreview(
                  imageUrl: item!.images![0].urls!.the1200X900!,
                  multiplePics: multiplePics,
                  nsfw: item!.nsfw ?? false,
                  imagesUrls: item!.images,
                  height: 100,
                  width: 100,
                  openOnTap: item?.type != 'link',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotIcon() {
    return Column(
      children: [
        SizedBox(width: item?.hot == true ? 5 : 0),
        item?.hot == true
            ? Icon(
                Icons.local_fire_department_outlined,
                color: Theme.of(context).colorScheme.primary,
              )
            : const SizedBox(),
      ],
    );
  }

  Widget _buildComments() {
    if (_comments != null && _comments!.isNotEmpty) {
      return Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
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
              comment: _comments![0],
              postItem: widget.item,
              refreshCallback: _refreshPost,
              refreshCommentCallback: _refreshComment,
            ),
            SizedBox(height: _comments!.length > 1 ? 10 : 0),
            _comments!.length > 1
                ? CommentInPostCard(
                    comment: _comments![1],
                    postItem: widget.item,
                    refreshCallback: _refreshPost,
                    refreshCommentCallback: _refreshComment,
                  )
                : const SizedBox(),
            SizedBox(height: _comments!.length > 2 ? 10 : 0),
            _comments!.length > 2
                ? CommentInPostCard(
                    comment: _comments![2],
                    postItem: widget.item,
                    refreshCallback: _refreshPost,
                    refreshCommentCallback: _refreshComment,
                  )
                : const SizedBox(),
            const SizedBox(height: 10),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildPoll() {
    if (item == null ||
        item!.poll?.options == null ||
        item!.poll?.title == null ||
        item!.poll?.uuid == null ||
        item!.poll?.numVotes == null ||
        item!.poll!.options!.length < 2) {
      return const SizedBox();
    }

    return PollWidget(
      title: item!.poll!.title!,
      uuid: item!.poll!.uuid!,
      options: item!.poll!.options!,
      numVotes: item!.poll!.numVotes!,
      userVote: item!.poll!.userVote,
      votingOnOption: _votingOnOption,
      onVoted: _voteOnPoll,
    );
  }

  Widget _buildTags() {
    if (item?.tags != null && item!.tags!.isNotEmpty) {
      List<Widget> tags = List.empty(growable: true);

      for (var tag in item!.tags!) {
        if (tag.name != null) {
          tags.add(GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TagScreen(
                    tag: tag.name!,
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
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade400,
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          MeasureSize(
            onChange: (size) {
              setState(() {
                _contentSize = size;
              });
            },
            child: Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 500),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  child: MarkdownBody(
                    data: _addEmojis(item?.content.toString() ?? ''),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      blockquoteDecoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    selectable: true,
                    onTapText: () {
                      if (item == null) return;

                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) {
                          return PostScreen(
                            post: item!,
                            refreshCallback: _refreshPost,
                            refreshCommentCallback: _refreshComment,
                          );
                        },
                      ));
                    },
                    onTapLink: (text, href, title) {
                      if (text[0] == ('#')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TagScreen(
                              tag: text.replaceFirst('#', ''),
                            ),
                          ),
                        );

                        return;
                      }

                      launchUrl(
                        Uri.parse(href.toString()),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ),
                _contentSize?.height == 500.0
                    ? Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black,
                                Colors.black,
                              ],
                              stops: [0, 0.9, 1],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          _contentSize?.height == 500.0
              ? Row(
                  children: const [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                        child: Text(
                          'Poka?? wi??cej',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (item?.type == 'article' || item?.type == 'link') {
      return GestureDetector(
        onTap: () {
          if (item?.type == 'link' && item?.link != null) {
            launchUrl(
              Uri.parse(item!.link!),
              mode: LaunchMode.externalApplication,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item?.title ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              item?.link != null
                  ? Text(
                      item!.link!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildAvatar() {
    final avatarUrl = item?.author?.avatar?.urls?.the100X100;

    return GestureDetector(
      onTap: _goToUserScreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.all(1),
          color: Colors.white,
          child: SizedBox(
            height: 36,
            width: 36,
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

  Widget _buildUsername() {
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
                    item?.author != null
                        ? item!.author!.username.toString()
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(width: item?.author?.sponsor == true ? 5 : 0),
                item?.author?.sponsor == true
                    ? Transform.rotate(
                        angle: 180,
                        child: const Icon(
                          Icons.mode_night_rounded,
                          color: Colors.brown,
                          size: 18,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(width: 5),
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
        color: item?.author?.currentColor != null
            ? Color(
                int.parse(
                  item!.author!.currentColor!.replaceAll('#', '0xff'),
                ),
              )
            : Colors.black,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        item?.author != null ? item!.author!.currentRank.toString() : 'null',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Row _buildCommunityAndDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: 48),
        const Text('w '),
        Flexible(
          child: GestureDetector(
            onTap: (() {
              if (item?.community == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityScreen(
                    communitySlug: item!.community?.slug,
                  ),
                ),
              );
            }),
            child: Text(
              item?.community?.name != null
                  ? item!.community!.name.toString()
                  : '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          item?.createdAt != null
              ? timeago.format(DateTime.parse(item!.createdAt.toString()),
                  locale: 'pl')
              : 'null',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
