import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/new_notificationsbloc/new_notifications_bloc.dart';

import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/ui/notifications_screen/widgets/notification_card.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
      color: boltColor,
      onRefresh: () => Future.sync(
        () {
          widget.controller.refresh();
          BlocProvider.of<NewNotificationsBloc>(context).add(
            GetNotificationsEvent(context: context),
          );
        },
      ),
      child: Column(
        children: [
          widget.topDropdown,
          Expanded(
            child: PagedListView<int, HejtoNotification>(
              pagingController: widget.controller,
              padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
              builderDelegate: PagedChildBuilderDelegate<HejtoNotification>(
                itemBuilder: (context, item, index) =>
                    NotificationCard(item: item),
                firstPageProgressIndicatorBuilder: (context) =>
                    LoadingAnimationWidget.threeArchedCircle(
                  color: boltColor,
                  size: 36,
                ),
                newPageProgressIndicatorBuilder: (context) =>
                    LoadingAnimationWidget.threeArchedCircle(
                  color: boltColor,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
