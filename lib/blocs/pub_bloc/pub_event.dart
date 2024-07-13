part of 'pub_bloc.dart';

abstract class PubEvent extends Equatable {
  const PubEvent();

  @override
  List<Object> get props => [];
}

class LoadPubs extends PubEvent {}

class FilterPubs extends PubEvent {
  final String filter;
  final List<String>? favouritePubIds;

  const FilterPubs({required this.filter, this.favouritePubIds});

  @override
  List<Object> get props => [filter, favouritePubIds ?? []];
}
