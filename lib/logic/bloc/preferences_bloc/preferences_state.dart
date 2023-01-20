part of 'preferences_bloc.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesSet extends PreferencesState {
  final bool deepLinkDialogDisplayed;
  final DefaultTab defaultTab;
  final DefaultPeriod defaultPeriod;

  const PreferencesSet({
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
