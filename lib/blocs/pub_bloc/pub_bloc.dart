import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'pub_event.dart';
part 'pub_state.dart';

class PubBloc extends Bloc<PubEvent, PubState> {
  final FirebaseFirestore firestore;

  PubBloc({required this.firestore}) : super(PubInitial()) {
    on<LoadPubs>(_onLoadPubs);
  }

  void _onLoadPubs(LoadPubs event, Emitter<PubState> emit) async {
    emit(PubLoading());
    try {
      QuerySnapshot snapshot = await firestore.collection('pubs').get();

      List<Future<Pub?>> futures = snapshot.docs.map((doc) async {
        try {
          final data = doc.data() as Map<String, dynamic>;
          return Pub.fromJson(doc.id, data);
        } catch (e) {
          print('Error parsing pub document: ${doc.id}, error: $e');
          return null; // Skip the document if there's an error
        }
      }).toList();

      List<Pub> pubs = (await Future.wait(futures)).whereType<Pub>().toList();
      emit(PubLoaded(pubs: pubs));
    } catch (e) {
      print('Error loading pubs: $e');
      emit(PubError());
    }
  }
}
