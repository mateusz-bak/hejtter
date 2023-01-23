part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class SetPreferencesEvent extends PreferencesEvent {
  final bool deepLinkDialogDisplayed;
  final HejtoPage defaultPage;
  final PostsPeriod defaultHotPeriod;

  const SetPreferencesEvent({
    required this.deepLinkDialogDisplayed,
    required this.defaultPage,
    required this.defaultHotPeriod,
  });

  @override
  List<Object> get props => [
        deepLinkDialogDisplayed,
        defaultPage,
        defaultHotPeriod,
      ];
}
