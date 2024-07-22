import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sobar_app/models/drink.dart';

class FilterDrinkResultsList extends StatelessWidget {
  final List<Drink> filteredDrinks;
  final Function(Drink) onDrinkSelected;
  final bool isBlackStyle;
   final TextEditingController drinkController;
  final FocusNode focusNode;

  const FilterDrinkResultsList({super.key, required this.filteredDrinks, required this.onDrinkSelected, required this.isBlackStyle,  required this.drinkController,
    required this.focusNode,});

  @override
  Widget build(BuildContext context) {
    Color gradientColor = isBlackStyle ? HexColor("#212121") : HexColor("#FCF4F0");

    return Stack(alignment: Alignment.bottomCenter, children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * .5,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: filteredDrinks.length,
          itemBuilder: (context, index) {
            final drink = filteredDrinks[index];
            return GestureDetector(
            onTap: () {
                onDrinkSelected(drink);
                drinkController.clear();
                focusNode.unfocus();
              },
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
                    CachedNetworkImage(
                      imageUrl: drink.imageUrl,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(color: Colors.transparent),
                        width: 40,
                        height: 40,
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
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
      ),
      Container(
        height: MediaQuery.of(context).size.height * .05,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientColor.withOpacity(0.0), // Transparent at the top
              gradientColor.withOpacity(0.5), // Semi-transparent
              gradientColor.withOpacity(1.0), // Fully opaque at the bottom
            ],
          ),
        ),
      ),
    ]);
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
