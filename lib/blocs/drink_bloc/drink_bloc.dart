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
      List<Drink> drinks = snapshot.docs.map((doc) => Drink.fromJson(doc.data() as Map<String, dynamic>)).toList();
      emit(DrinkLoaded(drinks: drinks));
    } catch (e) {
      print("error with drink model: $e");
      emit(DrinkError());
    }
  }
}
