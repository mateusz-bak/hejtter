import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';

import 'package:hejtter/logic/cubit/search_cubit.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/models/photo_to_upload.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/add_post_screen/add_post_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/hejto_drawer.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/notifications_screen/notifications_screen.dart';
import 'package:hejtter/ui/post_screen/post_screen.dart';
import 'package:hejtter/ui/posts_screen/posts_tab_view.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    this.navigateToPost,
    this.navigateToUser,
    this.navigateToCommunity,
  });

  String? navigateToPost;
  String? navigateToUser;
  String? navigateToCommunity;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FocusNode focusNode = FocusNode();
  var _showSearchBar = false;
  int bottomNavBarIndex = 0;
  int _notificationsCounter = 0;

  Future<String?> _addPost(
    String content,
    bool isNsfw,
    String communitySlug,
    List<PhotoToUpload>? images,
  ) async {
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

  _openPostFromDeepLink() async {
    await Future.delayed(const Duration(milliseconds: 0));

    if (widget.navigateToPost != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(
            slug: widget.navigateToPost,
          ),
        ),
      );
    } else if (widget.navigateToUser != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserScreen(
            userName: widget.navigateToUser,
          ),
        ),
      );
    } else if (widget.navigateToCommunity != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CommunityScreen(
            community: Community(name: widget.navigateToCommunity),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _openPostFromDeepLink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (bottomNavBarIndex == 1) {
              setState(() {
                bottomNavBarIndex = 0;
              });
              return false;
            }

            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                bottomNavBarIndex == 0
                    ? 'Dyskusje'
                    : bottomNavBarIndex == 1
                        ? 'Powiadomienia'
                        : '',
                style: const TextStyle(fontSize: 18),
              ),
              backgroundColor: backgroundColor,
              actions:
                  bottomNavBarIndex == 0 ? [_buildSearchButton(context)] : null,
            ),
            drawer: const HejtoDrawer(currentScreen: CurrentScreen.home),
            floatingActionButton: bottomNavBarIndex == 0
                ? _buildNewPostFAB()
                : _buildReadNotificationsFAB(),
            body: bottomNavBarIndex == 0
                ? PostsTabView(
                    showSearchBar: _showSearchBar,
                    focusNode: focusNode,
                    showFollowedTab: state is ProfilePresentState,
                  )
                : bottomNavBarIndex == 1
                    ? NotificationsScreen(updateCounter: (newValue) {
                        setState(() {
                          _notificationsCounter = newValue;
                        });
                      })
                    : const SizedBox(),
            bottomNavigationBar: _buildBottomNavigationBar(state, context),
          ),
        );
      },
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(
      ProfileState state, BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      currentIndex: bottomNavBarIndex,
      onTap: (value) {
        switch (value) {
          case 0:
            setState(() {
              bottomNavBarIndex = value;
            });
            break;
          case 1:
            if (state is ProfilePresentState) {
              setState(() {
                bottomNavBarIndex = value;
              });
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return const LoginScreen();
              }));
            }
        }
      },
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.reorder),
          label: 'Wpisy',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              _notificationsCounter != 0
                  ? Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          _notificationsCounter.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          label: 'Powiadomienia',
        ),
      ],
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

  Widget _buildReadNotificationsFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        await hejtoApi.markAllNotificationsAsRead(context: context);
      },
      isExtended: true,
      icon: const Icon(Icons.task_alt),
      label: const Text('Odczytaj wszystkie'),
    );
  }

  _openAddPostDialog() {
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return AddPostScreen(addPost: _addPost);
    }));
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
