part of 'new_notifications_bloc.dart';

abstract class NewNotificationsEvent extends Equatable {
  const NewNotificationsEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NewNotificationsEvent {
  const GetNotificationsEvent({required this.context});

  final BuildContext context;

  @override
  List<Object?> get props => [context];
}
