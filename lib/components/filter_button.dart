import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(isActive ? 0.7 : 0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            minimumSize: Size(MediaQuery.of(context).size.width / 5, 28)),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
