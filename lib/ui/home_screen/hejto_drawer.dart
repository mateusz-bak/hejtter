import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/ui/followed_page/followed_screen.dart';
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
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthorizedAuthState) {
                return ListTile(
                  title: const Text('Obserwowane'),
                  onTap: () {
                    if (currentScreen == CurrentScreen.home) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FollowedScreen(),
                        ),
                      );
                    } else if (currentScreen == CurrentScreen.communities) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FollowedScreen(),
                        ),
                      );
                    } else if (currentScreen == CurrentScreen.followed) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const FollowedScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          const Expanded(
            child: SizedBox(),
          ),
          _buildLoginLogoutTile(),
          ListTile(
            title: const Text('Ustawienia'),
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
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    height: 50,
                    width: 50,
                    imageUrl: avatar ?? defaultAvatar,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
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
