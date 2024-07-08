import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/models/drink.dart';

class DrinkTile extends StatelessWidget {
  final Drink drink;
  final VoidCallback onTap;

  const DrinkTile({Key? key, required this.drink, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('drinks').doc(drink.id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Text('Error loading drink data');
        }

        final drinkData = snapshot.data!.data() as Map<String, dynamic>;
        final updatedDrink = Drink.fromJson(drink.id, drinkData);

        return ListTile(
          onTap: onTap,
          title: Text(
            updatedDrink.name,
            style: TextStyle(fontFamily: 'Anton'),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ABV: ${updatedDrink.abv}'),
              Text('SOBÆR Rating: ${updatedDrink.averageRating}/5'),
              Text('Reviews: ${updatedDrink.ratingsCount.round()}'),
            ],
          ),
          leading: CachedNetworkImage(
            imageUrl: updatedDrink.imageUrl,
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
              if (updatedDrink.isVegan)
                const Text(
                  "VEGAN",
                  style: TextStyle(fontFamily: 'Anton', color: Color.fromARGB(255, 12, 74, 14)),
                ),
              if (updatedDrink.isGlutenFree)
                const Text(
                  "GF",
                  style: TextStyle(fontFamily: 'Anton'),
                ),
            ],
          ),
        );
      },
    );
  }
}
