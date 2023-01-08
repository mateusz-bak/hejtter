part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfilePresentState extends ProfileState {
  final String username;
  final String? avatar;
  final String? background;
  final bool showNsfw;
  final bool showControversial;
  final bool blurNsfw;

  const ProfilePresentState({
    required this.username,
    required this.avatar,
    required this.background,
    required this.showNsfw,
    required this.showControversial,
    required this.blurNsfw,
  });

  @override
  List<Object?> get props => [
        username,
        avatar,
        background,
        showNsfw,
        showControversial,
        blurNsfw,
      ];
}

class ProfileAbsentState extends ProfileState {
  const ProfileAbsentState({
    this.blockedUsers,
  });

  final List<String>? blockedUsers;

  @override
  List<Object?> get props => [blockedUsers];
}
