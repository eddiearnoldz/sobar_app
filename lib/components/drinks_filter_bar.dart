import 'package:flutter/material.dart';
import 'package:sobar_app/components/filter_button.dart';
import 'package:sobar_app/utils/globals.dart';

class DrinksFilterBar extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const DrinksFilterBar({
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
            FilterButton(
              label: 'draught',
              color: draughtColour,
              isActive: currentFilter == 'draught',
              onPressed: () => onFilterChanged('draught'),
            ),
            FilterButton(
              label: 'a to z',
              color: Colors.pink,
              isActive: currentFilter == 'alphabetical',
              onPressed: () => onFilterChanged('alphabetical'),
            ),
            FilterButton(
              label: '0.0%',
              color: Colors.teal,
              isActive: currentFilter == 'onlyZero',
              onPressed: () => onFilterChanged('onlyZero'),
            ),
            FilterButton(
              label: 'popular',
              color: Colors.orange,
              isActive: currentFilter == 'mostPopular',
              onPressed: () => onFilterChanged('mostPopular'),
            ),
            FilterButton(
              label: 'top rated',
              color: Colors.indigo,
              isActive: currentFilter == 'topRated',
              onPressed: () => onFilterChanged('topRated'),
            ),
          ],
        ),
      ),
    );
  }
}
