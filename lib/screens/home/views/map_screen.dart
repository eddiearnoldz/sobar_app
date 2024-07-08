import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<Map<String, bool>> getDrinkTypes(Pub pub) async {
    Map<String, bool> drinkTypes = {
      'draught': false,
      'can': false,
      'bottle': false,
      'wine': false,
      'spirit': false,
    };

    for (var drinkRef in pub.drinks) {
      try {
        DocumentSnapshot snapshot = await drinkRef.get();
        if (snapshot.exists) {
          Drink drink = Drink.fromJson(drinkRef.id, snapshot.data() as Map<String, dynamic>);
          drinkTypes[drink.type] = true;
        }
      } catch (e) {
        print('Error fetching drink: $e');
      }
    }

    return drinkTypes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PubBloc, PubState>(
        builder: (context, state) {
          if (state is PubLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PubLoaded) {
            return Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                itemCount: state.pubs.length,
                itemBuilder: (context, index) {
                  Pub pub = state.pubs[index];
                  return FutureBuilder<Map<String, bool>>(
                    future: getDrinkTypes(pub),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListTile(
                          title: Text(
                            pub.locationName,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton'),
                          ),
                          subtitle: Text(
                            pub.locationAddress,
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondary),
                          ),
                          trailing: const SizedBox(height: 10),
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 1,
                              child: PubDetailsSheet(pub: pub),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      } else {
                        Map<String, bool> drinkTypes = snapshot.data!;
                        return ListTile(
                          title: Text(
                            pub.locationName,
                            style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton'),
                          ),
                          subtitle: Text(
                            pub.locationAddress,
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (drinkTypes['draught']!) ...[
                                const CircleAvatar(radius: 5, backgroundColor: Color.fromARGB(255, 245, 89, 78)),
                                const SizedBox(width: 2),
                              ],
                              if (drinkTypes['can']!) ...[
                                const CircleAvatar(radius: 5, backgroundColor: Color.fromARGB(255, 248, 234, 115)),
                                const SizedBox(width: 2),
                              ],
                              if (drinkTypes['bottle']!) ...[
                                const CircleAvatar(radius: 5, backgroundColor: Color.fromARGB(255, 91, 177, 248)),
                                const SizedBox(width: 2),
                              ],
                              if (drinkTypes['wine']!) ...[
                                const CircleAvatar(radius: 5, backgroundColor: Color.fromARGB(255, 30, 113, 33)),
                                const SizedBox(width: 2),
                              ],
                              if (drinkTypes['spirit']!) ...[
                                const CircleAvatar(radius: 5, backgroundColor: Color.fromARGB(255, 215, 115, 228)),
                                const SizedBox(width: 2),
                              ],
                            ],
                          ),
                          onTap: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => PubDetailsSheet(pub: pub),
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('Failed to load pubs'));
          }
        },
      ),
    );
  }
}

class PubDetailsSheet extends StatelessWidget {
  final Pub pub;

  const PubDetailsSheet({Key? key, required this.pub}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Drink>>(
      future: _getAllDrinks(pub),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final drinks = snapshot.data!;
          final drinkGroups = _groupDrinksByType(drinks);
          return DraggableScrollableSheet(
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pub.locationName,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontFamily: 'Anton'),
                      ),
                      SizedBox(height: 8),
                      Text(
                        pub.locationAddress,
                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      SizedBox(height: 16),
                      (!snapshot.hasData || snapshot.data!.isEmpty)
                          ? const Center(child: Text('No low/no drinks found here'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildDrinkTypeSections(drinkGroups, context),
                            )
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
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

  List<Widget> _buildDrinkTypeSections(Map<String, List<Drink>> drinkGroups, BuildContext context) {
    List<Widget> sections = [];

    drinkGroups.forEach((type, drinks) {
      if (drinks.isNotEmpty) {
        sections.add(Text(type, style: TextStyle(fontSize: 14, fontFamily: 'Anton')));
        sections.add(SizedBox(height: 8));
        sections.addAll(drinks.map((drink) => Row(
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
                SizedBox(width: 8),
                Text(
                  '${drink.name} - ABV: ${drink.abv}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                SizedBox(width: 8),
                Text('${drink.averageRating}/5', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            )));
        sections.add(SizedBox(height: 16));
      }
    });

    return sections;
  }
}
