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
              isActive: currentFilter.contains('draught'),
              onPressed: () => onFilterChanged('draught'),
            ),
            FilterButton(
              label: 'bottles',
              color: bottleColour,
              isActive: currentFilter.contains('bottle'),
              onPressed: () => onFilterChanged('bottle'),
            ),
            FilterButton(
              label: 'cans',
              color: canColour,
              isActive: currentFilter.contains('can'),
              onPressed: () => onFilterChanged('can'),
            ),
            FilterButton(
              label: 'wines',
              color: wineColour,
              isActive: currentFilter.contains('wine'),
              onPressed: () => onFilterChanged('wine'),
            ),
            FilterButton(
              label: 'spirits',
              color: spiritColour,
              isActive: currentFilter.contains('spirit'),
              onPressed: () => onFilterChanged('spirit'),
            ),
            FilterButton(
              label: '5 plus',
              color: fivePlusColour,
              isActive: currentFilter.contains('5Plus'),
              onPressed: () => onFilterChanged('5Plus'),
            ),
            FilterButton(
              label: 'vegan',
              color: veganColour,
              isActive: currentFilter.contains('vegan'),
              onPressed: () => onFilterChanged('vegan'),
            ),
            FilterButton(
              label: 'gluten free',
              color: glutenFreeColour,
              isActive: currentFilter.contains('glutenFree'),
              onPressed: () => onFilterChanged('glutenFree'),
            ),
            FilterButton(
              label: '0.0%',
              color: zeroColour,
              isActive: currentFilter.contains('zero'),
              onPressed: () => onFilterChanged('zero'),
            ),
          ],
        ),
      ),
    );
  }
}
