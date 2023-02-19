import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/post.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

List<Post> filterLocallyBlockedUsers(List<Post> list, BuildContext context) {
  final state = BlocProvider.of<ProfileBloc>(context).state;
  if (state is ProfileAbsentState) {
    if (state.blockedUsers == null) return list;

    list.removeWhere((element) {
      return state.blockedUsers!.contains(element.author?.username);
    });

    return list;
  } else {
    return list;
  }
}

List<Post> removeDoubledPosts(
  PagingController<int, Post> controller,
  List<Post> items,
) {
  final checkedItems = List<Post>.empty(growable: true);
  final currentList = controller.itemList;
  if (currentList == null) {
    return items;
  }

  for (var item in items) {
    if (!currentList.any((element) => element.slug == item.slug)) {
      checkedItems.add(item);
    }
  }

  return checkedItems;
}
