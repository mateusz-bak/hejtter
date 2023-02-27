import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hejtter/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:hejtter/logic/bloc/preferences_bloc/preferences_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/home_screen/home_screen.dart';
import 'package:hejtter/ui/settings_screen/deep_links_dialog.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  bool _loginError = false;
  bool _passwordVisible = false;

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

            BlocProvider.of<ProfileBloc>(context).add(
              SetProfileEvent(context: context),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
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
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
          );
        },
      ),
    );
  }

  _showDialog() async {
    await Future.delayed(const Duration(milliseconds: 50));

    // ignore: use_build_context_synchronously
    final state = context.read<PreferencesBloc>().state;

    if (state is PreferencesSet) {
      if (!state.deepLinkDialogDisplayed) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DeepLinksDialog(state: state);
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _showDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                        'Mobilna aplikacja serwisu Hejto.pl tworzona przez społeczność',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            AutofillGroup(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: _emailController,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Email / Login',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                          hintText: 'Hasło',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          )),
                      onSubmitted: (_) {
                        _loading ? null : _login(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _loading ? null : () => _login(context),
                    child: _loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: Center(
                              child: LoadingAnimationWidget.fourRotatingDots(
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
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
