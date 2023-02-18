import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/settings_screen/deep_links_dialog.dart';
import 'package:hejtter/ui/settings_screen/default_period_dialog.dart';
import 'package:hejtter/ui/settings_screen/default_tab_dialog.dart';
import 'package:hejtter/ui/settings_screen/settings_section.dart';
import 'package:hejtter/ui/settings_screen/switch_setting.dart';
import 'package:hejtter/ui/settings_screen/text_setting.dart';
import 'package:hejtter/utils/enums.dart';

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

  _unblockUserLocally({
    required String? username,
    required List<String> currentList,
  }) async {
    if (username == null) return;

    currentList.removeWhere((element) {
      return element == username;
    });

    if (currentList.isEmpty) {
      BlocProvider.of<ProfileBloc>(context).add(
        const UpdateUnloggedBlocksProfileEvent(),
      );
    } else {
      BlocProvider.of<ProfileBloc>(context).add(
        UpdateUnloggedBlocksProfileEvent(usernames: currentList),
      );
    }
  }

  String _decideDefaultPageSubtitle(HejtoPage hejtoPage) {
    switch (hejtoPage) {
      case HejtoPage.articles:
        return 'Artykuły';
      case HejtoPage.discussions:
        return 'Dyskusje';
      default:
        return 'Artykuły';
    }
  }

  String _decideDefaultHotPeriodSubtitle(PostsPeriod defaultPeriod) {
    switch (defaultPeriod) {
      case PostsPeriod.threeHours:
        return '3h';
      case PostsPeriod.sixHours:
        return '6h';
      case PostsPeriod.twelveHours:
        return '12h';
      case PostsPeriod.twentyFourHours:
        return '24h';
      default:
        return '6h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ustawienia',
          style: TextStyle(fontSize: 20),
        ),
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
                            color: Theme.of(context).colorScheme.primary,
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
                _buildUnloggedBlacklist(),
                const SettingsSection(
                  title: 'Aplikacja',
                  leading: Icons.tune,
                ),
                BlocBuilder<PreferencesBloc, PreferencesState>(
                  builder: (context, state) {
                    if (state is PreferencesSet) {
                      return TextSetting(
                        title: 'Strona początkowa',
                        subtitle: _decideDefaultPageSubtitle(state.defaultPage),
                        onPressed: (() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DefaultTabDialog(state: state);
                            },
                          );
                        }),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                BlocBuilder<PreferencesBloc, PreferencesState>(
                  builder: (context, state) {
                    if (state is PreferencesSet) {
                      return TextSetting(
                        title: 'Domyślny okres gorących',
                        subtitle: _decideDefaultHotPeriodSubtitle(
                          state.defaultHotPeriod,
                        ),
                        onPressed: (() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DefaultPeriodDialog(state: state);
                            },
                          );
                        }),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                TextSetting(
                  title: 'Otwieraj linki w aplikacji',
                  subtitle: 'Kliknij, żeby wyświetlić poradę',
                  onPressed: () {
                    final state = context.read<PreferencesBloc>().state;

                    if (state is PreferencesSet) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DeepLinksDialog(state: state);
                        },
                      );
                    }
                  },
                ),
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

  Widget _buildUnloggedBlacklist() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileAbsentState && state.blockedUsers != null) {
          final blockedUsers = List<Widget>.empty(growable: true);

          for (var user in state.blockedUsers!) {
            blockedUsers.add(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(user),
                TextButton(
                  onPressed: () => _unblockUserLocally(
                    currentList: state.blockedUsers!,
                    username: user,
                  ),
                  child: const Text('Odblokuj'),
                )
              ],
            ));
          }

          return TextSetting(
            title: 'Zablokowani użytkownicy',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('Zablokowani użytkownicy'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: blockedUsers,
                        ),
                      )
                    ],
                  );
                },
              );
            },
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
