import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PubBloc, PubState>(
        builder: (context, state) {
          if (state is PubLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PubLoaded) {
            return ListView.builder(
              itemCount: state.pubs.length,
              itemBuilder: (context, index) {
                Pub pub = state.pubs[index];
                return ListTile(
                  title: Text(
                    pub.locationName,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 16, color: Colors.black),
                  ),
                  subtitle: Text(
                    pub.locationAddress,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 16, color: Colors.black),
                  ),
                  onTap: () => {showModalBottomSheet(context: context, builder: (context) => PubDetailsSheet(pub: pub), backgroundColor: Colors.white)},
                );
              },
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
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pub.locationName,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              pub.locationAddress,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'City: ${pub.city}',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'Latitude: ${pub.latitude}',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'Longitude: ${pub.longitude}',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ...pub.drinks
                .map((drinkRef) => FutureBuilder<DocumentSnapshot>(
                      future: drinkRef.get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error loading drink');
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text('Drink not found');
                        } else {
                          Drink drink = Drink.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(drink.imageUrl),
                              ),
                              Text(
                                '${drink.name} - ABV: ${drink.abv}',
                                style: TextStyle(color: Colors.red),
                              ),
                              Text('${drink.averageRating}/5', style: TextStyle(color: Colors.red))
                            ],
                          );
                        }
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
