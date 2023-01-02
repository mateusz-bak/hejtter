part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfilePresentState extends ProfileState {
  final String username;
  final String? avatar;
  final String? background;

  const ProfilePresentState({
    required this.username,
    required this.avatar,
    required this.background,
  });

  @override
  List<Object?> get props => [
        username,
        avatar,
        background,
      ];
}

class ProfileAbsentState extends ProfileState {
  const ProfileAbsentState();

  @override
  List<Object?> get props => [];
}
