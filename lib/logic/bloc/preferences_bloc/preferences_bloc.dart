import 'package:equatable/equatable.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends HydratedBloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc()
      : super(
          const PreferencesSet(
            showDeepLinkDialog: true,
            defaultPage: HejtoPage.all,
            defaultHotPeriod: PostsPeriod.sixHours,
          ),
        ) {
    on<SetPreferencesEvent>((event, emit) {
      emit(
        PreferencesSet(
          showDeepLinkDialog: event.showDeepLinkDialog,
          defaultPage: event.defaultPage,
          defaultHotPeriod: event.defaultHotPeriod,
        ),
      );
    });
  }

  @override
  PreferencesState fromJson(Map<String, dynamic> json) {
    final deepLinkDialogDisplayed = json['deep_link_dialog_displayed'] as bool?;
    final defaultPage = json['default_page'] as String?;
    final defaultHotPeriod = json['default_hot_period'] as String?;

    return PreferencesSet(
      showDeepLinkDialog: deepLinkDialogDisplayed ?? false,
      defaultPage: defaultPage == 'discussions'
          ? HejtoPage.discussions
          : defaultPage == 'articles'
              ? HejtoPage.articles
              : HejtoPage.all,
      defaultHotPeriod: defaultHotPeriod == 'three_hours'
          ? PostsPeriod.threeHours
          : defaultHotPeriod == 'twelve_hours'
              ? PostsPeriod.twelveHours
              : defaultHotPeriod == 'twenty_four_hours'
                  ? PostsPeriod.twentyFourHours
                  : PostsPeriod.sixHours,
    );
  }

  @override
  Map<String, dynamic>? toJson(PreferencesState state) {
    if (state is PreferencesSet) {
      return {
        'deep_link_dialog_displayed': state.showDeepLinkDialog,
        'default_page': state.defaultPage == HejtoPage.discussions
            ? 'discussions'
            : state.defaultPage == HejtoPage.articles
                ? 'articles'
                : state.defaultPage == HejtoPage.all
                    ? 'all'
                    : null,
        'default_hot_period': state.defaultHotPeriod == PostsPeriod.threeHours
            ? 'three_hours'
            : state.defaultHotPeriod == PostsPeriod.sixHours
                ? 'six_hours'
                : state.defaultHotPeriod == PostsPeriod.twelveHours
                    ? 'twelve_hours'
                    : state.defaultHotPeriod == PostsPeriod.twentyFourHours
                        ? 'twenty_four_hours'
                        : state.defaultHotPeriod == PostsPeriod.sevenDays
                            ? 'seven_days'
                            : state.defaultHotPeriod == PostsPeriod.thirtyDays
                                ? 'thirty_days'
                                : state.defaultHotPeriod == PostsPeriod.all
                                    ? 'all'
                                    : 'null',
      };
    } else {
      return null;
    }
  }
}
