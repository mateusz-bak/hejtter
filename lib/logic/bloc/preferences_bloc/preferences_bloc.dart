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
            defaultPostsCategory: PostsCategory.hotSixHours,
          ),
        ) {
    on<SetPreferencesEvent>((event, emit) {
      emit(
        PreferencesSet(
          showDeepLinkDialog: event.showDeepLinkDialog,
          defaultPage: event.defaultPage,
          defaultPostsCategory: event.defaultPostsCategory,
        ),
      );
    });
  }

  @override
  PreferencesState fromJson(Map<String, dynamic> json) {
    final deepLinkDialogDisplayed = json['deep_link_dialog_displayed'] as bool?;
    final defaultPage = json['default_page'] as String?;
    final defaultPostsCategory = json['default_posts_category'] as String?;

    return PreferencesSet(
      showDeepLinkDialog: deepLinkDialogDisplayed ?? false,
      defaultPage: defaultPage == 'discussions'
          ? HejtoPage.discussions
          : defaultPage == 'articles'
              ? HejtoPage.articles
              : HejtoPage.all,
      defaultPostsCategory: defaultPostsCategory == 'hotThreeHours'
          ? PostsCategory.hotThreeHours
          : defaultPostsCategory == 'hotSixHours'
              ? PostsCategory.hotSixHours
              : defaultPostsCategory == 'hotTwelveHours'
                  ? PostsCategory.hotTwelveHours
                  : defaultPostsCategory == 'hotTwentyFourHours'
                      ? PostsCategory.hotTwentyFourHours
                      : defaultPostsCategory == 'topSevenDays'
                          ? PostsCategory.topSevenDays
                          : defaultPostsCategory == 'topThirtyDays'
                              ? PostsCategory.topThirtyDays
                              : defaultPostsCategory == 'all'
                                  ? PostsCategory.all
                                  : defaultPostsCategory == 'followed'
                                      ? PostsCategory.followed
                                      : PostsCategory.hotSixHours,
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
        'default_posts_category':
            state.defaultPostsCategory == PostsCategory.hotThreeHours
                ? 'hotThreeHours'
                : state.defaultPostsCategory == PostsCategory.hotSixHours
                    ? 'hotSixHours'
                    : state.defaultPostsCategory == PostsCategory.hotTwelveHours
                        ? 'hotTwelveHours'
                        : state.defaultPostsCategory ==
                                PostsCategory.hotTwentyFourHours
                            ? 'hotTwentyFourHours'
                            : state.defaultPostsCategory ==
                                    PostsCategory.topSevenDays
                                ? 'topSevenDays'
                                : state.defaultPostsCategory ==
                                        PostsCategory.topThirtyDays
                                    ? 'topThirtyDays'
                                    : state.defaultPostsCategory ==
                                            PostsCategory.all
                                        ? 'all'
                                        : state.defaultPostsCategory ==
                                                PostsCategory.followed
                                            ? 'followed'
                                            : 'hotSixHours',
      };
    } else {
      return null;
    }
  }
}
