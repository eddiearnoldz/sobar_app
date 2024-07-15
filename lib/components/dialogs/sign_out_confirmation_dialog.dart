import 'package:flutter/material.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const SignOutConfirmationDialog({Key? key, required this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'sign out',
        style: TextStyle(fontFamily: 'Anton'),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Are you sure you want to sign out?',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'nope',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(
            'yep',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
