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

    if (username != null) {
      return ProfilePresentState(
        username: username,
        avatar: avatar,
        background: background,
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
      };
    } else {
      return {
        'username': null,
        'avatar': null,
        'background': null,
      };
    }
  }
}
