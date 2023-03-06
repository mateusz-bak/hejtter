part of 'preferences_bloc.dart';

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object> get props => [];
}

class SetPreferencesEvent extends PreferencesEvent {
  final bool showDeepLinkDialog;
  final HejtoPage defaultPage;
  final PostsPeriod defaultHotPeriod;

  const SetPreferencesEvent({
    required this.showDeepLinkDialog,
    required this.defaultPage,
    required this.defaultHotPeriod,
  });

  @override
  List<Object> get props => [
        showDeepLinkDialog,
        defaultPage,
        defaultHotPeriod,
      ];
}
