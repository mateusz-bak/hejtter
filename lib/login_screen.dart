import 'package:flutter/material.dart';
import 'package:hejtter/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLogin ? const Text('Login') : const Text('Register'),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
            !_isLogin
                ? TextField(
                    controller: _passwordRepeatController,
                    decoration: const InputDecoration(
                      hintText: 'Repeat your password',
                    ),
                    obscureText: true,
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            ElevatedButton(
              child: _isLogin ? const Text('Login') : const Text('Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  HomeScreen(),
                  ),
                );
              },
            ),
            TextButton(
              child: _isLogin
                  ? const Text('Don\'t have an account? Register')
                  : const Text('Already have an account? Login'),
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
