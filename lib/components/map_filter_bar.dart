import 'package:flutter/material.dart';
import 'filter_button.dart';

class MapFilterBar extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const MapFilterBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          children: [
            FilterButton(
              label: 'draught',
              color: Colors.purple,
              isActive: currentFilter == 'draught',
              onPressed: () => onFilterChanged('draught'),
            ),
            FilterButton(
              label: 'bottles',
              color: Colors.red,
              isActive: currentFilter == 'bottle',
              onPressed: () => onFilterChanged('bottle'),
            ),
            FilterButton(
              label: 'cans',
              color: Colors.blue,
              isActive: currentFilter == 'can',
              onPressed: () => onFilterChanged('can'),
            ),
            FilterButton(
              label: 'wines',
              color: Colors.green,
              isActive: currentFilter == 'wine',
              onPressed: () => onFilterChanged('wine'),
            ),
            FilterButton(
              label: 'spirits',
              color: Colors.yellow,
              isActive: currentFilter == 'spirit',
              onPressed: () => onFilterChanged('spirit'),
            ),
          ],
        ),
      ),
    );
  }
}
