import 'package:flutter/material.dart';
import 'package:hejtter/logic/cubit/discussions_nav_cubit.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class HejtoPagesMenu extends StatelessWidget {
  const HejtoPagesMenu({
    super.key,
    required this.options,
    required this.onPressed,
  });

  final List<HejtoPage> options;
  final Function(HejtoPage) onPressed;

  String _getOptionText(HejtoPage option) {
    switch (option) {
      case HejtoPage.all:
        return 'Wszystko';
      case HejtoPage.articles:
        return 'Artykuły';
      case HejtoPage.discussions:
        return 'Wpisy';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          border: Border.all(
            width: 1,
            color: dividerColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildOptions(),
        ),
      ),
      // ),
    );
  }

  List<Widget> _buildOptions() {
    final widgets = List<Widget>.empty(growable: true);

    for (var option in options) {
      widgets.add(
        StreamBuilder<HejtoPage>(
            stream: discussionsNavCubit.currentHejtoPageFetcher,
            builder: (context, snapshot) {
              return ElevatedButton(
                onPressed: () => onPressed(option),
                style: ElevatedButton.styleFrom(
                  backgroundColor: option == snapshot.data
                      ? primaryColor
                      : Colors.transparent,
                  foregroundColor:
                      option == snapshot.data ? onPrimaryColor : onPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(width: 1, color: dividerColor),
                  ),
                ),
                child: Text(
                  _getOptionText(option),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }),
      );
    }

    return widgets;
  }
}
