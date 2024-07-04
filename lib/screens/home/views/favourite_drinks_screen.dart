import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/drink_bloc/drink_bloc.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteDrinksScreen extends StatelessWidget {
  const FavoriteDrinksScreen({super.key});

  Future<String> getUserName(DocumentReference userRef) async {
    DocumentSnapshot userDoc = await userRef.get();
    return userDoc['name']; // Assuming the user document has a 'name' field
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Drinks'),
      ),
      body: BlocBuilder<DrinkBloc, DrinkState>(
        builder: (context, state) {
          if (state is DrinkLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DrinkLoaded) {
            return ListView.builder(
              itemCount: state.drinks.length,
              itemBuilder: (context, index) {
                Drink drink = state.drinks[index];
                return ListTile(
                  title: Text(drink.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ABV: ${drink.abv}'),
                      Text('Type: ${drink.type}'),
                      Text('Average Rating: ${drink.averageRating}'),
                      Text('Ratings Count: ${drink.ratingsCount}'),
                      FutureBuilder(
                        future: Future.wait(drink.ratings.map((rating) => getUserName(rating.userRef)).toList()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading ratings...');
                          } else if (snapshot.hasError) {
                            return const Text('Error loading ratings');
                          } else {
                            List<String> userNames = snapshot.data as List<String>;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: drink.ratings.asMap().entries.map((entry) {
                                int idx = entry.key;
                                Rating rating = entry.value;
                                return Text('${userNames[idx]}: ${rating.rating}');
                              }).toList(),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  leading: Image.network(drink.imageUrl),
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
