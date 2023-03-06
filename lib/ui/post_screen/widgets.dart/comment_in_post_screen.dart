import 'package:cached_network_image/cached_network_image.dart';

import 'package:dart_emoji/dart_emoji.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';

import 'package:hejtter/models/comments_response.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/widgets.dart/widgets.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:url_launcher/url_launcher.dart';

class CommentInPostScreen extends StatefulWidget {
  const CommentInPostScreen({
    required this.comment,
    required this.respondToUser,
    required this.refreshPost,
    required this.isOP,
    super.key,
  });

  final CommentItem comment;
  final Function(String?) respondToUser;
  final Function() refreshPost;
  final bool isOP;

  @override
  State<CommentInPostScreen> createState() => _CommentInPostScreenState();
}

class _CommentInPostScreenState extends State<CommentInPostScreen> {
  CommentItem? comment;

  final moreButtonOptions = {
    // 'Edytuj',
    'Usuń',
  };

  final buttonOptions = {'Zgłoś'};

  _removeComment() async {
    if (comment?.postSlug == null || comment?.uuid == null) return;

    final result = await hejtoApi.removeComment(
      postSlug: comment!.postSlug!,
      uuid: comment!.uuid!,
      context: context,
    );

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentarz usunięty')),
      );

      widget.refreshPost();
    }
  }

  _setTimeAgoLocale() {
    timeago.setLocaleMessages('pl', timeago.PlMessages());
  }

  String _addEmojis(String text) {
    final parser = EmojiParser();
    return parser.emojify(text);
  }

  _goToUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(
          userName: comment?.author?.username,
        ),
      ),
    );
  }

  Future<void> _likeComment(BuildContext context) async {
    final result = await hejtoApi.likeComment(
      postSlug: comment?.postSlug,
      commentUUID: comment?.uuid,
      context: context,
    );
    if (result && mounted) {
      final newComment = await _refreshComment(context);

      setState(() {
        comment = newComment;
      });
    }
  }

  Future<void> _unlikeComment(BuildContext context) async {
    final result = await hejtoApi.unlikeComment(
      postSlug: comment?.postSlug,
      commentUUID: comment?.uuid,
      context: context,
    );

    if (result && mounted) {
      final newComment = await _refreshComment(context);

      setState(() {
        comment = newComment;
      });
    }
  }

  Future<CommentItem?> _refreshComment(BuildContext context) async {
    return await hejtoApi.getCommentDetails(
      postSlug: comment?.postSlug,
      commentUUID: comment?.uuid,
      context: context,
    );
  }

  @override
  void initState() {
    super.initState();

    comment = widget.comment;
  }

  @override
  Widget build(BuildContext context) {
    _setTimeAgoLocale();

    return Container(
      decoration: BoxDecoration(
        color: widget.isOP
            ? backgroundSecondaryColor.withOpacity(0.4)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
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
                _buildMoreButton(comment?.author?.username),
                HejtterLikeButton(
                  author: comment?.author?.username,
                  likeStatus: comment?.isLiked,
                  numLikes: comment?.numLikes,
                  unlikeComment: _unlikeComment,
                  likeComment: _likeComment,
                  small: true,
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
          SizedBox(height: widget.isOP ? 12 : 0),
          _buildContent(),
          _buildPictures(),
          Padding(
            padding: const EdgeInsets.only(left: 42),
            child: AnswerButton(
              isSmaller: true,
              username: widget.comment.author?.username,
              respondToUser: widget.respondToUser,
            ),
          ),
          const SizedBox(height: 0),
        ],
      ),
    );
  }

  Widget _buildMoreButton(String? author) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState && state.username == author) {
          return PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (BuildContext context) {
              return moreButtonOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                  onTap: () {
                    if (choice == 'Edytuj') {
                      // _editComment();
                    } else if (choice == 'Usuń') {
                      _removeComment();
                    }
                  },
                );
              }).toList();
            },
          );
        } else {
          return PopupMenuButton<String>(
            onSelected: (_) {},
            itemBuilder: (BuildContext context) {
              return buttonOptions.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                  onTap: () {
                    if (choice == 'Zgłoś') {
                      _reportComment();
                    }
                  },
                );
              }).toList();
            },
          );
        }
      },
    );
  }

  Widget _buildPictures() {
    final images = comment?.images;

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

  Widget _buildContent() {
    return Row(
      children: [
        const SizedBox(width: 52),
        Expanded(
          child: MarkdownBody(
            data: _addEmojis(comment?.content ?? ''),
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
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
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final avatarUrl = comment?.author?.avatar?.urls?.the100X100;

    return GestureDetector(
      onTap: () => _goToUserScreen(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(1),
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
                    comment?.author != null
                        ? comment!.author!.username.toString()
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(width: comment?.author?.sponsor == true ? 5 : 0),
                comment?.author?.sponsor == true
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
                  widget.isOP ? 'OP' : '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: widget.isOP ? 5 : 0),
                const SizedBox(width: 5),
                _buildRankPlate(),
              ],
            ),
            Text(
              comment?.createdAt != null
                  ? timeago.format(DateTime.parse('${comment?.createdAt}'),
                      locale: 'pl')
                  : 'null',
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.05,
              ),
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
        color: comment?.author?.currentColor != null
            ? Color(
                int.parse(
                  comment!.author!.currentColor!.replaceAll('#', '0xff'),
                ),
              )
            : Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        comment?.author != null ? comment!.author!.currentRank.toString() : '',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  _reportAsNotAuthorized() {
    if (comment?.links?.self == null) return;
    const firstPart = 'Zgłaszam złamanie regulaminu:\n\n';
    final commentUrl =
        'https://www.hejto.pl/posts/${comment?.links?.self?.href}';
    const lastPart = '\n\nPozdrawiam';

    final Email email = Email(
      body: '$firstPart$commentUrl$lastPart',
      subject: 'Złamanie regulaminu',
      recipients: ['support@hejto.pl'],
      isHTML: false,
    );

    FlutterEmailSender.send(email).then((value) {
      const SnackBar snackBar = SnackBar(content: Text('Zgłoszono komentarz'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  _reportComment() async {
    if (context.read<ProfileBloc>().state is ProfileAbsentState) {
      _reportAsNotAuthorized();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (comment?.postSlug == null || comment?.uuid == null) return;

      showDialog(
        context: context,
        builder: (context) {
          return ReportDialog(
            postSlug: comment!.postSlug!,
            commentUUID: comment!.uuid!,
          );
        },
      );
    });
  }
}
