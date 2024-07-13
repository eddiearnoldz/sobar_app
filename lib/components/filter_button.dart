import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? color : Theme.of(context).colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: color, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            minimumSize: Size(MediaQuery.of(context).size.width / 5, 28)),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
