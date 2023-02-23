import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hejtter/logic/bloc/profile_bloc/profile_bloc.dart';
import 'package:hejtter/ui/login_screen/login_screen.dart';

class AnswerButton extends StatelessWidget {
  const AnswerButton({
    super.key,
    this.isSmaller = false,
    required this.respondToUser,
    required this.username,
  });
  final bool isSmaller;
  final Function(String?) respondToUser;
  final String? username;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      onPressed: () {
        if (context.read<ProfileBloc>().state is ProfilePresentState) {
          respondToUser(username);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const LoginScreen();
          }));
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.comment,
            size: isSmaller ? 16 : 18,
          ),
          const SizedBox(width: 10),
          Text(
            'Odpowiedz',
            style: TextStyle(fontSize: isSmaller ? 11 : 13),
          ),
        ],
      ),
    );
  }
}
