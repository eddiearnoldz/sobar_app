import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:sobar_app/blocs/drink_bloc/drink_bloc.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopRatedDrinksScreen extends StatelessWidget {
  const TopRatedDrinksScreen({super.key});

  Future<String> getUserName(DocumentReference userRef) async {
    DocumentSnapshot userDoc = await userRef.get();
    return userDoc['name']; // Assuming the user document has a 'name' field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DrinkBloc, DrinkState>(
        builder: (context, state) {
          if (state is DrinkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DrinkLoaded) {
            state.drinks.sort((a, b) => b.averageRating.compareTo(a.averageRating));
            return ListView.builder(
              itemCount: state.drinks.length,
              itemBuilder: (context, index) {
                Drink drink = state.drinks[index];
                return ListTile(
                  title: Text(
                    drink.name,
                    style: TextStyle(fontFamily: 'Anton'),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ABV: ${drink.abv}'),
                      Text('SOBÆR Rating: ${drink.averageRating}/5'),
                      Text('Votes: ${drink.ratingsCount.round()}'),
                    ],
                  ),
                  leading: Image(
                    image: NetworkImageWithRetry(
                      drink.imageUrl,
                    ),
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                        width: 80,
                        height: 80,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Failed to load drinks'));
          }
        },
      ),
    );
  }
}
