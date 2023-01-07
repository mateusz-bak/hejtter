import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/settings_screen/settings_section.dart';
import 'package:hejtter/ui/settings_screen/switch_setting.dart';
import 'package:hejtter/ui/settings_screen/text_setting.dart';
import 'package:hejtter/utils/constants.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showNsfwLoading = false;
  bool _blurNsfwLoading = false;
  bool _showControversialLoading = false;

  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  _changeShowNsfwPref(bool value, ProfilePresentState state) async {
    setState(() {
      _showNsfwLoading = true;
    });

    final result = await hejtoApi.updateAccountSettings(
      context: context,
      current: state,
      showNsfw: value,
    );

    if (result) {
      BlocProvider.of<ProfileBloc>(context).add(
        SetProfileEvent(context: context),
      );
    }

    setState(() {
      _showNsfwLoading = false;
    });
  }

  _changeBlurNsfwPref(bool value, ProfilePresentState state) async {
    setState(() {
      _blurNsfwLoading = true;
    });

    final result = await hejtoApi.updateAccountSettings(
      context: context,
      current: state,
      blurNsfw: value,
    );

    if (result) {
      BlocProvider.of<ProfileBloc>(context).add(
        SetProfileEvent(context: context),
      );
    }

    setState(() {
      _blurNsfwLoading = false;
    });
  }

  _changeShowControversialPref(bool value, ProfilePresentState state) async {
    setState(() {
      _showControversialLoading = true;
    });

    final result = await hejtoApi.updateAccountSettings(
      context: context,
      current: state,
      showControversial: value,
    );

    if (result) {
      BlocProvider.of<ProfileBloc>(context).add(
        SetProfileEvent(context: context),
      );
    }

    setState(() {
      _showControversialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ustawienia'),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            _showNsfwLoading || _blurNsfwLoading || _showControversialLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: primaryColor,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20)
                    ],
                  )
                : const SizedBox(),
            SingleChildScrollView(
              child: Column(children: [
                _buildAccountPreferences(),
                const SettingsSection(
                  title: 'O aplikacji',
                  leading: Icons.smartphone,
                ),
                TextSetting(
                  title: 'Kod źródłowy',
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://github.com/mateusz-bak/hejtter'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                _buildAppVersion(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return FutureBuilder(
      future: _getAppVersion(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return TextSetting(
            title: snapshot.data,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildAccountPreferences() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          return Column(
            children: [
              const SettingsSection(
                title: 'Konto',
                leading: Icons.person,
              ),
              _buildShowNSFW(),
              _buildBlurNSFW(),
              _buildShowControversial(),
              const SizedBox(height: 20),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildShowNSFW() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          if (state.showNsfw) {
            return SwitchSetting(
              title: 'Pokazuj wpisy NSFW',
              value: true,
              onChanged: (value) {
                _changeShowNsfwPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Pokazuj wpisy NSFW',
              value: false,
              onChanged: (value) {
                _changeShowNsfwPref(value, state);
              },
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildBlurNSFW() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          if (state.blurNsfw) {
            return SwitchSetting(
              title: 'Rozmazuj obrazy NSFW',
              value: true,
              onChanged: (value) {
                _changeBlurNsfwPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Rozmazuj obrazy NSFW',
              value: false,
              onChanged: (value) {
                _changeBlurNsfwPref(value, state);
              },
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildShowControversial() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfilePresentState) {
          if (state.showControversial) {
            return SwitchSetting(
              title: 'Pokazuj wpisy kontrowersyjne',
              value: true,
              onChanged: (value) {
                _changeShowControversialPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Pokazuj wpisy kontrowersyjne',
              value: false,
              onChanged: (value) {
                _changeShowControversialPref(value, state);
              },
            );
          }
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
