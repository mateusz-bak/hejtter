import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.item,
  });

  final HejtoNotification item;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  late HejtoNotification item;

  String _addEmojis(String text) {
    final parser = EmojiParser();
    return parser.emojify(text);
  }

  Widget _prepareNotificationDate() {
    if (item.createdAt == null) {
      return const SizedBox();
    }

    final time = '${item.createdAt?.hour}:${item.createdAt?.minute}';

    late String monthStr;

    switch (item.createdAt?.month) {
      case 1:
        monthStr = 'sty';
        break;
      case 2:
        monthStr = 'lut';
        break;
      case 3:
        monthStr = 'mar';
        break;
      case 4:
        monthStr = 'kwi';
        break;
      case 5:
        monthStr = 'maj';
        break;
      case 6:
        monthStr = 'cze';
        break;
      case 7:
        monthStr = 'lip';
        break;
      case 8:
        monthStr = 'sie';
        break;
      case 9:
        monthStr = 'wrz';
        break;
      case 10:
        monthStr = 'paź';
        break;
      case 11:
        monthStr = 'lis';
        break;
      case 12:
        monthStr = 'gru';
        break;
      default:
        monthStr = '';
    }
    final date = '${item.createdAt?.day} $monthStr ${item.createdAt?.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, bottom: 10),
          child: Text(
            '$time  $date',
            style: TextStyle(
              color:
                  item.status == ItemStatus.NEW ? onPrimaryColor : dividerColor,
            ),
          ),
        ),
      ],
    );
  }

  _openNotification(BuildContext context) {
    setState(() {
      item.status = ItemStatus.READ;
    });

    if (item.uuid != null) {
      hejtoApi.getNotificationDetails(
        context: context,
        uuid: item.uuid!,
      );
    }

    if (widget.item.resourceName == ResourceName.POST_LIKE ||
        widget.item.resourceName == ResourceName.POST ||
        widget.item.resourceName == ResourceName.POST_COMMENT ||
        widget.item.resourceName == ResourceName.POST_COMMENT_LIKE) {
      final slug = widget.item.resourceParams?.slug;
      if (slug != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return PostScreen(
                slug: slug,
              );
            },
          ),
        );
      }
    } else if (widget.item.resourceName == ResourceName.USER_ACHIEVEMENT) {
      final profileState = context.read<ProfileBloc>().state;

      if (profileState is ProfilePresentState) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return UserScreen(
                userName: profileState.username,
              );
            },
          ),
        );
      }
    } else if (widget.item.type == Type.SYSTEM) {
      final profileState = context.read<ProfileBloc>().state;

      if (profileState is ProfilePresentState) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return UserScreen(
                userName: profileState.username,
              );
            },
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          _openNotification(context);
        },
        child: Card(
          color: item.status == ItemStatus.NEW
              ? backgroundSecondaryColor
              : backgroundColor,
          elevation: 0,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: EdgeInsets.all(
                            item.status == ItemStatus.NEW ? 3 : 1),
                        color: item.status == ItemStatus.NEW
                            ? Colors.green
                            : Colors.white,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            height: item.status == ItemStatus.NEW ? 32 : 36,
                            width: item.status == ItemStatus.NEW ? 32 : 36,
                            imageUrl: item.sender?.avatar?.urls?.the250X250 ??
                                defaultAvatar,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildContent(item),
                ],
              ),
              _prepareNotificationDate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HejtoNotification item) {
    return Expanded(
      child: Html(
        data: _addEmojis(item.content.toString()),
        style: {
          'body': Style(
            color: Colors.white70,
            maxLines: 3,
            textOverflow: TextOverflow.ellipsis,
          )
        },
      ),
    );
  }
}
