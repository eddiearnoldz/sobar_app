import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';

class FilterDrinkResultsList extends StatelessWidget {
  final List<Drink> filteredDrinks;
  final Function(Drink) onDrinkSelected;

  const FilterDrinkResultsList({
    super.key,
    required this.filteredDrinks,
    required this.onDrinkSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredDrinks.length,
        itemBuilder: (context, index) {
          final drink = filteredDrinks[index];
          return GestureDetector(
            onTap: () => onDrinkSelected(drink),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(top: 5, left: 10),
              decoration: BoxDecoration(
                color: _getDrinkColor(drink.type),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Image.network(drink.imageUrl, width: 40, height: 40, fit: BoxFit.contain),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(drink.name, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Text('abv:${drink.abv}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                          if (drink.isVegan) const SizedBox(width: 5),
                          if (drink.isVegan) Text(' *vegan', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                          const SizedBox(width: 5),
                          if (drink.isGlutenFree) Text(' *gf', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                          if (drink.isGlutenFree) const SizedBox(width: 5),
                          if (drink.calories.toString().isNotEmpty) Text(' *${drink.calories.round().toString()}cals', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDrinkColor(String type) {
    switch (type) {
      case 'draught':
        return Colors.purple.withOpacity(0.9);
      case 'bottle':
        return Colors.red.withOpacity(0.9);
      case 'can':
        return Colors.blue.withOpacity(0.9);
      case 'wine':
        return Colors.green.withOpacity(0.9);
      case 'spirit':
        return Colors.yellow.withOpacity(0.9);
      default:
        return Colors.grey.shade900;
    }
  }
}
