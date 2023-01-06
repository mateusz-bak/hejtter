import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';

class SwitchSetting extends StatelessWidget {
  const SwitchSetting({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }
}
