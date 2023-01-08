part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class SetProfileEvent extends ProfileEvent {
  const SetProfileEvent({
    required this.context,
  });

  final BuildContext context;

  @override
  List<Object?> get props => [];
}

class ClearProfileEvent extends ProfileEvent {
  const ClearProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUnloggedBlocksProfileEvent extends ProfileEvent {
  const UpdateUnloggedBlocksProfileEvent({
    this.usernames,
  });

  final List<String>? usernames;

  @override
  List<Object?> get props => [];
}
