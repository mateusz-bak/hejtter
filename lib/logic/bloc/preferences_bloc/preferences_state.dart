part of 'preferences_bloc.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesSet extends PreferencesState {
  final bool deepLinkDialogDisplayed;

  const PreferencesSet({
    required this.deepLinkDialogDisplayed,
  });

  @override
  List<Object> get props => [
        deepLinkDialogDisplayed,
      ];
}
