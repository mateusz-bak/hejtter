import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/ui/settings_screen/settings_dialog_button.dart';
import 'package:hejtter/utils/enums.dart';

class DefaultTabDialog extends StatefulWidget {
  const DefaultTabDialog({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PreferencesSet state;

  @override
  State<DefaultTabDialog> createState() => _DefaultTabDialogState();
}

class _DefaultTabDialogState extends State<DefaultTabDialog> {
  _updatePreferences(DefaultTab defaultTab) {
    BlocProvider.of<PreferencesBloc>(context).add(
      SetPreferencesEvent(
        deepLinkDialogDisplayed: true,
        defaultPeriod: widget.state.defaultPeriod,
        defaultTab: defaultTab,
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
                'Wybierz domyślną kartę',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SettingsDialogButton(
              text: 'Gorące',
              onPressed: () => _updatePreferences(DefaultTab.hot),
            ),
            SettingsDialogButton(
              text: 'Top',
              onPressed: () => _updatePreferences(DefaultTab.top),
            ),
            SettingsDialogButton(
              text: 'Najnowsze',
              onPressed: () => _updatePreferences(DefaultTab.newTab),
            ),
            SettingsDialogButton(
              text: 'Obserwowane',
              onPressed: () => _updatePreferences(DefaultTab.followed),
            ),
          ],
        ),
      ),
    );
  }
}
