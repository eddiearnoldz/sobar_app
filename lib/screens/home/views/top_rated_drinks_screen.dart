import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
      filteredDrinks = List.from(state.drinks.where((drink) => drink.abv == '0.0%'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'mostPopular') {
      filteredDrinks = List.from(state.drinks)..sort((a, b) => b.ratingsCount.compareTo(a.ratingsCount));
    } else if (currentFilter == 'bottle') {
      filteredDrinks = List.from(state.drinks.where((drink) => drink.type == 'bottle'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'can') {
      filteredDrinks = List.from(state.drinks.where((drink) => drink.type == 'can'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'wine') {
      filteredDrinks = List.from(state.drinks.where((drink) => drink.type == 'wine'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'spirit') {
      filteredDrinks = List.from(state.drinks.where((drink) => drink.type == 'spirit'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'draught') {
      filteredDrinks = List.from(state.drinks.where((drink) => drink.type == 'draught'))..sort((a, b) => a.name.compareTo(b.name));
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
                  itemCount: filteredDrinks.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredDrinks.length) {
                      return const SizedBox(
                        height: 40,
                      );
                    } else {
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
                      label: 'Bottles',
                      color: Colors.orange,
                      isActive: currentFilter == 'bottle',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'bottle';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Cans',
                      color: Colors.purple,
                      isActive: currentFilter == 'can',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'can';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Wines',
                      color: Colors.pink,
                      isActive: currentFilter == 'wine',
                      onPressed: () {
                        setState(() {
                          currentFilter = 'wine';
                        });
                      },
                    ),
                    FilterButton(
                      label: 'Spirits',
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
