part of 'preferences_bloc.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object> get props => [];
}

class PreferencesSet extends PreferencesState {
  final bool showDeepLinkDialog;
  final HejtoPage defaultPage;
  final PostsPeriod defaultHotPeriod;

  const PreferencesSet({
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
