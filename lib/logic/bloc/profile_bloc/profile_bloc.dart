import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'package:hejtter/services/hejto_api.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'profile_state.dart';
part 'profile_event.dart';

class ProfileBloc extends HydratedBloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileAbsentState()) {
    on<SetProfileEvent>((event, emit) async {
      final account = await hejtoApi.getAccount(context: event.context);

      if (account != null) {
        emit(ProfilePresentState(
          username: account.username!,
          avatar: account.avatar?.urls?.the250X250,
          background: account.background?.urls?.the1200X900!,
          showNsfw: account.showNsfw ?? true,
          showControversial: account.showControversial ?? true,
          blurNsfw: account.blurNsfw ?? true,
        ));
      } else {
        emit(const ProfileAbsentState());
      }
    });
    on<ClearProfileEvent>((event, emit) async {
      emit(const ProfileAbsentState());
    });
  }

  @override
  ProfileState fromJson(Map<String, dynamic> json) {
    final username = json['username'] as String?;
    final avatar = json['avatar'] as String?;
    final background = json['background'] as String?;
    final showNsfw = json['show_nsfw'] as bool?;
    final showControversial = json['show_controversial'] as bool?;
    final blurNsfw = json['blur_nsfw'] as bool?;

    if (username != null) {
      return ProfilePresentState(
        username: username,
        avatar: avatar,
        background: background,
        showNsfw: showNsfw ?? true,
        showControversial: showControversial ?? true,
        blurNsfw: blurNsfw ?? true,
      );
    } else {
      return const ProfileAbsentState();
    }
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    if (state is ProfilePresentState) {
      return {
        'username': state.username,
        'avatar': state.avatar,
        'background': state.background,
        'show_nsfw': state.showNsfw,
        'show_controversial': state.showControversial,
        'blur_nsfw': state.blurNsfw,
      };
    } else {
      return {
        'username': null,
        'avatar': null,
        'background': null,
        'show_nsfw': null,
        'show_controversial': null,
        'blur_nsfw': null,
      };
    }
  }
}
