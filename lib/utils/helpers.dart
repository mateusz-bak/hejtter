import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}
