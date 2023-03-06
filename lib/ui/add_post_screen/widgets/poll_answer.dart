import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';

class PollAnswer extends StatelessWidget {
  const PollAnswer({
    super.key,
    required this.textController,
    required this.number,
  });

  final TextEditingController textController;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: dividerColor),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$number.  '),
            Expanded(
              child: TextField(
                autofocus: true,
                controller: textController,
                expands: false,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Odpowiedź do ankiety',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
