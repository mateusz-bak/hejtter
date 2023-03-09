import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';

class DrawerDestination extends StatelessWidget {
  const DrawerDestination({
    super.key,
    required this.text,
    required this.icon,
    this.current = false,
    this.onTap,
  });

  final String text;
  final Widget icon;
  final bool current;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: current ? backgroundSecondaryColor : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Text(text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
