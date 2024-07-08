import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sobar_app/blocs/drink_bloc/drink_bloc.dart';
import 'package:sobar_app/components/drink_review_modal.dart';
import 'package:sobar_app/components/drink_tile.dart';
import 'package:sobar_app/components/drinks_filter_bar.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/components/filter_button.dart';

class DrinksScreen extends StatefulWidget {
  const DrinksScreen({super.key});

  @override
  _DrinksScreenState createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {
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

  void updateFilter(String newFilter) {
    setState(() {
      currentFilter = newFilter;
    });
  }

  void _showReviewModal(Drink drink) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.only(top: 30),
          child: DrinkReviewModal(drink: drink),
        );
      },
    );
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
                      return DrinkTile(
                        drink: drink,
                        onTap: () => _showReviewModal(filteredDrinks[index]),
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
            child: DrinksFilterBar(
              currentFilter: currentFilter,
              onFilterChanged: updateFilter,
            ),
          ),
        ],
      ),
    );
  }
}
