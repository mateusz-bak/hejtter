import 'package:equatable/equatable.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends HydratedBloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc()
      : super(
          const PreferencesSet(
            deepLinkDialogDisplayed: false,
            defaultTab: DefaultTab.hot,
            defaultPeriod: DefaultPeriod.sixHours,
          ),
        ) {
    on<SetPreferencesEvent>((event, emit) {
      emit(
        PreferencesSet(
          deepLinkDialogDisplayed: event.deepLinkDialogDisplayed,
          defaultTab: event.defaultTab,
          defaultPeriod: event.defaultPeriod,
        ),
      );
    });
  }

  @override
  PreferencesState fromJson(Map<String, dynamic> json) {
    final deepLinkDialogDisplayed = json['deep_link_dialog_displayed'] as bool?;
    final defaultTab = json['default_tab'] as String?;
    final defaultPeriod = json['default_period'] as String?;

    return PreferencesSet(
      deepLinkDialogDisplayed: deepLinkDialogDisplayed ?? false,
      defaultTab: defaultTab == 'hot'
          ? DefaultTab.hot
          : defaultTab == 'top'
              ? DefaultTab.top
              : defaultTab == 'new_tab'
                  ? DefaultTab.newTab
                  : defaultTab == 'followed'
                      ? DefaultTab.followed
                      : DefaultTab.hot,
      defaultPeriod: defaultPeriod == 'six_hours'
          ? DefaultPeriod.sixHours
          : defaultPeriod == 'twelve_hours'
              ? DefaultPeriod.twelveHours
              : defaultPeriod == 'twenty_four_hours'
                  ? DefaultPeriod.twentyFourHours
                  : defaultPeriod == 'seven_days'
                      ? DefaultPeriod.sevenDays
                      : defaultPeriod == 'thirty_days'
                          ? DefaultPeriod.thirtyDays
                          : defaultPeriod == 'all'
                              ? DefaultPeriod.all
                              : DefaultPeriod.sixHours,
    );
  }

  @override
  Map<String, dynamic>? toJson(PreferencesState state) {
    if (state is PreferencesSet) {
      return {
        'deep_link_dialog_displayed': state.deepLinkDialogDisplayed,
        'default_tab': state.defaultTab == DefaultTab.hot
            ? 'hot'
            : state.defaultTab == DefaultTab.top
                ? 'top'
                : state.defaultTab == DefaultTab.newTab
                    ? 'new_tab'
                    : state.defaultTab == DefaultTab.followed
                        ? 'followed'
                        : 'hot',
        'default_period': state.defaultPeriod == DefaultPeriod.sixHours
            ? 'six_hours'
            : state.defaultPeriod == DefaultPeriod.twelveHours
                ? 'twelve_hours'
                : state.defaultPeriod == DefaultPeriod.twentyFourHours
                    ? 'twenty_four_hours'
                    : state.defaultPeriod == DefaultPeriod.sevenDays
                        ? 'seven_days'
                        : state.defaultPeriod == DefaultPeriod.thirtyDays
                            ? 'thirty_days'
                            : state.defaultPeriod == DefaultPeriod.all
                                ? 'all'
                                : 'six_hours',
      };
    } else {
      return null;
    }
  }
}
