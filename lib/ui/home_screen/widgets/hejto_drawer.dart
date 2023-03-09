import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/ui/community_screen/community_screen.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/home_screen/widgets/widgets.dart';
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
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            ..._buildTopDestinations(),
            const Spacer(),
            ..._buildBottomDestinations(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  DrawerHeader _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: backgroundSecondaryColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
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
              appName,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(letterSpacing: 4),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildTopDestinations() {
    return [
      DrawerDestination(
        icon: const Icon(Icons.newspaper),
        text: 'Strona główna',
        current: widget.currentScreen == CurrentScreen.home,
        onTap: () {
          if (widget.currentScreen == CurrentScreen.communities) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      DrawerDestination(
        icon: const Icon(Icons.people),
        text: 'Społeczności',
        current: widget.currentScreen == CurrentScreen.communities,
        onTap: () {
          if (widget.currentScreen == CurrentScreen.home) {
            Navigator.of(context).pop();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CommunitiesScreen(),
              ),
            );
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    ];
  }

  List<Widget> _buildBottomDestinations() {
    return [
      DrawerDestination(
        text: 'Społeczność Hejtter',
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
        onTap: () {
          Navigator.of(context).pop();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityScreen(
                communitySlug: hejtterCommunitySlug,
              ),
            ),
          );
        },
      ),
      DrawerDestination(
        text: 'Ustawienia',
        icon: const Icon(Icons.settings),
        onTap: () {
          Navigator.of(context).pop();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
      ),
      BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthorizedAuthState) {
            return DrawerDestination(
              text: 'Wyloguj się',
              icon: const Icon(Icons.logout),
              current: false,
              onTap: () {
                _clearPresentLogin();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            );
          } else {
            return DrawerDestination(
              text: 'Zaloguj się',
              icon: const Icon(Icons.login),
              current: false,
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
      ),
    ];
  }
}
