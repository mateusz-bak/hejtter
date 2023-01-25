import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
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
    }
  }

  @override
  void initState() {
    super.initState();
    item = widget.item;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openNotification(context);
      },
      child: Material(
        color: backgroundColor,
        child: Card(
          color: item.status == ItemStatus.NEW
              ? primaryColor.withOpacity(0.15)
              : backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding:
                          EdgeInsets.all(item.status == ItemStatus.NEW ? 3 : 1),
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
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HejtoNotification item) {
    return Expanded(
      child: Html(
        data: _addEmojis(item.content.toString()),
      ),
    );
  }
}
