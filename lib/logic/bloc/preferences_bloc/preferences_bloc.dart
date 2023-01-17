import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends HydratedBloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc()
      : super(
          const PreferencesSet(
            deepLinkDialogDisplayed: false,
          ),
        ) {
    on<SetPreferencesEvent>((event, emit) {
      emit(
        PreferencesSet(
          deepLinkDialogDisplayed: event.deepLinkDialogDisplayed,
        ),
      );
    });
  }

  @override
  PreferencesState fromJson(Map<String, dynamic> json) {
    final deepLinkDialogDisplayed = json['deep_link_dialog_displayed'] as bool?;

    if (deepLinkDialogDisplayed != null) {
      return PreferencesSet(
        deepLinkDialogDisplayed: deepLinkDialogDisplayed,
      );
    } else {
      return const PreferencesSet(
        deepLinkDialogDisplayed: false,
      );
    }
  }

  @override
  Map<String, dynamic>? toJson(PreferencesState state) {
    if (state is PreferencesSet) {
      return {
        'deep_link_dialog_displayed': state.deepLinkDialogDisplayed,
      };
    } else {
      return {
        'deep_link_dialog_displayed': false,
      };
    }
  }
}
