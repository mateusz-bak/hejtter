import 'package:flutter/material.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/utils/constants.dart';

class PostsSearchBar extends StatelessWidget {
  PostsSearchBar({
    super.key,
    required this.show,
    required this.focusNode,
  });

  final bool show;
  final FocusNode? focusNode;

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: searchCubit.searchString,
        builder: (context, AsyncSnapshot<String> snapshot) {
          return AnimatedContainer(
            padding: const EdgeInsets.all(10),
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            height: show ? 75 : 0,
            decoration: const BoxDecoration(),
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<String>(
                    stream: searchCubit.searchString,
                    builder: (context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData) {
                        _controller.text = snapshot.data!;
                        _controller.selection = TextSelection.collapsed(
                            offset: _controller.text.length);
                      }

                      return TextField(
                        controller: _controller,
                        focusNode: focusNode,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Szukaj w postach',
                        ),
                        onSubmitted: (value) {
                          searchCubit.changeString(value);
                        },
                        onChanged: (value) {
                          searchCubit.changeString(value);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
