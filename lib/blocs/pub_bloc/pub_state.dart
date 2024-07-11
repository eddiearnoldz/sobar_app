part of 'pub_bloc.dart';

abstract class PubState extends Equatable {
  const PubState();

  @override
  List<Object> get props => [];
}

class PubInitial extends PubState {}

class PubLoading extends PubState {}

class PubLoaded extends PubState {
  final List<Pub> pubs;

  const PubLoaded({required this.pubs});

  @override
  List<Object> get props => [pubs];
}

class PubFiltered extends PubState {
  final List<Pub> filteredPubs;

  const PubFiltered({required this.filteredPubs});

  @override
  List<Object> get props => [filteredPubs];
}

class PubError extends PubState {}
