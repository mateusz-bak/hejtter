import 'package:flutter/material.dart';

import 'package:hejtter/utils/locale.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    this.isSmaller = false,
    required this.respondToUser,
    required this.username,
  });
  final bool isSmaller;
  final Function(String?) respondToUser;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      onPressed: () => respondToUser(username),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.comment,
            size: isSmaller ? 16 : 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$answerText',
            style: TextStyle(fontSize: isSmaller ? 12 : null),
          ),
        ],
      ),
    );
  }
}
