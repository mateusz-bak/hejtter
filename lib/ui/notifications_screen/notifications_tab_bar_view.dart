import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_emoji/dart_emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:hejtter/models/user_notification.dart';

import 'package:hejtter/utils/constants.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationsTabBarView extends StatefulWidget {
  const NotificationsTabBarView({
    super.key,
    required this.controller,
    this.topDropdown = const SizedBox(),
  });

  final PagingController<int, NotificationItem> controller;
  final Widget topDropdown;

  @override
  State<NotificationsTabBarView> createState() =>
      _NotificationsTabBarViewState();
}

class _NotificationsTabBarViewState extends State<NotificationsTabBarView>
    with AutomaticKeepAliveClientMixin {
  String _addEmojis(String text) {
    final parser = EmojiParser();
    return parser.emojify(text);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => widget.controller.refresh(),
      ),
      child: Column(
        children: [
          widget.topDropdown,
          Expanded(
            child: PagedListView<int, NotificationItem>(
              pagingController: widget.controller,
              padding: const EdgeInsets.all(10),
              builderDelegate: PagedChildBuilderDelegate<NotificationItem>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
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
                                  padding: EdgeInsets.all(
                                      item.status == ItemStatus.NEW ? 3 : 1),
                                  color: item.status == ItemStatus.NEW
                                      ? Colors.green
                                      : Colors.white,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                      height: item.status == ItemStatus.NEW
                                          ? 32
                                          : 36,
                                      width: item.status == ItemStatus.NEW
                                          ? 32
                                          : 36,
                                      imageUrl: item.sender?.avatar?.urls
                                              ?.the250X250 ??
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NotificationItem item) {
    return Expanded(
      child: Html(
        data: _addEmojis(item.content.toString()),
      ),
    );
  }
}
