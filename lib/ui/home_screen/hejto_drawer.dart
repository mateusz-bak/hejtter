import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/communities_screen/communities_screen.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hejtter/ui/user_screen/user_screen.dart';
import 'package:hejtter/utils/constants.dart';
import 'package:hejtter/utils/enums.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HejtoDrawer extends StatelessWidget {
  const HejtoDrawer({
    super.key,
    required this.currentScreen,
  });

  final CurrentScreen currentScreen;

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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
              } else if (currentScreen == CurrentScreen.communities) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const CommunitiesScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
          _buildLoginLogoutTile(),
          const Expanded(
            child: SizedBox(),
          ),
          ListTile(
            title: const Text('Github'),
            onTap: () {
              launchUrl(
                Uri.parse('https://github.com/mateusz-bak/hejtter'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          FutureBuilder(
            future: _getAppVersion(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  title: Text(snapshot.data.toString()),
                  onTap: () {},
                );
              } else {
                return const SizedBox();
              }
            },
          ),
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
            title: const Text('Zaloguj się w aplikacji'),
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
        const defaultAvatarUrl =
            'https://www.hejto.pl/_next/image?url=https%3A%2F%2Fhejto-media.s3.eu-central-1.amazonaws.com%2Fassets%2Fimages%2Fdefault-avatar-new.png&w=2048&q=75';

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
                    imageUrl:
                        avatar != null ? avatar.toString() : defaultAvatarUrl,
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
