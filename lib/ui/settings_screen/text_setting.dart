import 'package:flutter/material.dart';

class TextSetting extends StatelessWidget {
  const TextSetting({super.key, required this.title, this.onPressed});

  final String title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ListTile(
        title: Text(title),
      ),
    );
  }
}
