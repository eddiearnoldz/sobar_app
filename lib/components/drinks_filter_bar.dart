import 'package:flutter/material.dart';
import 'package:sobar_app/components/filter_button.dart';

class DrinksFilterBar extends StatelessWidget {
  final String currentFilter;
  final ValueChanged<String> onFilterChanged;

  const DrinksFilterBar({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

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
              label: 'A to Z',
              color: Colors.red,
              isActive: currentFilter == 'alphabetical',
              onPressed: () => onFilterChanged('alphabetical'),
            ),
            FilterButton(
              label: '0.0%',
              color: Colors.blue,
              isActive: currentFilter == 'onlyZero',
              onPressed: () => onFilterChanged('onlyZero'),
            ),
            FilterButton(
              label: 'Popular',
              color: Colors.yellow,
              isActive: currentFilter == 'mostPopular',
              onPressed: () => onFilterChanged('mostPopular'),
            ),
            FilterButton(
              label: 'Top rated',
              color: Colors.green,
              isActive: currentFilter == 'topRated',
              onPressed: () => onFilterChanged('topRated'),
            ),
            FilterButton(
              label: 'Bottles',
              color: Colors.orange,
              isActive: currentFilter == 'bottle',
              onPressed: () => onFilterChanged('bottle'),
            ),
            FilterButton(
              label: 'Cans',
              color: Colors.purple,
              isActive: currentFilter == 'can',
              onPressed: () => onFilterChanged('can'),
            ),
            FilterButton(
              label: 'Wines',
              color: Colors.pink,
              isActive: currentFilter == 'wine',
              onPressed: () => onFilterChanged('wine'),
            ),
            FilterButton(
              label: 'Spirits',
              color: Colors.cyan,
              isActive: currentFilter == 'spirit',
              onPressed: () => onFilterChanged('spirit'),
            ),
            FilterButton(
              label: 'Draught',
              color: Colors.brown,
              isActive: currentFilter == 'draught',
              onPressed: () => onFilterChanged('draught'),
            ),
          ],
        ),
      ),
    );
  }
}
