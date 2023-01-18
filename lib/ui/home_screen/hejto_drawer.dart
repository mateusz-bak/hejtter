import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/models/avatar.dart';
import 'package:hejtter/models/background.dart';
import 'package:hejtter/models/communities_response.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/settings_screen/settings_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';

class HejtoDrawer extends StatelessWidget {
  const HejtoDrawer({
    super.key,
    required this.currentScreen,
  });

  final CurrentScreen currentScreen;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ),
                ),
                const SizedBox(width: 20),
                const Text(
                  'Hejtter',
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          _buildUserTile(),
          ListTile(
            title: const Text('Strona główna'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          ListTile(
            title: const Text('Społeczności'),
            onTap: () {
              if (currentScreen == CurrentScreen.home) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunitiesScreen(),
                  ),
                );
              } else if (currentScreen == CurrentScreen.followed) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunitiesScreen(),
                  ),
                );
              } else if (currentScreen == CurrentScreen.communities) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const CommunitiesScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
          const Expanded(
            child: SizedBox(),
          ),
          ListTile(
            title: const Text('Społeczność Hejtter'),
            leading: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      height: 22,
                      width: 22,
                      imageUrl:
                          'https://hejto-media.s3.eu-central-1.amazonaws.com/uploads/communities/images/avatars/250x250/c9dc19226b6dd04bd625960dedbb41d0.png',
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityScreen(
                    community: Community(
                      slug: 'Hejtter',
                      name: 'Hejtter',
                      avatar: Avatar(
                        urls: AvatarUrls(
                          the250X250:
                              'https://hejto-media.s3.eu-central-1.amazonaws.com/uploads/communities/images/avatars/250x250/c9dc19226b6dd04bd625960dedbb41d0.png',
                        ),
                      ),
                      background: Background(
                        urls: BackgroundUrls(
                          the1200X900:
                              'https://hejto-media.s3.eu-central-1.amazonaws.com/uploads/communities/images/backgrounds/1200x900/d07ab812a674241079adeb90b06b4879.jpg',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildLoginLogoutTile(),
          ListTile(
            title: const Text('Ustawienia'),
            leading: const Icon(Icons.settings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  BlocBuilder<AuthBloc, AuthState> _buildLoginLogoutTile() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthorizedAuthState) {
          return ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Wyloguj się'),
            onTap: () {
              BlocProvider.of<AuthBloc>(context).add(
                const LogOutAuthEvent(),
              );

              BlocProvider.of<ProfileBloc>(context).add(
                const ClearProfileEvent(),
              );

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          );
        } else {
          return ListTile(
            title: const Text('Zaloguj się'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          );
        }
      },
    );
  }

  BlocBuilder<ProfileBloc, ProfileState> _buildUserTile() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          final avatar = state.avatar;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(1),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        height: 42,
                        width: 42,
                        imageUrl: avatar ?? defaultAvatar,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                state.username,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserScreen(
                      userName: state.username,
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
