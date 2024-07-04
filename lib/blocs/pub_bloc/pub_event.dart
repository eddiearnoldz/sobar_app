part of 'pub_bloc.dart';

abstract class PubEvent extends Equatable {
  const PubEvent();

  @override
  List<Object> get props => [];
}

class LoadPubs extends PubEvent {}

class ResetDrinks extends PubEvent {}
