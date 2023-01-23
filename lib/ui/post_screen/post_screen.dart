import 'package:cached_network_image/cached_network_image.dart';

import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/post_screen/answer_button.dart';
import 'package:hejtter/ui/post_screen/comment_in_post_screen.dart';
import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/ui/post_screen/hejtter_like_button.dart';
import 'package:hejtter/ui/post_screen/picture_preview.dart';
import 'package:hejtter/ui/post_screen/poll_widget.dart';
import 'package:hejtter/ui/posts_screen/posts_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:share_plus/share_plus.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:url_launcher/url_launcher.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({
    this.post,
    this.slug,
    this.refreshCallback,
    Key? key,
  }) : super(key: key);

  final Post? post;
  final String? slug;
  final Function()? refreshCallback;

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  final TextEditingController _commentController = TextEditingController();

  static const _pageSize = 50;

  late Post post;

  final PagingController<int, CommentItem> _pagingController = PagingController(
    firstPageKey: 1,
  );

  late Set<String> moreButtonOptions;

  int? _votingOnOption;

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

  List<PhotoToUpload> _postPhotos = List.empty(growable: true);

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
        slug: post.slug,
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

  Future<void> _likePost(BuildContext context) async {
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

      if (widget.refreshCallback != null) {
        widget.refreshCallback!();
      }
    }
  }

  Future<void> _unlikePost(BuildContext context) async {
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

      if (widget.refreshCallback != null) {
        widget.refreshCallback!();
      }
    }
  }

  _sendComment() async {
    final message = _commentController.text;

    if (message.isEmpty && !focusNode.hasFocus) {
      focusNode.requestFocus();
      return;
    }

    if (message.isNotEmpty) {
      FocusScope.of(context).unfocus();

      final commentCreated = await hejtoApi.addComment(
        slug: post.slug,
        content: _commentController.text,
        context: context,
        images: _postPhotos,
      );

      if (commentCreated) {
        setState(() {
          _postPhotos = List.empty(growable: true);
        });

        focusNode.unfocus();

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

  _removePost() async {
    if (post.slug == null) return;

    final result = await hejtoApi.removePost(
      postSlug: post.slug!,
      context: context,
    );

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wpis usunięty')),
      );

      if (widget.refreshCallback != null) {
        widget.refreshCallback!();
      }

      Navigator.of(context).pop();
    }
  }

  _setMoreOptionsButtons(bool isCurrentUsersPost) {
    if (isCurrentUsersPost) {
      moreButtonOptionsFavorited.add('Usuń');
      moreButtonOptionsNotFavorited.add('Usuń');
    }

    if (post.isFavorited == true) {
      moreButtonOptions = moreButtonOptionsFavorited;
    } else {
      moreButtonOptions = moreButtonOptionsNotFavorited;
    }
  }

  void _loadPhotoFromStorage() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final photoXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (photoXFile == null) return;

    final tmpCroppedPhoto = await ImageCropper().cropImage(
      maxWidth: 1024,
      maxHeight: 1024,
      sourcePath: photoXFile.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit cover',
          toolbarColor: Colors.black,
          statusBarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black87,
          cropGridColor: Colors.black87,
          activeControlsWidgetColor:
              (mounted) ? Theme.of(context).primaryColor : Colors.teal,
          cropFrameColor: Colors.black87,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
      ],
    );

    if (tmpCroppedPhoto == null) return;

    final potoBytes = await tmpCroppedPhoto.readAsBytes();
    final updatedPostphotos = await _updatePhotoList(potoBytes);

    setState(() {
      _postPhotos = updatedPostphotos;
    });
  }

  Future<List<PhotoToUpload>> _updatePhotoList(Uint8List potoBytes) async {
    final position = _postPhotos.length + 1;

    var updatedPostphotos = _postPhotos;
    updatedPostphotos.add(PhotoToUpload(
      bytes: potoBytes,
      position: position,
    ));

    setState(() {
      _postPhotos = updatedPostphotos;
    });

    final uuid = await hejtoApi.createUpload(
      context: context,
      picture: potoBytes,
    );

    updatedPostphotos = _postPhotos;
    updatedPostphotos[updatedPostphotos.indexWhere(
      (element) => element.position == position,
    )] = PhotoToUpload(
      bytes: potoBytes,
      position: position,
      uuid: uuid,
    );

    return updatedPostphotos;
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

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    if (widget.post != null) {
      post = widget.post!;
    } else {
      post = Post(slug: widget.slug);
      _refreshPostAndComments();
    }

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

    if (post.title == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          _setMoreOptionsButtons(
            post.author?.username == state.username,
          );

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
                          } else if (choice == 'Usuń') {
                            _removePost();
                          }
                        },
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: _buildPost(),
            bottomSheet: Container(
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white.withAlpha(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Scrollbar(
                              child: TextField(
                                focusNode: focusNode,
                                controller: _commentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                minLines: 1,
                                expands: false,
                                decoration: const InputDecoration.collapsed(
                                  hintText: null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: _loadPhotoFromStorage,
                        child: const Icon(
                          Icons.image,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: _sendComment,
                        child: const Icon(
                          Icons.send_sharp,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  _buildPicturePreviews(),
                ],
              ),
            ),
          );
        } else {
          _setMoreOptionsButtons(false);

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
            body: _buildPost(),
          );
        }
      },
    );
  }

  Widget _buildPicturePreviews() {
    final widgets = List<Widget>.empty(growable: true);

    for (var photo in _postPhotos) {
      if (photo.uuid != null) {
        widgets.add(
          _buildUploadedPicturePreview(photo),
        );
      } else {
        widgets.add(
          _buildUploadingPicturePreview(),
        );
      }
    }

    if (widgets.isEmpty) {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: widgets),
        ),
      );
    }
  }

  Container _buildUploadingPicturePreview() {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 32,
        height: 32,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  Padding _buildUploadedPicturePreview(PhotoToUpload photo) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          final updatedPostPhotos = _postPhotos;

          updatedPostPhotos.removeWhere(
            (element) => element.uuid == photo.uuid,
          );

          final reorganizedPostPhotos = List<PhotoToUpload>.empty(
            growable: true,
          );

          var index = 1;
          for (var photo in updatedPostPhotos) {
            reorganizedPostPhotos.add(
              PhotoToUpload(
                bytes: photo.bytes,
                position: index,
                uuid: photo.uuid,
              ),
            );

            index++;
          }

          setState(() {
            _postPhotos = reorganizedPostPhotos;
          });
        },
        child: Image.memory(
          photo.bytes,
          width: 100,
          height: 100,
        ),
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
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 200),
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
                          HejtterLikeButton(
                            likeStatus: post.isLiked,
                            numLikes: post.numLikes,
                            unlikeComment: _unlikePost,
                            likeComment: _likePost,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildTitle(),
                        SizedBox(height: post.type == 'article' ? 10 : 0),
                        post.type == 'article'
                            ? _buildPicture()
                            : const SizedBox(),
                        SizedBox(height: post.type == 'article' ? 10 : 0),
                        _buildContent(),
                        _buildTags(),
                        _buildPoll(),
                        post.type != 'article'
                            ? _buildPicture()
                            : const SizedBox(),
                        const SizedBox(height: 20),
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
        SizedBox(width: widget.post?.hot == true ? 5 : 0),
        widget.post?.hot == true
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
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
        clipBehavior: Clip.antiAlias,
        physics: const NeverScrollableScrollPhysics(),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<CommentItem>(
          noItemsFoundIndicatorBuilder: (context) => const SizedBox(),
          itemBuilder: (context, item, index) {
            return CommentInPostScreen(
              comment: item,
              respondToUser: _respondToUser,
              isOP: item.author?.username == post.author?.username,
              refreshPost: () async {
                await _refreshPostAndComments();
                await Future.delayed(const Duration(milliseconds: 500));
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
            );
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

  Widget _buildPoll() {
    if (post.poll?.options == null ||
        post.poll?.title == null ||
        post.poll?.uuid == null ||
        post.poll?.numVotes == null ||
        post.poll!.options!.length < 2) {
      return const SizedBox();
    }

    return PollWidget(
      title: post.poll!.title!,
      uuid: post.poll!.uuid!,
      options: post.poll!.options!,
      numVotes: post.poll!.numVotes!,
      userVote: post.poll!.userVote,
      votingOnOption: _votingOnOption,
      onVoted: _voteOnPoll,
    );
  }

  Widget _buildPicture() {
    if (post.images == null ||
        post.images!.isEmpty ||
        post.images![0].urls?.the1200X900 == null) {
      return const SizedBox();
    }

    final bool multiplePics = post.images!.length > 1;

    return PicturePreview(
      imageUrl: post.images![0].urls!.the1200X900!,
      multiplePics: multiplePics,
      nsfw: post.nsfw ?? false,
      imagesUrls: post.images,
    );
  }

  Widget _buildTitle() {
    if (post.type == 'article') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          post.title ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(1),
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
                SizedBox(width: widget.post?.author?.sponsor == true ? 5 : 0),
                widget.post?.author?.sponsor == true
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
        color: post.author?.currentColor != null
            ? Color(
                int.parse(
                  post.author!.currentColor!.replaceAll('#', '0xff'),
                ),
              )
            : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        post.author != null ? post.author!.currentRank.toString() : '',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
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
                  builder: (context) => CommunityScreen(
                    community: Community(
                      slug: post.community?.slug,
                      name: post.community?.name,
                      background: post.community?.background,
                      avatar: post.community?.avatar,
                    ),
                  ),
                ),
              );
            }),
            child: Text(
              post.community?.name != null
                  ? post.community!.name.toString()
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
