import 'package:flutter/material.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const SignOutConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(0),
        title: const Text(
          'sign out',
          style: TextStyle(fontFamily: 'Anton'),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'are you sure you want to sign out?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'nope',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
            ),
            child: Text(
              'yep',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
