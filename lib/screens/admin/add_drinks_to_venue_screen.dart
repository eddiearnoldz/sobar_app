import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/globals.dart';

class AddDrinksToVenueScreen extends StatefulWidget {
  const AddDrinksToVenueScreen({super.key});

  @override
  _AddDrinksToVenueScreenState createState() => _AddDrinksToVenueScreenState();
}

class _AddDrinksToVenueScreenState extends State<AddDrinksToVenueScreen> {
  final TextEditingController _pubController = TextEditingController();
  final TextEditingController _drinkController = TextEditingController();
  List<Pub> allPubs = [];
  List<Drink> allDrinks = [];
  List<Pub> filteredPubs = [];
  List<Drink> filteredDrinks = [];
  Pub? selectedPub;
  List<Drink> drinks = [];

  @override
  void initState() {
    super.initState();
    _loadPubsAndDrinks();
    _pubController.addListener(_filterPubs);
    _drinkController.addListener(_filterDrinks);
  }

  Future<void> _loadPubsAndDrinks() async {
    // Load all pubs
    final pubSnapshot = await FirebaseFirestore.instance.collection('pubs').get();
    final pubs = pubSnapshot.docs.map((doc) => Pub.fromJson(doc.id, doc.data())).toList();

    // Load all drinks
    final drinkSnapshot = await FirebaseFirestore.instance.collection('drinks').get();
    final drinks = drinkSnapshot.docs.map((doc) => Drink.fromJson(doc.id, doc.data() as Map<String, dynamic>)).toList();

    setState(() {
      allPubs = pubs;
      allDrinks = drinks;
    });
  }

  void _filterPubs() {
    final query = _pubController.text.toLowerCase();
    setState(() {
      filteredPubs = allPubs.where((pub) => pub.locationName.toLowerCase().contains(query)).toList();
    });
  }

  void _filterDrinks() {
    final query = _drinkController.text.toLowerCase();
    setState(() {
      filteredDrinks = allDrinks.where((drink) => drink.name.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _selectPub(Pub pub) async {
    final pubDoc = FirebaseFirestore.instance.collection('pubs').doc(pub.id);
    final existingDrinksSnapshot = await pubDoc.get();
    List<DocumentReference> existingDrinkRefs = (existingDrinksSnapshot.data()?['drinks'] as List<dynamic>? ?? []).map((docRef) => docRef as DocumentReference).toList();

    final drinks = await Future.wait(existingDrinkRefs.map((docRef) async {
      final drinkDoc = await docRef.get();
      return Drink.fromJson(drinkDoc.id, drinkDoc.data()! as Map<String, dynamic>);
    }));

    setState(() {
      selectedPub = pub;
      this.drinks = drinks;
      filteredPubs = [];
      _pubController.clear();
    });
  }

  void _addDrink(Drink drink) {
    if (!drinks.any((d) => d.id == drink.id)) {
      setState(() {
        drinks.add(drink);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "${drink.name} added to venue drinks list",
              style: const TextStyle(color: wineColour),
              textAlign: TextAlign.center,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(
            child: Text(
              "That drink's already on the list",
              textAlign: TextAlign.center,
            ),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _removeDrink(Drink drink) {
    setState(() {
      drinks.remove(drink);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "${drink.name} removed to venue drinks list",
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submitDrinks() async {
    if (selectedPub != null) {
      final pubDoc = FirebaseFirestore.instance.collection('pubs').doc(selectedPub!.id);
      final drinkRefs = drinks.map((drink) => FirebaseFirestore.instance.collection('drinks').doc(drink.id)).toList();

      await pubDoc.update({'drinks': drinkRefs});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Drinks updated for ${selectedPub!.locationName}',
          textAlign: TextAlign.center,
        )),
      );

      setState(() {
        selectedPub = null;
        drinks.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('add drinks to venue'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedPub == null)
                  TextField(
                    controller: _pubController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'search for a venue',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                if (filteredPubs.isNotEmpty && _pubController.text.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredPubs.length,
                      itemBuilder: (context, index) {
                        final pub = filteredPubs[index];
                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pub.locationName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                pub.locationAddress,
                              ),
                            ],
                          ),
                          onTap: () => _selectPub(pub),
                        );
                      },
                    ),
                  ),
                if (selectedPub != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'venue: ${selectedPub!.locationName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error),
                        onPressed: () {
                          setState(() {
                            selectedPub = null;
                            _pubController.clear();
                            _drinkController.clear();
                            filteredPubs.clear();
                            filteredDrinks.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(alignment: Alignment.centerRight, children: [
                    TextField(
                      controller: _drinkController,
                      decoration: InputDecoration(
                        labelText: 'search for a drink',
                        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      cursorColor: Theme.of(context).colorScheme.onPrimary,
                      onChanged: (value) {
                        if (value.isEmpty) {
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                    if (_drinkController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error),
                        onPressed: () {
                          _drinkController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      ),
                  ]),
                  if (filteredDrinks.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDrinks.length,
                        itemBuilder: (context, index) {
                          final drink = filteredDrinks[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    drink.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  drink.type.toUpperCase(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: wineColour,
                              ),
                              onPressed: () => _addDrink(drink),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (drinks.isEmpty)
                    const Expanded(
                        child: Text(
                      "This venue has no drinks yet",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    )),
                  if (drinks.isNotEmpty) ...[
                    const Text(
                      'current drinks selection:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: drinks.length,
                        itemBuilder: (context, index) {
                          final drink = drinks[index];
                          return ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    drink.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  ' - ${drink.type.toUpperCase()}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: bottleColour,
                              ),
                              onPressed: () => _removeDrink(drink),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            drinks.clear();
                            selectedPub = null;
                            _pubController.clear();
                            _drinkController.clear();
                            filteredPubs.clear();
                            filteredDrinks.clear();
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      ElevatedButton(
                        onPressed: _submitDrinks,
                        child: Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
