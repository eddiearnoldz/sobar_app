import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/screens/home/views/drink_screen.dart';
import 'package:sobar_app/components/drink_tile.dart';
import 'package:sobar_app/components/drinks_filter_bar.dart';
import 'package:sobar_app/models/drink.dart';

class DrinksScreen extends StatefulWidget {
  final Function(Drink) onSearchOnMap;
  const DrinksScreen({super.key, required this.onSearchOnMap});

  @override
  _DrinksScreenState createState() => _DrinksScreenState();
}

class _DrinksScreenState extends State<DrinksScreen> {
  List<Drink> filteredDrinks = [];
  String currentFilter = 'topRated';

  void filterDrinks(List<Drink> drinks) {
    if (currentFilter == 'alphabetical') {
      filteredDrinks = List.from(drinks)..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'onlyZero') {
      filteredDrinks = List.from(drinks.where((drink) => drink.abv == '0.0%'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'mostPopular') {
      filteredDrinks = List.from(drinks)..sort((a, b) => b.ratingsCount.compareTo(a.ratingsCount));
    } else if (currentFilter == 'bottle') {
      filteredDrinks = List.from(drinks.where((drink) => drink.type == 'bottle'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'can') {
      filteredDrinks = List.from(drinks.where((drink) => drink.type == 'can'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'wine') {
      filteredDrinks = List.from(drinks.where((drink) => drink.type == 'wine'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'spirit') {
      filteredDrinks = List.from(drinks.where((drink) => drink.type == 'spirit'))..sort((a, b) => a.name.compareTo(b.name));
    } else if (currentFilter == 'draught') {
      filteredDrinks = List.from(drinks.where((drink) => drink.type == 'draught'))..sort((a, b) => a.name.compareTo(b.name));
    } else {
      filteredDrinks = List.from(drinks)..sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }
  }

  void updateFilter(String newFilter) {
    setState(() {
      currentFilter = newFilter;
    });
  }

  void _navigateToDrinkReview(Drink drink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DrinkScreen(
          drink: drink,
          onSearchOnMap: widget.onSearchOnMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('drinks').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.hasError) {
                return const Center(child: Text('Failed to load drinks'));
              }

              List<Drink> drinks = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Drink.fromJson(doc.id, data);
              }).toList();

              filterDrinks(drinks);

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
                      onTap: () => _navigateToDrinkReview(filteredDrinks[index]),
                    );
                  }
                },
              );
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
