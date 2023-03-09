part of 'new_notifications_bloc.dart';

abstract class NewNotificationsState extends Equatable {
  const NewNotificationsState();

  @override
  List<Object?> get props => [];
}

class NewNotificationsPresent extends NewNotificationsState {
  const NewNotificationsPresent();

  @override
  List<Object?> get props => [];
}

class NewNotificationsAbsent extends NewNotificationsState {
  const NewNotificationsAbsent();

  @override
  List<Object?> get props => [];
}
