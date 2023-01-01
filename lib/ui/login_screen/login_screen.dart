import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/auth_bloc.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _loginError = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  _changeLoadingStatus(bool status) {
    setState(() {
      _loading = status;
    });
  }

  Future _login(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    _changeLoadingStatus(true);

    BlocProvider.of<AuthBloc>(context).add(
      LogInAuthEvent(
          username: _emailController.text,
          password: _passwordController.text,
          onSuccess: () {
            _changeLoadingStatus(false);

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (Route<dynamic> route) => false,
            );
          },
          onFailure: () {
            _changeLoadingStatus(false);

            _loginError = true;
          }),
    );

    return;
  }

  _skipLogin(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    BlocProvider.of<AuthBloc>(context).add(
      SkipLoginAuthEvent(
        onSuccess: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hejtter',
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'mobilna aplikacja serwisu Hejto.pl tworzona przez społeczność',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff2295F3).withAlpha(30),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Email',
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff2295F3).withAlpha(30),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                obscureText: true,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Hasło',
                ),
                onSubmitted: (_) {
                  _loading ? null : _login(context);
                },
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2295F3),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loading ? null : () => _login(context),
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const Text('Zaloguj się'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                TextButton(
                  onPressed: (() => _skipLogin(context)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kontynuuj bez logowania'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}