import 'package:flutter/material.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class PostTypesButton extends StatefulWidget {
  const PostTypesButton({
    super.key,
    required this.text,
    required this.mainAxisAlignment,
    required this.onPressed,
    required this.positionedOnLeft,
  });

  final dynamic text;
  final MainAxisAlignment mainAxisAlignment;
  final Function() onPressed;
  final bool positionedOnLeft;

  @override
  State<PostTypesButton> createState() => _PostTypesButtonState();
}

class _PostTypesButtonState extends State<PostTypesButton> {
  String _decideText() {
    switch (widget.text) {
      case HejtoPage.all:
        return 'Wszystko';
      case HejtoPage.articles:
        return 'Artykuły';
      case HejtoPage.discussions:
        return 'Wpisy';
      case PostsCategory.hotThreeHours:
        return 'Gorące 3h';
      case PostsCategory.hotSixHours:
        return 'Gorące 6h';
      case PostsCategory.hotTwelveHours:
        return 'Gorące 12h';
      case PostsCategory.hotTwentyFourHours:
        return 'Gorące 24h';
      case PostsCategory.topSevenDays:
        return 'Top 7d';
      case PostsCategory.topThirtyDays:
        return 'Top 30d';
      case PostsCategory.all:
        return 'Najnowsze';
      case PostsCategory.followed:
        return 'Obserwowane';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.positionedOnLeft ? 10 : 0),
          bottomLeft: Radius.circular(widget.positionedOnLeft ? 10 : 0),
          topRight: Radius.circular(widget.positionedOnLeft ? 0 : 10),
          bottomRight: Radius.circular(widget.positionedOnLeft ? 0 : 10),
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _decideText(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.expand_more,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
