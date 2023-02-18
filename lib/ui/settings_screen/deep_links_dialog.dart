import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';

class DeepLinksDialog extends StatefulWidget {
  const DeepLinksDialog({
    Key? key,
    required this.state,
  }) : super(key: key);

  final PreferencesSet state;

  @override
  State<DeepLinksDialog> createState() => _DeepLinksDialogState();
}

class _DeepLinksDialogState extends State<DeepLinksDialog> {
  _updatePreferences(BuildContext context) {
    BlocProvider.of<PreferencesBloc>(context).add(
      SetPreferencesEvent(
        deepLinkDialogDisplayed: true,
        defaultHotPeriod: widget.state.defaultHotPeriod,
        defaultPage: widget.state.defaultPage,
      ),
    );
  }

  bool _goToSettingsClicked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Otwierać linki Hejto.pl w aplikacji?',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Text('1. Kliknij '),
              Text(
                '"Przejdź do ustawień"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('2. Kliknij '),
              Text(
                '"Otwieraj domyślnie"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('3. Zaznacz '),
              Text(
                '"Otwieraj obsługiwane łącza"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('4. Kliknij '),
              Text(
                '"Dodaj link"',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Text('5. Zaznacz '),
              Text(
                'obie opcje',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        FilledButton.tonal(
          onPressed: () {
            _updatePreferences(context);
            Navigator.of(context).pop();
          },
          child: const Text('Nie'),
        ),
        FilledButton(
          onPressed: !_goToSettingsClicked
              ? () {
                  setState(() {
                    _goToSettingsClicked = true;
                  });

                  _updatePreferences(context);
                  AppSettings.openAppSettings();
                }
              : () => Navigator.of(context).pop(),
          child: !_goToSettingsClicked
              ? const Text('Przejdź do ustawień')
              : const Text('Zrobione'),
        ),
      ],
    );
  }
}
