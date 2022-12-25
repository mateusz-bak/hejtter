import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(),
      ),
    );
  }
}
