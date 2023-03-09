import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/ui/settings_screen/widgets/widgets.dart';
import 'package:hejtter/utils/enums.dart';

class DefaultPeriodDialog extends StatefulWidget {
  const DefaultPeriodDialog({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PreferencesSet state;

  @override
  State<DefaultPeriodDialog> createState() => _DefaultPeriodDialogState();
}

class _DefaultPeriodDialogState extends State<DefaultPeriodDialog> {
  _updatePreferences(PostsCategory defaultPostsCategory) {
    BlocProvider.of<PreferencesBloc>(context).add(
      SetPreferencesEvent(
        showDeepLinkDialog: widget.state.showDeepLinkDialog,
        defaultPostsCategory: defaultPostsCategory,
        defaultPage: widget.state.defaultPage,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Wybierz domyślny okres gorących',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SettingsDialogButton(
              text: 'Gorące 3h',
              onPressed: () => _updatePreferences(
                PostsCategory.hotThreeHours,
              ),
            ),
            SettingsDialogButton(
              text: 'Gorące 6h',
              onPressed: () => _updatePreferences(
                PostsCategory.hotSixHours,
              ),
            ),
            SettingsDialogButton(
              text: 'Gorące 12h',
              onPressed: () => _updatePreferences(
                PostsCategory.hotTwelveHours,
              ),
            ),
            SettingsDialogButton(
              text: 'Gorące 24h',
              onPressed: () => _updatePreferences(
                PostsCategory.hotTwentyFourHours,
              ),
            ),
            SettingsDialogButton(
              text: 'Top 7 dni',
              onPressed: () => _updatePreferences(
                PostsCategory.topSevenDays,
              ),
            ),
            SettingsDialogButton(
              text: 'Top 30 dni',
              onPressed: () => _updatePreferences(
                PostsCategory.topThirtyDays,
              ),
            ),
            SettingsDialogButton(
              text: 'Najnowsze',
              onPressed: () => _updatePreferences(
                PostsCategory.all,
              ),
            ),
            SettingsDialogButton(
              text: 'Obserwowane',
              onPressed: () => _updatePreferences(
                PostsCategory.followed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
