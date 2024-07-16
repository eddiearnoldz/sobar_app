import 'package:flutter/material.dart';

class LaunchUrlPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const LaunchUrlPill({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: GestureDetector(
        onTap: onPressed,
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 15,
            ),
            const SizedBox(
              width: 3,
            ),
            Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
