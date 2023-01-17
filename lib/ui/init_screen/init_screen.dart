import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/main.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:uni_links/uni_links.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  Uri? _initialURI;
  Uri? _currentURI;
  Object? _err;

  StreamSubscription? _streamSubscription;

  Future<bool> _initURIHandler() async {
    if (!initialURILinkHandled) {
      initialURILinkHandled = true;

      try {
        final initialURI = await getInitialUri();

        if (initialURI != null) {
          if (!mounted) {
            return false;
          }

          setState(() {
            _initialURI = initialURI;
          });

          return true;
        }
      } on FormatException catch (err) {
        if (!mounted) {
          return false;
        }
        setState(() => _err = err);
      }
    }

    return false;
  }

  // void _incomingLinkHandler() {

  //   _streamSubscription = uriLinkStream.listen((Uri? uri) {
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       _currentURI = uri;
  //       _err = null;
  //     });
  //   }, onError: (Object err) {
  //     if (!mounted) {
  //       return;
  //     }
  //     setState(() {
  //       _currentURI = null;
  //       if (err is FormatException) {
  //         _err = err;
  //       } else {
  //         _err = null;
  //       }
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return FutureBuilder(
          future: _initURIHandler(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              // _incomingLinkHandler();

              if (snapshot.data!) {
                final string = _initialURI.toString();
                final splittedString = string.split('/');
                final type = splittedString[splittedString.length - 2];
                final slug = splittedString.last;

                if (type == 'wpis') {
                  return MaterialApp(
                    home: HomeScreen(navigateToPost: slug),
                    theme: ThemeData.dark(useMaterial3: true).copyWith(
                      primaryColor: const Color(0xff2295F3),
                    ),
                  );
                } else if (type == 'uzytkownik') {
                  return MaterialApp(
                    home: HomeScreen(navigateToUser: slug),
                    theme: ThemeData.dark(useMaterial3: true).copyWith(
                      primaryColor: const Color(0xff2295F3),
                    ),
                  );
                } else if (type == 'spolecznosc') {
                  return MaterialApp(
                    home: HomeScreen(navigateToCommunity: slug),
                    theme: ThemeData.dark(useMaterial3: true).copyWith(
                      primaryColor: const Color(0xff2295F3),
                    ),
                  );
                }
              }

              if (state is AuthorizedAuthState ||
                  state is LoginSkippedAuthState) {
                if (state is AuthorizedAuthState) {
                  BlocProvider.of<ProfileBloc>(context).add(
                    SetProfileEvent(context: context),
                  );
                }

                return MaterialApp(
                  home: HomeScreen(),
                  theme: ThemeData.dark(useMaterial3: true).copyWith(
                    primaryColor: const Color(0xff2295F3),
                  ),
                );
              } else {
                return MaterialApp(
                  home: const LoginScreen(),
                  scaffoldMessengerKey: snackbarKey,
                  theme: ThemeData.dark(useMaterial3: true).copyWith(
                    primaryColor: const Color(0xff2295F3),
                  ),
                );
              }
            } else {
              return const SizedBox();
            }
          },
        );
      },
    );
  }
}
