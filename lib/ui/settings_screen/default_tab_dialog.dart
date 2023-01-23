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
  _updatePreferences(HejtoPage defaultPage) {
    BlocProvider.of<PreferencesBloc>(context).add(
      SetPreferencesEvent(
        deepLinkDialogDisplayed: true,
        defaultHotPeriod: widget.state.defaultHotPeriod,
        defaultPage: defaultPage,
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
                'Wybierz stronę początkową',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SettingsDialogButton(
              text: 'Artykuły',
              onPressed: () => _updatePreferences(HejtoPage.articles),
            ),
            SettingsDialogButton(
              text: 'Dyskusje',
              onPressed: () => _updatePreferences(HejtoPage.discussions),
            ),
          ],
        ),
      ),
    );
  }
}
