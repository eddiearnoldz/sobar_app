import 'package:flutter/material.dart';
import 'package:sobar_app/utils/globals.dart';
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
              color: draughtColour,
              isActive: currentFilter == 'draught',
              onPressed: () => onFilterChanged('draught'),
            ),
            FilterButton(
              label: 'bottles',
              color: bottleColour,
              isActive: currentFilter == 'bottle',
              onPressed: () => onFilterChanged('bottle'),
            ),
            FilterButton(
              label: 'cans',
              color: canColour,
              isActive: currentFilter == 'can',
              onPressed: () => onFilterChanged('can'),
            ),
            FilterButton(
              label: 'wines',
              color: wineColour,
              isActive: currentFilter == 'wine',
              onPressed: () => onFilterChanged('wine'),
            ),
            FilterButton(
              label: 'spirits',
              color: spiritColour,
              isActive: currentFilter == 'spirit',
              onPressed: () => onFilterChanged('spirit'),
            ),
          ],
        ),
      ),
    );
  }
}
