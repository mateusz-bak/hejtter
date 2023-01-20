part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class SetPreferencesEvent extends PreferencesEvent {
  final bool deepLinkDialogDisplayed;
  final DefaultTab defaultTab;
  final DefaultPeriod defaultPeriod;

  const SetPreferencesEvent({
    required this.deepLinkDialogDisplayed,
    required this.defaultTab,
    required this.defaultPeriod,
  });

  @override
  List<Object> get props => [
        deepLinkDialogDisplayed,
        defaultTab,
        defaultPeriod,
      ];
}
