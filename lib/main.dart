import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

late FlutterSecureStorage secureStorage;
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS has problems with high refresh rate - update to latest flutter *MAY* fix it according to info I found
  if (Platform.isAndroid) {
    await FlutterDisplayMode.setHighRefreshRate();
  }

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  FlutterDownloader.registerCallback(DownloadCallback.callback);

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  AndroidOptions getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  secureStorage = FlutterSecureStorage(aOptions: getAndroidOptions());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthorizedAuthState || state is LoginSkippedAuthState) {
            if (state is AuthorizedAuthState) {
              BlocProvider.of<ProfileBloc>(context).add(
                SetProfileEvent(context: context),
              );
            }

            return MaterialApp(
              home: const HomeScreen(),
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
        },
      ),
    ),
  );
}

class DownloadCallback {
  static void callback(String id, DownloadTaskStatus status, int progress) {}
}
