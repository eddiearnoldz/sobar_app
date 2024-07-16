import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FavouritePubPill extends StatefulWidget {
  final Pub pub;

  const FavouritePubPill({super.key, required this.pub});

  @override
  _FavouritePubPillState createState() => _FavouritePubPillState();
}

class _FavouritePubPillState extends State<FavouritePubPill> {
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavourite();
  }

  Future<void> checkIfFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.pub.id.isNotEmpty) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final favouriteDoc = await userDoc.get();
      if (favouriteDoc.exists) {
        final favourites = favouriteDoc.data()?['favourites'] ?? [];
        if (favourites.contains(widget.pub.id)) {
          setState(() {
            isFavourite = true;
          });
        }
      }
    }
  }

  void toggleFavourite() async {
    final user = context.read<AuthenticationBloc>().state.user;
    if (user != null) {
      final pubRef = FirebaseFirestore.instance.collection('pubs').doc(widget.pub.id);
      if (pubRef.id.isNotEmpty) {
        await updateUserFavourites(user.userId, pubRef, !isFavourite);
        setState(() {
          isFavourite = !isFavourite;
        });
      } else {
        log('Pub reference ID is empty');
      }
    }
  }

  Future<void> updateUserFavourites(String userId, DocumentReference pubRef, bool isAdding) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
      if (isAdding) {
        await userDoc.update({
          'favourites': FieldValue.arrayUnion([pubRef.id])
        });
      } else {
        await userDoc.update({
          'favourites': FieldValue.arrayRemove([pubRef.id])
        });
      }
    } catch (e) {
      log('Error updating favourites: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(5),
          color: isFavourite ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: GestureDetector(
        onTap: toggleFavourite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavourite ? Icons.favorite : Icons.favorite_border,
              color: isFavourite ? const Color.fromARGB(255, 247, 119, 87) : Theme.of(context).colorScheme.onPrimary,
              size: 15,
            ),
            const SizedBox(width: 3),
            Text(
              "venue",
              style: TextStyle(color: isFavourite ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
