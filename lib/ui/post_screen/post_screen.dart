import 'package:cached_network_image/cached_network_image.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/answer_button.dart';
import 'package:hejtter/ui/post_screen/comment_in_post_screen.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/ui/post_screen/picture_full_screen.dart';
import 'package:hejtter/ui/post_screen/picture_preview.dart';
import 'package:hejtter/ui/posts_screen/posts_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({
    required this.post,
    required this.refreshCallback,
    Key? key,
  }) : super(key: key);

  final Post post;
  final Function() refreshCallback;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();

  static const _pageSize = 20;

  late Post post;

  final PagingController<int, CommentItem> _pagingController = PagingController(
    firstPageKey: 1,
  );

  late Set<String> moreButtonOptions;

  final moreButtonOptionsFavorited = {
    'Usuń z ulubionych',
    'Udostępnij',
    'Zgłoś',
  };
  final moreButtonOptionsNotFavorited = {
    'Dodaj do ulubionych',
    'Udostępnij',
    'Zgłoś',
  };

  _goToUserScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: post.author?.username,
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
        commentsHref: post.links!.comments!.href!,
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
    await _refreshPost();
    await _refreshComments();
  }

  Future _refreshPost() async {
    final refreshedPost = await hejtoApi.getPostDetails(
      postSlug: post.slug,
      context: context,
    );

    if (refreshedPost != null) {
      setState(() {
        post = refreshedPost;
      });
    }
  }

  Future _refreshComments() async {
    _pagingController.refresh();
  }

  _likePost() async {
    if (post.slug == null) return;

    final postLiked = await hejtoApi.likePost(
      postSlug: post.slug!,
      context: context,
    );

    if (postLiked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: post.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          post = refreshedPost;
        });
      }

      widget.refreshCallback();
    }
  }

  _unlikePost() async {
    if (post.slug == null) return;

    final postUnliked = await hejtoApi.unlikePost(
      postSlug: post.slug!,
      context: context,
    );

    if (postUnliked) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: post.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          post = refreshedPost;
        });
      }

      widget.refreshCallback();
    }
  }

  _sendComment() async {
    final message = _commentController.text;

    if (message.isNotEmpty) {
      FocusScope.of(context).unfocus();

      final commentCreated = await hejtoApi.addComment(
        slug: post.slug,
        content: _commentController.text,
        context: context,
      );

      if (commentCreated) {
        await _refreshPostAndComments();
        await Future.delayed(const Duration(milliseconds: 500));
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.ease,
        );
      }

      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Komentarz nie może być pusty'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  _respondToUser(String? username) {
    if (username == null) return;

    if (_commentController.text.isEmpty) {
      _commentController.text = '@$username ';
    } else {
      _commentController.text = '${_commentController.text}\n@$username ';
    }

    FocusScope.of(context).requestFocus(focusNode);
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
  }

  _addPostToFavorites() async {
    if (post.slug == null) return;

    final result = await hejtoApi.addPostToFavorites(
      postSlug: post.slug!,
      context: context,
    );

    if (result) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: post.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          post = refreshedPost;
        });
      }
    }
  }

  _removePostFromFavorites() async {
    if (post.slug == null) return;

    final result = await hejtoApi.removePostFromFavorites(
      postSlug: post.slug!,
      context: context,
    );

    if (result) {
      final refreshedPost = await hejtoApi.getPostDetails(
        postSlug: post.slug,
        context: context,
      );

      if (refreshedPost != null) {
        setState(() {
          post = refreshedPost;
        });
      }
    }
  }

  _sharePost() async {
    if (post.links?.self == null) return;
    final postUrl = 'https://www.hejto.pl/wpis/${post.slug}';

    Share.share(postUrl);
  }

  _reportPost() async {
    if (post.links?.self == null) return;
    const firstPart = 'Zgłaszam złamanie regulaminu:\n\n';
    final postUrl = 'https://www.hejto.pl/wpis/${post.slug}';
    const lastpart = '\n\nPozdrawiam';

    final Email email = Email(
      body: '$firstPart$postUrl$lastpart',
      subject: 'Złamanie regulaminu',
      recipients: ['support@hejto.pl'],
      isHTML: false,
    );

    FlutterEmailSender.send(email).then((value) {
      const SnackBar snackBar = SnackBar(content: Text('Zgłoszono wpis'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  _setMoreOptionsButtons() {
    if (post.isFavorited == true) {
      moreButtonOptions = moreButtonOptionsFavorited;
    } else {
      moreButtonOptions = moreButtonOptionsNotFavorited;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    post = widget.post;

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
    _setMoreOptionsButtons();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (BuildContext context) {
              return moreButtonOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                  onTap: () {
                    if (choice == 'Dodaj do ulubionych') {
                      _addPostToFavorites();
                    } else if (choice == 'Usuń z ulubionych') {
                      _removePostFromFavorites();
                    } else if (choice == 'Udostępnij') {
                      _sharePost();
                    } else if (choice == 'Zgłoś') {
                      _reportPost();
                    }
                  },
                );
              }).toList();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfilePresentState) {
            return CommentBox(
              focusNode: focusNode,
              userImage: CommentBox.commentImageParser(
                imageURLorPath: state.avatar ?? defaultAvatar,
              ),
              labelText: 'Skomentuj',
              withBorder: false,
              sendButtonMethod: _sendComment,
              commentController: _commentController,
              backgroundColor: backgroundColor,
              textColor: Colors.white,
              sendWidget: const Icon(
                Icons.send_sharp,
                size: 24,
                color: Color(0xff2295F3),
              ),
              child: _buildPost(),
            );
          } else {
            return _buildPost();
          }
        },
      ),
    );
  }

  Widget _buildPost() {
    return Container(
      color: backgroundColor,
      child: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _refreshPostAndComments(),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              color: backgroundColor,
              child: Card(
                color: backgroundColor,
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
                            post.numLikes != null
                                ? post.numLikes.toString()
                                : 'null',
                            style: TextStyle(
                              color: post.isLiked == true
                                  ? const Color(0xffFFC009)
                                  : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bolt),
                            color: post.isLiked == true
                                ? const Color(0xffFFC009)
                                : null,
                            onPressed:
                                post.isLiked == true ? _unlikePost : _likePost,
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
                        _buildPictures(),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: AnswerButton(
                            username: post.author?.username,
                            respondToUser: _respondToUser,
                          ),
                        ),
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
        SizedBox(width: widget.post.hot == true ? 5 : 0),
        widget.post.hot == true
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
              return CommentInPostScreen(
                comment: item,
                respondToUser: _respondToUser,
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTags() {
    if (post.tags != null && post.tags!.isNotEmpty) {
      List<Widget> tags = List.empty(growable: true);

      for (var tag in post.tags!) {
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

  Widget _buildPictures() {
    if (post.images == null || post.images!.isEmpty) {
      return const SizedBox();
    }

    if (post.images!.length == 1) {
      return Container(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 0),
        height: 400,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: GestureDetector(
              child: post.images![0].urls?.the1200X900 != null
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: '${post.images![0].urls?.the1200X900}',
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : const SizedBox(),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return PictureFullScreen(
                    imageUrl: '${post.images![0].urls?.the1200X900}',
                  );
                }));
              },
            ),
          ),
        ),
      );
    }

    final imageWidgets = List<Widget>.empty(growable: true);
    int index = 0;

    for (var image in post.images!) {
      if (post.images?[index].urls?.the1200X900 != null) {
        imageWidgets.add(PicturePreview(
          imageUrl: post.images![index].urls!.the1200X900!,
        ));
      }
      index++;
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: imageWidgets,
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: MarkdownBody(
        data: _addEmojis(post.content.toString()),
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
    final avatarUrl = post.author?.avatar?.urls?.the100X100;

    return GestureDetector(
      onTap: _goToUserScreen,
      child: SizedBox(
        height: 36,
        width: 36,
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
                    post.author != null
                        ? post.author!.username.toString()
                        : 'null',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                SizedBox(width: widget.post.author?.sponsor == true ? 5 : 0),
                widget.post.author?.sponsor == true
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
        post.author != null ? post.author!.currentRank.toString() : 'null',
        style: TextStyle(
          fontSize: 12,
          color: post.author?.currentColor != null
              ? Color(
                  int.parse(
                    post.author!.currentColor!.replaceAll('#', '0xff'),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostsScreen(
                    communityName: post.community!.name,
                    communitySlug: post.community!.slug,
                  ),
                ),
              );
            }),
            child: Text(
              post.community?.name != null
                  ? post.community!.name.toString()
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
          post.createdAt != null
              ? timeago.format(DateTime.parse(post.createdAt.toString()),
                  locale: 'pl')
              : 'null',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
