part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class SetPreferencesEvent extends PreferencesEvent {
  final bool deepLinkDialogDisplayed;

  const SetPreferencesEvent({
    required this.deepLinkDialogDisplayed,
  });

  @override
  List<Object> get props => [
        deepLinkDialogDisplayed,
      ];
}
