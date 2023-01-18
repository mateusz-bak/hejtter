import 'package:flutter/material.dart';
import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/notifications_screen/notifications_tab_bar_view.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.updateCounter});

  final Function(int) updateCounter;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin {
  static const _pageSize = 20;
  int _currentTab = 0;

  final PagingController<int, NotificationItem>
      _myNotificationsPagingController = PagingController(firstPageKey: 1);
  final PagingController<int, NotificationItem>
      _followedNotificationsPagingController =
      PagingController(firstPageKey: 1);

  Future<void> _fetchMyNotificationsPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getNotifications(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        type: 'my',
      );

      final isLastPage = newItems!.length < _pageSize;

      if (isLastPage) {
        if (!mounted) return;
        _myNotificationsPagingController.appendLastPage(
          _removeDoubledNotifications(
            _myNotificationsPagingController,
            newItems,
          ),
        );

        _updateUnreadCounter(_myNotificationsPagingController);
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _myNotificationsPagingController.appendPage(
          _removeDoubledNotifications(
            _myNotificationsPagingController,
            newItems,
          ),
          nextPageKey,
        );

        _updateUnreadCounter(_myNotificationsPagingController);
      }
    } catch (error) {
      _myNotificationsPagingController.error = error;
    }
  }

  Future<void> _fetchFollowedNotificationsPage(int pageKey) async {
    try {
      final newItems = await hejtoApi.getNotifications(
        pageKey: pageKey,
        pageSize: _pageSize,
        context: context,
        type: 'followed',
      );

      final isLastPage = newItems!.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _followedNotificationsPagingController.appendLastPage(
          _removeDoubledNotifications(
            _followedNotificationsPagingController,
            newItems,
          ),
        );

        _updateUnreadCounter(_myNotificationsPagingController);
      } else {
        final nextPageKey = pageKey + 1;
        if (!mounted) return;
        _followedNotificationsPagingController.appendPage(
          _removeDoubledNotifications(
            _followedNotificationsPagingController,
            newItems,
          ),
          nextPageKey,
        );

        _updateUnreadCounter(_myNotificationsPagingController);
      }
    } catch (error) {
      _followedNotificationsPagingController.error = error;
    }
  }

  _updateUnreadCounter(PagingController<int, NotificationItem> controller) {
    int counter = 0;

    final notifications = controller.itemList;

    if (notifications == null) return;

    for (var notif in notifications) {
      if (notif.status == ItemStatus.NEW) {
        counter++;
      }
    }

    widget.updateCounter(counter);
  }

  List<NotificationItem> _removeDoubledNotifications(
    PagingController<int, NotificationItem> controller,
    List<NotificationItem> items,
  ) {
    final checkedItems = List<NotificationItem>.empty(growable: true);
    final currentList = controller.itemList;
    if (currentList == null) {
      return items;
    }

    for (var item in items) {
      if (!currentList.any((element) => element.uuid == item.uuid)) {
        checkedItems.add(item);
      }
    }

    return checkedItems;
  }

  @override
  void initState() {
    _myNotificationsPagingController.addPageRequestListener((pageKey) {
      _fetchMyNotificationsPage(pageKey);
    });

    _followedNotificationsPagingController.addPageRequestListener((pageKey) {
      _fetchFollowedNotificationsPage(pageKey);
    });

    super.initState();
  }

  @override
  void dispose() {
    _myNotificationsPagingController.dispose();
    _followedNotificationsPagingController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Builder(builder: (context) {
      return Container(
        color: backgroundColor,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                onTap: (value) {
                  if (value == _currentTab) {
                    if (value == 0) {
                      _myNotificationsPagingController.refresh();
                    } else if (value == 1) {
                      _followedNotificationsPagingController.refresh();
                    }
                  }

                  setState(() {
                    _currentTab = value;
                  });
                },
                indicatorColor: const Color(0xff2295F3),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: [
                  _buildTab(context, 0, 'Moje'),
                  _buildTab(context, 1, 'Obserwowane'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    NotificationsTabBarView(
                      controller: _myNotificationsPagingController,
                    ),
                    NotificationsTabBarView(
                      controller: _followedNotificationsPagingController,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Tab _buildTab(BuildContext context, int index, String text) {
    return Tab(
      child: FittedBox(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
