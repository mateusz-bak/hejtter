import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hejtter/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();
  
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      theme: ThemeData.dark(),
    ),
  );
}
