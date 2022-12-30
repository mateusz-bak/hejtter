import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
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

  var cookieJar = CookieJar();
  var client = HttpClient();

  _changeLoadingStatus(bool status) {
    setState(() {
      _isLoading = status;
    });
  }

  Future _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _changeLoadingStatus(true);

    await _getProviders();

    final csrfToken = await _getCSRFToken();
    await _postCredentials(csrfToken);
    await _getSession();

    _changeLoadingStatus(false);

    return;
  }

  Future<dynamic> _getProviders() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/providers',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
        Uri.https('www.hejto.pl'), response.cookies);

    print('_getProviders.stringData: $stringData');

    return stringData;
  }

  Future<dynamic> _getCSRFToken() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/csrf',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
        Uri.https('www.hejto.pl'), response.cookies);

    print('_getCSRF.stringData: $stringData');

    final token = jsonDecode(stringData)['csrfToken'];
    print('csrfToken: $token');

    return token;
  }

  Future<dynamic> _postCredentials(String csrfToken) async {
    const username = 'username';
    const pass = 'password';

    final body = {
      'username': username,
      'password': pass,
      'redirect': 'false',
      'json': 'true',
      'callbackUrl':
          'https://www.hejto.pl/wpis/czolem-kasie-i-tomki-wlasnie-wydalem-wersje-0-0-2-hejttera-niestety-dalej-bez-lo',
      'csrfToken': csrfToken,
    };

    HttpClientRequest request = await client.postUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/callback/credentials',
      ),
    );

    final cookies = await cookieJar.loadForRequest(
      Uri.https('www.hejto.pl'),
    );
    print('cookies: ${cookies}');
    request.cookies.addAll(cookies);

    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(body)));

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    final headers = response.headers;

    await cookieJar.saveFromResponse(
        Uri.https('www.hejto.pl'), response.cookies);

    print('_postCredentials.stringData: $stringData');
    print('_postCredentials.headers: $headers');

    return stringData;
  }

  Future<dynamic> _getSession() async {
    HttpClientRequest request = await client.getUrl(
      Uri.https(
        'www.hejto.pl',
        '/api/auth/session',
      ),
    );

    request.cookies.addAll(
      await cookieJar.loadForRequest(
        Uri.https('www.hejto.pl'),
      ),
    );

    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();

    await cookieJar.saveFromResponse(
        Uri.https('www.hejto.pl'), response.cookies);

    print('_getSession.stringData: $stringData');
    print('_getSession.headers: ${response.headers}');

    return stringData;
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
