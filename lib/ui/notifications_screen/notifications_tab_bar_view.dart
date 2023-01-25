import 'package:flutter/material.dart';

import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/ui/notifications_screen/notification_card.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationsTabBarView extends StatefulWidget {
  const NotificationsTabBarView({
    super.key,
    required this.controller,
    this.topDropdown = const SizedBox(),
  });

  final PagingController<int, HejtoNotification> controller;
  final Widget topDropdown;

  @override
  State<NotificationsTabBarView> createState() =>
      _NotificationsTabBarViewState();
}

class _NotificationsTabBarViewState extends State<NotificationsTabBarView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => Future.sync(
        () => widget.controller.refresh(),
      ),
      child: Column(
        children: [
          widget.topDropdown,
          Expanded(
            child: PagedListView<int, HejtoNotification>(
              pagingController: widget.controller,
              padding: const EdgeInsets.all(10),
              builderDelegate: PagedChildBuilderDelegate<HejtoNotification>(
                itemBuilder: (context, item, index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: NotificationCard(item: item),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
