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

class HejtoDrawer extends StatefulWidget {
  const HejtoDrawer({
    super.key,
    required this.currentScreen,
  });

  final CurrentScreen currentScreen;

  @override
  State<HejtoDrawer> createState() => _HejtoDrawerState();
}

class _HejtoDrawerState extends State<HejtoDrawer> {
  late List<Widget> topDestinations;
  late List<Widget> bottomDestinations;

  @override
  void initState() {
    super.initState();
  }

  List<NavigationDrawerDestination> _prepareTopDestinations() {
    final primary = Theme.of(context).colorScheme.primary;

    return [
      NavigationDrawerDestination(
        label: const Text('Strona główna'),
        icon: const Icon(Icons.newspaper),
        selectedIcon: Icon(Icons.newspaper, color: primary),
      ),
      NavigationDrawerDestination(
        label: const Text('Społeczności'),
        icon: const Icon(Icons.people),
        selectedIcon: Icon(Icons.people, color: primary),
      ),
    ];
  }

  List<NavigationDrawerDestination> _prepareBottomDestinations() {
    return [
      NavigationDrawerDestination(
        label: const Text('Społeczność Hejtter'),
        icon: ClipRRect(
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
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      ),
      const NavigationDrawerDestination(
        label: Text('Ustawienia'),
        icon: Icon(Icons.settings),
      ),
      NavigationDrawerDestination(
        label: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthorizedAuthState) {
              return const Text('Wyloguj się');
            } else {
              return const Text('Zaloguj się');
            }
          },
        ),
        icon: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthorizedAuthState) {
              return const Icon(Icons.logout);
            } else {
              return const Icon(Icons.login);
            }
          },
        ),
      ),
    ];
  }

  int? _decideSelectedIndex() {
    if (widget.currentScreen == CurrentScreen.home) {
      return 0;
    } else if (widget.currentScreen == CurrentScreen.communities) {
      return 1;
    }

    return null;
  }

  _changeDestination(value) {
    switch (value) {
      case 0:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
        break;
      case 1:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CommunitiesScreen()),
          (Route<dynamic> route) => false,
        );
        break;
      case 2:
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
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
      case 4:
        if (context.read<AuthBloc>().state is AuthorizedAuthState) {
          _clearPresentLogin();

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (Route<dynamic> route) => false,
          );
        }

        break;
    }
  }

  _clearPresentLogin() {
    BlocProvider.of<AuthBloc>(context).add(
      const LogOutAuthEvent(),
    );

    BlocProvider.of<ProfileBloc>(context).add(
      const ClearProfileEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    topDestinations = _prepareTopDestinations();
    bottomDestinations = _prepareBottomDestinations();

    return NavigationDrawer(
      selectedIndex: _decideSelectedIndex(),
      onDestinationSelected: _changeDestination,
      children: [
        _buildUserHeader(),
        ...topDestinations,
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Divider(),
        ),
        ...bottomDestinations,
      ],
    );
  }

  BlocBuilder<ProfileBloc, ProfileState> _buildUserHeader() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          final avatar = state.avatar;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 12, 0),
                child: GestureDetector(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(1),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              height: 80,
                              width: 80,
                              imageUrl: avatar ?? defaultAvatar,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.username,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, 16),
                child: Divider(),
              ),
            ],
          );
        } else {
          return const SizedBox(height: 64);
        }
      },
    );
  }
}
