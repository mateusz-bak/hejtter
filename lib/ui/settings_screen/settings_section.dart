import 'package:flutter/material.dart';

import 'package:hejtter/utils/constants.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.leading,
  });

  final String title;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20),
        ),
        leading: Icon(
          leading,
          color: primaryColor,
        ),
      ),
    );
  }
}
