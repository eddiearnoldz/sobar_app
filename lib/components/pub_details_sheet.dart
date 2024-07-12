import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';

class PubDetailsSheet extends StatefulWidget {
  final Pub pub;

  const PubDetailsSheet({super.key, required this.pub});

  @override
  _PubDetailsSheetState createState() => _PubDetailsSheetState();
}

class _PubDetailsSheetState extends State<PubDetailsSheet> {
  int _selectedPage = 0;
  late Future<Map<String, List<Drink>>> _drinkGroupsFuture;

  @override
  void initState() {
    super.initState();
    _drinkGroupsFuture = _fetchDrinkGroups(widget.pub);
  }

  Future<Map<String, List<Drink>>> _fetchDrinkGroups(Pub pub) async {
    List<Drink> drinks = await _getAllDrinks(pub);
    return _groupDrinksByType(drinks);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.pub.locationName,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton', fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            widget.pub.locationAddress,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['draught', 'can', 'bottle', 'wine', 'spirit'].map((type) {
              int index = ['draught', 'can', 'bottle', 'wine', 'spirit'].indexOf(type);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPage = index;
                  });
                },
                child: Column(
                  children: [
                    Stack(children: [
                      Text('${type}s',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Anton',
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
                      if (_selectedPage == index)
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 2,
                            width: 40,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                    ])
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<Map<String, List<Drink>>>(
              future: _drinkGroupsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading drinks'));
                } else {
                  final drinkGroups = snapshot.data!;
                  final drinksOfType = drinkGroups.values.elementAt(_selectedPage);

                  return AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(milliseconds: 300),
                    child: Visibility(
                      visible: true,
                      maintainState: true,
                      child: drinksOfType.isEmpty
                          ? Center(child: Text('No ${drinkGroups.keys.elementAt(_selectedPage)}s at this pub yet'))
                          : ListView.builder(
                              itemCount: drinksOfType.length,
                              itemBuilder: (context, index) {
                                final drink = drinksOfType[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CachedNetworkImage(
                                          imageUrl: drink.imageUrl,
                                          placeholder: (context, url) => Container(
                                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                                            width: 40,
                                            height: 40,
                                          ),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                          height: 40,
                                          width: 40,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${drink.name} - ABV: ${drink.abv}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Drink>> _getAllDrinks(Pub pub) async {
    List<Drink> drinks = [];

    for (var drinkRef in pub.drinks) {
      try {
        DocumentSnapshot snapshot = await drinkRef.get();
        if (snapshot.exists) {
          drinks.add(Drink.fromJson(drinkRef.id, snapshot.data() as Map<String, dynamic>));
        }
      } catch (e) {
        print('Error fetching drink: $e');
      }
    }

    return drinks;
  }

  Map<String, List<Drink>> _groupDrinksByType(List<Drink> drinks) {
    Map<String, List<Drink>> drinkGroups = {
      'draught': [],
      'can': [],
      'bottle': [],
      'wine': [],
      'spirit': [],
    };

    for (var drink in drinks) {
      drinkGroups[drink.type]?.add(drink);
    }

    return drinkGroups;
  }
}
