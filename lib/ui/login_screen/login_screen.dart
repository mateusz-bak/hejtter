import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final client = http.Client();

  _changeLoadingStatus(bool status) {
    setState(() {
      _isLoading = status;
    });
  }

  Future _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _changeLoadingStatus(true);

    var responseProviders = await _getProviders();

    var responseCSRF = await _getCSRF();

    var responseCredentials = await _postCredentials(
      jsonDecode(responseCSRF.body)['csrfToken'],
    );

    var responseSession = await _getSession();

    _changeLoadingStatus(false);

    return;
  }

  Future<http.Response> _getProviders() async {
    final response = await client.get(
      Uri.https(
        'hejto.pl',
        '/api/auth/providers',
      ),
    );

    print('responseProviders: ${response.body}');
    print('responseProviders.headers: ${response.headers}');
    print(
        'responseProviders.headers["set-cookie"]: ${response.headers['set-cookie']}');

    return response;
  }

  Future<http.Response> _getCSRF() async {
    final response = await client.get(
      Uri.https(
        'hejto.pl',
        '/api/auth/csrf',
      ),
    );

    print('responseCSRF: ${response.body}');
    print('responseCSRF.headers: ${response.headers}');
    print(
        'responseCSRF.headers["set-cookie"]: ${response.headers['set-cookie']}');

    return response;
  }

  Future<http.Response> _postCredentials(String csrfToken) async {
    final queryParameters = {
      'username': 'SluchamPsaJakGra',
      'password': 'dddddddddd',
      'redirect': 'false',
      'json': 'true',
      'callbackUrl':
          'https%3A%2F%2Fwww.hejto.pl%2Fwpis%2Fczolem-kasie-i-tomki-wlasnie-wydalem-wersje-0-0-2-hejttera-niestety-dalej-bez-lo',
      'csrfToken': csrfToken,
    };

    var body = json.encode(queryParameters);

    var response = await client.post(
      Uri.https(
        'hejto.pl',
        '/api/auth/callback/credentials',
      ),
      body: body,
    );

    print('responseCredentials: ${response.body}');
    print('responseCredentials.headers: ${response.headers}');
    print(
        'responseCredentials.headers["set-cookie"]: ${response.headers['set-cookie']}');

    return response;
  }

  Future<http.Response> _getSession() async {
    var response = await client.get(
      Uri.https(
        'hejto.pl',
        '/api/auth/session',
      ),
    );

    print('responseSession: ${response.body}');
    print('responseSession.headers: ${response.headers}');
    print(
        'responseSession.headers["set-cookie"]: ${response.headers['set-cookie']}');

    return response;
  }

  _skipLogin() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
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
                // autofocus: true,
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
                decoration: const InputDecoration.collapsed(
                  hintText: 'Hasło',
                ),
                onSubmitted: (_) {
                  _login();
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
                    onPressed: _login,
                    child: _isLoading
                        ? Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                            size: 24,
                            color: Colors.white,
                          ))
                        : const Text('Zaloguj się'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _skipLogin,
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
