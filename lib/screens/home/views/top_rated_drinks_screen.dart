import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image/flutter_image.dart';
import 'package:sobar_app/blocs/drink_bloc/drink_bloc.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/components/filter_button.dart';

class TopRatedDrinksScreen extends StatefulWidget {
  const TopRatedDrinksScreen({super.key});

  @override
  _TopRatedDrinksScreenState createState() => _TopRatedDrinksScreenState();
}

class _TopRatedDrinksScreenState extends State<TopRatedDrinksScreen> {
  List<Drink> filteredDrinks = [];
  String currentFilter = 'topRated';

  void filterDrinks(DrinkLoaded state) {
    if (currentFilter == 'alphabetical') {
      filteredDrinks = List.from(state.drinks)..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'onlyZero') {
      filteredDrinks = state.drinks.where((drink) => drink.abv == '0.0%').toList();
    } else if (currentFilter == 'mostPopular') {
      filteredDrinks = List.from(state.drinks)..sort((a, b) => b.ratingsCount.compareTo(a.ratingsCount));
    } else if (currentFilter == 'bottle') {
      filteredDrinks = state.drinks.where((drink) => drink.type == 'bottle').toList();
    } else if (currentFilter == 'can') {
      filteredDrinks = state.drinks.where((drink) => drink.type == 'can').toList();
    } else if (currentFilter == 'wine') {
      filteredDrinks = state.drinks.where((drink) => drink.type == 'wine').toList();
    } else if (currentFilter == 'spirit') {
      filteredDrinks = state.drinks.where((drink) => drink.type == 'spirit').toList();
    } else if (currentFilter == 'draught') {
      filteredDrinks = state.drinks.where((drink) => drink.type == 'draught').toList();
    } else {
      filteredDrinks = List.from(state.drinks)..sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<DrinkBloc, DrinkState>(
            builder: (context, state) {
              if (state is DrinkLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DrinkLoaded) {
                filterDrinks(state);
                return ListView.builder(
                  itemCount: filteredDrinks.length,
                  itemBuilder: (context, index) {
                    Drink drink = filteredDrinks[index];
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
                            width: 60,
                            height: 60,
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        height: 60,
                        width: 60,
                        fit: BoxFit.fitHeight,
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('Failed to load drinks'));
              }
            },
          ),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
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
                      onPressed: () {
                        setState(() {
                          currentFilter = 'alphabetical';
                        });
                      },
                    ),
                    FilterButton(
                      label: '0.0%',
                      color: Colors.blue,
                      isActive: currentFilter == 'onlyZero',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'onlyZero';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Popular',
                      color: Colors.yellow,
                      isActive: currentFilter == 'mostPopular',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'mostPopular';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Top rated',
                      color: Colors.green,
                      isActive: currentFilter == 'topRated',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'topRated';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Bottle',
                      color: Colors.orange,
                      isActive: currentFilter == 'bottle',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'bottle';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Can',
                      color: Colors.purple,
                      isActive: currentFilter == 'can',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'can';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Wine',
                      color: Colors.pink,
                      isActive: currentFilter == 'wine',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'wine';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Spirit',
                      color: Colors.cyan,
                      isActive: currentFilter == 'spirit',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'spirit';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Draught',
                      color: Colors.brown,
                      isActive: currentFilter == 'draught',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'draught';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
