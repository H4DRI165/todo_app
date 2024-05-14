import 'package:flutter/material.dart';
import 'package:todo_app/constants/colours.dart';

class Button extends StatelessWidget {
  final String text;
  VoidCallback onPressed;

  Button({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: lightGrey,
      child: Text(text),
    );
  }
}
