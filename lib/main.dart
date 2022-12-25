import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hejtter/home_screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  FlutterDownloader.registerCallback(DownloadCallback.callback);

  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: const Color(0xff2295F3),
      ),
    ),
  );
}

class DownloadCallback {
  static void callback(String id, DownloadTaskStatus status, int progress) {}
}
