import 'package:flutter/material.dart';
import 'package:hejtter/models/post.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PollWidget extends StatelessWidget {
  const PollWidget({
    super.key,
    required this.title,
    required this.uuid,
    required this.options,
    required this.numVotes,
    required this.userVote,
    required this.onVoted,
    required this.votingOnOption,
  });

  final String title;
  final String uuid;
  final List<HejtoPollOption> options;
  final int numVotes;
  final int? userVote;
  final int? votingOnOption;
  final Future<void> Function(String, int) onVoted;

  String _decideVotesText() {
    if (numVotes == 0) {
      return 'głosów';
    } else if (numVotes == 1) {
      return 'głos';
    }

    final numVotesString = numVotes.toString();
    final lastChar = numVotesString[numVotesString.length - 1];

    if (lastChar == '2' || lastChar == '3' || lastChar == '4') {
      return 'głosy';
    } else {
      return 'głosów';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _buildPollOptions(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text('$numVotes ${_decideVotesText()}'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPollOptions(BuildContext context) {
    final widgets = List<Widget>.empty(growable: true);

    final Size percentageSize = (TextPainter(
      text: const TextSpan(text: '100%'),
      maxLines: 1,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout())
        .size;

    for (var option in options) {
      final votes = option.numVotes ?? 0;
      final double percentage = numVotes == 0.0 ? 0 : (votes * 100 / numVotes);

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Stack(
          children: [
            _buildOptionBackground(),
            _buildOptionForeground(
              percentage != 0 ? percentage.toInt() : 0,
              option,
              context,
            ),
            _buildOptionContent(option, percentageSize, percentage, context),
          ],
        ),
      ));
    }

    return widgets;
  }

  GestureDetector _buildOptionContent(
    HejtoPollOption option,
    Size percentageSize,
    double percentage,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: votingOnOption == null && option.num != null
          ? () => onVoted(uuid, option.num!)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: votingOnOption == option.num
                  ? Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: boltColor,
                          size: 16,
                        ),
                      ),
                    )
                  : Text(
                      option.title.toString(),
                      style: TextStyle(
                        fontWeight:
                            userVote == option.num ? FontWeight.bold : null,
                        color: userVote == option.num ? Colors.black : null,
                      ),
                    ),
            ),
            const SizedBox(width: 5),
            SizedBox(
              child: userVote == option.num
                  ? const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Center(
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 20,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
            SizedBox(
              width: percentageSize.width + 16,
              child: userVote != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight:
                                userVote == option.num ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Positioned _buildOptionForeground(
    int percentage,
    HejtoPollOption option,
    BuildContext context,
  ) {
    return Positioned.fill(
      child: Row(
        children: [
          percentage != 0
              ? Expanded(
                  flex: percentage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: userVote == null
                          ? Colors.transparent
                          : userVote == option.num
                              ? boltColor
                              : primaryColor,
                    ),
                  ),
                )
              : const SizedBox(),
          percentage != 100
              ? Spacer(
                  flex: 100 - percentage,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Positioned _buildOptionBackground() {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
