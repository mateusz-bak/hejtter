import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/settings_screen/settings_screen.dart';
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

  List<NavigationDrawerDestination> _prepareTopDestinations() {
    return [
      const NavigationDrawerDestination(
        label: Text('Strona główna'),
        icon: Icon(Icons.newspaper),
        selectedIcon: Icon(Icons.newspaper, color: boltColor),
      ),
      const NavigationDrawerDestination(
        label: Text('Społeczności'),
        icon: Icon(Icons.people),
        selectedIcon: Icon(Icons.people, color: boltColor),
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
                imageUrl: hejtterAvatar,
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
            builder: (context) => const CommunityScreen(
              communitySlug: 'hejtter',
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    topDestinations = _prepareTopDestinations();
    bottomDestinations = _prepareBottomDestinations();

    return NavigationDrawer(
      selectedIndex: _decideSelectedIndex(),
      onDestinationSelected: _changeDestination,
      backgroundColor: backgroundColor,
      children: [
        _buildHeader(context),
        const SizedBox(height: 32),
        ...topDestinations,
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 32, 28, 0),
          child: Divider(),
        ),
        ...bottomDestinations,
      ],
    );
  }

  DrawerHeader _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: backgroundSecondaryColor),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              appLogoAsset,
              fit: BoxFit.cover,
              height: 80,
              width: 80,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Hejtter',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          )
        ],
      ),
    );
  }
}
