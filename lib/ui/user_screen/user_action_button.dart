import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    required this.color,
  }) : super(key: key);

  final IconData icon;
  final Function() onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: IconButton(
        padding: const EdgeInsets.all(10),
        iconSize: 20,
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          foregroundColor: color,
          backgroundColor: primaryColor.withAlpha(100),
        ),
      ),
    );
  }
}
