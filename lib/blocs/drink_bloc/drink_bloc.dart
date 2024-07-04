import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'drink_event.dart';
part 'drink_state.dart';

class DrinkBloc extends Bloc<DrinkEvent, DrinkState> {
  final FirebaseFirestore firestore;

  DrinkBloc({required this.firestore}) : super(DrinkInitial()) {
    on<LoadDrinks>(_onLoadDrinks);
  }

  void _onLoadDrinks(LoadDrinks event, Emitter<DrinkState> emit) async {
    emit(DrinkLoading());
    try {
      QuerySnapshot snapshot = await firestore.collection('drinks').get();

      List<Future<Drink?>> futures = snapshot.docs.map((doc) async {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return Drink.fromJson(data);
        } catch (e) {
          print('Error parsing drink document: ${doc.id}, error: $e');
          return null; // Skip the document if there's an error
        }
      }).toList();

      List<Drink> drinks = (await Future.wait(futures)).whereType<Drink>().toList();
      emit(DrinkLoaded(drinks: drinks));
    } catch (e) {
      print("Error loading drinks: $e");
      emit(DrinkError());
    }
  }
}
