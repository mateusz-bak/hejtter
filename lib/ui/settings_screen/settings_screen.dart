import 'package:animated_widgets/animated_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';

import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/ui/observed_screen/observed_screen.dart';
import 'package:hejtter/ui/settings_screen/widgets/widgets.dart';
import 'package:hejtter/utils/constants.dart';
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
        return 'Wszystko';
    }
  }

  String _decideDefaultPostsCategorySubtitle(PostsCategory postsCategory) {
    switch (postsCategory) {
      case PostsCategory.hotThreeHours:
        return 'Gorące 3h';
      case PostsCategory.hotSixHours:
        return 'Gorące 6h';
      case PostsCategory.hotTwelveHours:
        return 'Gorące 12h';
      case PostsCategory.hotTwentyFourHours:
        return 'Gorące24h';
      case PostsCategory.topSevenDays:
        return 'Top 7 dni';
      case PostsCategory.topThirtyDays:
        return 'Top 30 dni';
      case PostsCategory.all:
        return 'Najnowsze';
      case PostsCategory.followed:
        return 'Obserwowane';
      default:
        return '6h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        title: const Text(
          'Ustawienia',
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(children: [
                _buildDonate(),
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
                        title: 'Domyślny typ wpisów',
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
                        title: 'Domyślny widok postów',
                        subtitle: _decideDefaultPostsCategorySubtitle(
                          state.defaultPostsCategory,
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
            _showNsfwLoading || _blurNsfwLoading || _showControversialLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                            decoration: BoxDecoration(
                              color: backgroundSecondaryColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: dividerColor),
                            ),
                            child: LoadingAnimationWidget.threeArchedCircle(
                              color: boltColor,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20)
                    ],
                  )
                : const SizedBox(),
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
              _buildObservedTags(),
              _buildBlockedTags(),
              _buildObservedCommunities(),
              _buildBlockedCommunities(),
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

  Widget _buildDonate() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            builder: (context) {
              return const DonateModal();
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: backgroundSecondaryColor,
            border: Border.all(color: dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: const Text(
              'Donate dla developera aplikacji',
            ),
            leading: ShakeAnimatedWidget(
              duration: const Duration(seconds: 2),
              shakeAngle: Rotation.deg(z: 30),
              curve: Curves.bounceInOut,
              child: const Icon(
                FontAwesomeIcons.sackDollar,
                color: boltColor,
                size: 28,
              ),
            ),
          ),
        ),
      ),
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
                if (_showNsfwLoading) {
                  return;
                }

                _changeShowNsfwPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Pokazuj wpisy NSFW',
              value: false,
              onChanged: (value) {
                if (_showNsfwLoading) {
                  return;
                }

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
                if (_blurNsfwLoading) {
                  return;
                }
                _changeBlurNsfwPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Rozmazuj obrazy NSFW',
              value: false,
              onChanged: (value) {
                if (_blurNsfwLoading) {
                  return;
                }

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
                if (_showControversialLoading) {
                  return;
                }

                _changeShowControversialPref(value, state);
              },
            );
          } else {
            return SwitchSetting(
              title: 'Pokazuj wpisy kontrowersyjne',
              value: false,
              onChanged: (value) {
                if (_showControversialLoading) {
                  return;
                }

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

  Widget _buildObservedTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const ObservedScreen(
              getTags: true,
            );
          }));
        },
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Pokaż obserwowane tagi',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedTags() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const ObservedScreen(
              getBlockedTags: true,
            );
          }));
        },
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Pokaż zablokowane tagi',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildObservedCommunities() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const ObservedScreen(
              getCommunities: true,
            );
          }));
        },
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Pokaż Twoje społeczności',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedCommunities() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 16, 16, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const ObservedScreen(
              getBlockedCommunities: true,
            );
          }));
        },
        child: Row(
          children: const [
            Expanded(
              child: Text(
                'Pokaż zablokowane społeczności',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
