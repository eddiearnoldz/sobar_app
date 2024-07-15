part of 'pub_bloc.dart';

abstract class PubEvent extends Equatable {
  const PubEvent();

  @override
  List<Object> get props => [];
}

class LoadPubs extends PubEvent {}

class FilterPubs extends PubEvent {
  final List<String> filters;
  final List<String>? favouritePubIds;

  const FilterPubs({required this.filters, this.favouritePubIds});

  @override
  List<Object> get props => [filters, favouritePubIds ?? []];
}
