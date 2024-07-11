part of 'pub_bloc.dart';

abstract class PubEvent extends Equatable {
  const PubEvent();

  @override
  List<Object> get props => [];
}

class LoadPubs extends PubEvent {}

class FilterPubs extends PubEvent {
  final String filter;

  const FilterPubs({required this.filter});

  @override
  List<Object> get props => [filter];
}
