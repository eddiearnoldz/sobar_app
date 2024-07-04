import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double padding;
  final String buttonText;
  final MaterialStateProperty<Color> backgroundColor;

  const MyTextButton({
    super.key,
    required this.onPressed,
    required this.padding,
    required this.backgroundColor,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: backgroundColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary),
          ),
        ));
  }
}
