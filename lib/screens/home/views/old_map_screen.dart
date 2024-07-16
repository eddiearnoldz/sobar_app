import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/components/pub_details_sheet.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';

class OldMapScreen extends StatelessWidget {
  const OldMapScreen({super.key});

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
        log('Error fetching drink: $e');
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
                          onTap: () => {},
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
                            onTap: () => {});
                      }
                    },
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('Failed to load pubs'));
          }
        },
      ),
    );
  }
}
