import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/add_post_screen.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode focusNode = FocusNode();
  var _showSearchBar = false;

  Future<String?> _addPost(
    String content,
    bool isNsfw,
    String communitySlug,
    List<PhotoToUpload>? images,
  ) async {
    final List<dynamic> imagesJsons = List.empty(growable: true);

    final result = await hejtoApi.createPost(
      context: context,
      content: content,
      isNsfw: isNsfw,
      communitySlug: communitySlug,
      images: images,
    );

    if (result != null && mounted) {
      Navigator.pop(context);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hejtter'),
        backgroundColor: backgroundColor,
        actions: [_buildSearchButton(context)],
      ),
      drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
      floatingActionButton: _buildNewPostFAB(),
      body: PostsTabView(
        showSearchBar: _showSearchBar,
        focusNode: focusNode,
      ),
    );
  }

  Widget _buildNewPostFAB() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return FloatingActionButton(
            onPressed: _openAddPostDialog,
            child: const Icon(Icons.add),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  _openAddPostDialog() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AddPostScreen(addPost: _addPost);
    }));

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.black,
    //   builder: (BuildContext context) {
    //     return SizedBox(
    //       child: SingleChildScrollView(
    //           child: Container(
    //         padding: EdgeInsets.only(
    //           bottom: MediaQuery.of(context).viewInsets.bottom,
    //           top: MediaQuery.of(context).viewInsets.top,
    //         ),
    //         child: AddPostDialog(addPost: _addPost),
    //       )),
    //     );
    //   },
    // );
  }

  IconButton _buildSearchButton(BuildContext context) {
    return IconButton(
      onPressed: (() {
        setState(() {
          _showSearchBar = !_showSearchBar;
          searchCubit.changeString('');

          if (_showSearchBar) {
            FocusScope.of(context).requestFocus(focusNode);
          } else {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        });
      }),
      icon: Icon(_showSearchBar ? Icons.search_off : Icons.search),
    );
  }
}
