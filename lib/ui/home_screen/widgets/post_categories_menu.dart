import 'package:flutter/material.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class PostCategoriesMenu extends StatelessWidget {
  const PostCategoriesMenu({
    super.key,
    required this.options,
    required this.onPressed,
  });

  final List<PostsCategory?> options;
  final Function(PostsCategory) onPressed;

  String _getOptionText(PostsCategory option) {
    switch (option) {
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
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildOptions(),
        ),
      ),
    );
  }

  List<Widget> _buildOptions() {
    final widgets = List<Widget>.empty(growable: true);

    for (var option in options) {
      widgets.add(
        option == null
            ? const SizedBox(height: 10)
            : StreamBuilder<PostsCategory>(
                stream: discussionsNavCubit.currentPostsCategoryFetcher,
                builder: (context, snapshot) {
                  return ElevatedButton(
                    onPressed: () => onPressed(option),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: option == snapshot.data
                          ? primaryColor
                          : Colors.transparent,
                      foregroundColor: option == snapshot.data
                          ? onPrimaryColor
                          : onPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(width: 1, color: dividerColor),
                      ),
                    ),
                    child: Text(
                      _getOptionText(option),
                      style: const TextStyle(
                        fontSize: 16,
                        wordSpacing: 2,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }),
      );
    }

    return widgets;
  }
}
