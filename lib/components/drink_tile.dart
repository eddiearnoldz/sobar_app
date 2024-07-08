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
        drink.name,
        style: const TextStyle(fontFamily: 'Anton'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABV: ${drink.abv}'),
          Text('SOBÆR Rating: ${drink.averageRating}/5'),
          Text('Reviews: ${drink.ratingsCount.round()}'),
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
            const Text(
              "VEGAN",
              style: TextStyle(fontFamily: 'Anton', color: Color.fromARGB(255, 12, 74, 14)),
            ),
          if (drink.isGlutenFree)
            const Text(
              "GF",
              style: TextStyle(fontFamily: 'Anton'),
            ),
        ],
      ),
    );
  }
}
