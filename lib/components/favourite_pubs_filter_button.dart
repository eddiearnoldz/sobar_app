import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:sobar_app/blocs/pub_bloc/pub_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritePubsFilterButton extends StatefulWidget {
  const FavouritePubsFilterButton({Key? key}) : super(key: key);

  @override
  _FavouritePubsFilterButtonState createState() => _FavouritePubsFilterButtonState();
}

class _FavouritePubsFilterButtonState extends State<FavouritePubsFilterButton> {
  bool isFilterActive = false;
  bool hasNoFavourites = false;

  void _toggleFavouriteFilter() async {
    final user = context.read<AuthenticationBloc>().state.user;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.userId).get();
      final favourites = List<String>.from(userDoc.data()?['favourites'] ?? []);

      if (isFilterActive) {
        if (mounted) context.read<PubBloc>().add(const FilterPubs(filter: ''));
        setState(() {
          isFilterActive = false;
          hasNoFavourites = false;
        });
      } else {
        if (favourites.isNotEmpty) {
          if (mounted) context.read<PubBloc>().add(FilterPubs(filter: '', favouritePubIds: favourites));
          setState(() {
            isFilterActive = true;
            hasNoFavourites = false;
          });
        } else {
          if (mounted) context.read<PubBloc>().add(const FilterPubs(filter: ''));
          setState(() {
            isFilterActive = true;
            hasNoFavourites = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 240,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            onPressed: _toggleFavouriteFilter,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.favorite,
              color: isFilterActive ? Colors.red : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        if (isFilterActive && hasNoFavourites)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Add some pubs to your favourite list',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
