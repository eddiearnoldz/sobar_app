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

  void _onLoadPubs(LoadPubs event, Emitter<PubState> emit) async {
    emit(PubLoading());
    try {
      QuerySnapshot snapshot = await firestore.collection('pubs').get();

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
          print('Error parsing pub document: ${doc.id}, error: $e');
          return null; // Skip the document if there's an error
        }
      }).toList();

      List<Pub> pubs = (await Future.wait(futures)).whereType<Pub>().toList();
      originalPubs = pubs;
      emit(PubLoaded(pubs: pubs));
    } catch (e) {
      print('Error loading pubs: $e');
      emit(PubError());
    }
  }

  void _onFilterPubs(FilterPubs event, Emitter<PubState> emit) {
    List<Pub> pubsToFilter = originalPubs;
    List<Pub> filteredPubs;

    if (event.filter.isEmpty) {
      filteredPubs = pubsToFilter;
    } else {
      switch (event.filter) {
        case 'bottle':
          filteredPubs = pubsToFilter.where((pub) => pub.drinksData.any((drink) => drink.type == 'bottle')).toList();
          break;
        case 'can':
          filteredPubs = pubsToFilter.where((pub) => pub.drinksData.any((drink) => drink.type == 'can')).toList();
          break;
        case 'wine':
          filteredPubs = pubsToFilter.where((pub) => pub.drinksData.any((drink) => drink.type == 'wine')).toList();
          break;
        case 'spirit':
          filteredPubs = pubsToFilter.where((pub) => pub.drinksData.any((drink) => drink.type == 'spirit')).toList();
          break;
        case 'draught':
          filteredPubs = pubsToFilter.where((pub) => pub.drinksData.any((drink) => drink.type == 'draught')).toList();
          break;
        default:
          filteredPubs = pubsToFilter;
          break;
      }
    }
    emit(PubFiltered(filteredPubs: filteredPubs));
  }
}
