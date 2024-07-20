import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'pub_event.dart';
part 'pub_state.dart';

class PubBloc extends Bloc<PubEvent, PubState> {
  final FirebaseFirestore firestore;
  List<Pub> originalPubs = [];

  PubBloc({required this.firestore}) : super(PubInitial()) {
    on<LoadPubs>(_onLoadPubs);
    on<FilterPubs>(_onFilterPubs);
  }

  Future<void> _onLoadPubs(LoadPubs event, Emitter<PubState> emit) async {
    emit(PubLoading());
    try {
      await for (var snapshot in firestore.collection('pubs').snapshots()) {
        List<Future<Pub?>> futures = snapshot.docs.map((doc) async {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final pub = Pub.fromJson(doc.id, data);

            // Fetch associated drinks for each pub
            List<Drink> drinks = [];
            for (DocumentReference drinkRef in pub.drinks) {
              final drinkDoc = await drinkRef.get();
              if (drinkDoc.exists) {
                drinks.add(Drink.fromJson(drinkDoc.id, drinkDoc.data() as Map<String, dynamic>));
              }
            }
            pub.drinksData = drinks;

            return pub;
          } catch (e) {
            log('Error parsing pub document: ${doc.id}, error: $e');
            return null; // Skip the document if there's an error
          }
        }).toList();

        List<Pub> pubs = (await Future.wait(futures)).whereType<Pub>().toList();
        originalPubs = pubs;
        emit(PubLoaded(pubs: pubs));
      }
    } catch (e) {
      log('Error loading pubs: $e');
      emit(PubError());
    }
  }

  void _onFilterPubs(FilterPubs event, Emitter<PubState> emit) {
    List<Pub> pubsToFilter = originalPubs;
    List<Pub> filteredPubs = pubsToFilter;

    if (event.favouritePubIds != null && event.favouritePubIds!.isNotEmpty) {
      filteredPubs = filteredPubs.where((pub) => event.favouritePubIds!.contains(pub.id)).toList();
    }

    for (var filter in event.filters) {
      if (filter.startsWith('drink_')) {
        final drinkId = filter.substring(6);
        filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.id == drinkId)).toList();
      } else {
        switch (filter) {
          case 'bottle':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.type == 'bottle')).toList();
            break;
          case 'can':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.type == 'can')).toList();
            break;
          case 'wine':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.type == 'wine')).toList();
            break;
          case 'spirit':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.type == 'spirit')).toList();
            break;
          case 'draught':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.any((drink) => drink.type == 'draught')).toList();
            break;
          case '5Plus':
            filteredPubs = filteredPubs.where((pub) => pub.drinksData.length >= 5).toList();
            break;
          default:
            break;
        }
      }
    }

    emit(PubFiltered(filteredPubs: filteredPubs));
  }
}
