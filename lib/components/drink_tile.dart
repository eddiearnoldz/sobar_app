import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sobar_app/models/drink.dart';

class DrinkTile extends StatelessWidget {
  final Drink drink;
  final VoidCallback onTap;

  const DrinkTile({Key? key, required this.drink, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        drink.name.toUpperCase(),
        style: const TextStyle(fontFamily: 'Anton'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'abv: ',
                ),
                TextSpan(
                  text: '${drink.abv}',
                  style: const TextStyle(fontFamily: 'Work Sans', fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'rating: ',
                ),
                TextSpan(
                  text: '${drink.averageRating}/5',
                  style: const TextStyle(fontFamily: 'Work Sans', fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'reviews: ',
                ),
                TextSpan(
                  text: '${drink.ratingsCount.round()}',
                  style: const TextStyle(fontFamily: 'Work Sans', fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      leading: CachedNetworkImage(
        imageUrl: drink.imageUrl,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          width: 60,
          height: 60,
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
        height: 60,
        width: 60,
        fit: BoxFit.contain,
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (drink.isVegan)
            Text(
              "vegan",
              style: TextStyle(fontFamily: 'Anton', color: Colors.green.withOpacity(0.8)),
            ),
          if (drink.isGlutenFree)
            Text(
              "gf",
              style: TextStyle(fontFamily: 'Anton', color: Colors.red.withOpacity(0.8)),
            ),
          if (drink.calories.isFinite)
            Text(
              "${drink.calories.floor()} cals",
              style: TextStyle(fontFamily: 'Anton', color: Color.fromARGB(255, 0, 91, 249).withOpacity(0.7)),
            ),
        ],
      ),
    );
  }
}
