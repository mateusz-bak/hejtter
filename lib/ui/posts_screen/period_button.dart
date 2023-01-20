import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';

class PeriodButton extends StatelessWidget {
  const PeriodButton({
    Key? key,
    required this.period,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final String period;
  final bool selected;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? primaryColor : Colors.black.withOpacity(0.8),
          foregroundColor: Colors.white,
          minimumSize: Size.zero,
          padding: const EdgeInsets.fromLTRB(18, 5, 18, 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Text(
          period,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
