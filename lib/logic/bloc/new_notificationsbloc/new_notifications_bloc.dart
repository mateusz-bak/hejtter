import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/models/user_notification.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:equatable/equatable.dart';

part 'new_notifications_event.dart';
part 'new_notifications_state.dart';

class NewNotificationsBloc
    extends Bloc<NewNotificationsEvent, NewNotificationsState> {
  NewNotificationsBloc() : super(const NewNotificationsAbsent()) {
    on<GetNotificationsEvent>((event, emit) async {
      final notifications = await hejtoApi.getNotifications(
        pageKey: 1,
        pageSize: 20,
        context: event.context,
        type: null,
      );

      if (notifications != null) {
        final newNotificationsPresent = _parseNotifications(notifications);

        if (newNotificationsPresent) {
          emit(const NewNotificationsPresent());
          return;
        }
      }

      emit(const NewNotificationsAbsent());
    });
  }

  bool _parseNotifications(List<HejtoNotification> list) {
    bool newNotificationsPresent = false;

    if (list.isNotEmpty) {
      for (var element in list) {
        if (element.status == ItemStatus.NEW) {
          newNotificationsPresent = true;
        }
      }
    }

    return newNotificationsPresent;
  }
}
