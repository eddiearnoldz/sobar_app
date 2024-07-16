import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sobar_app/utils/globals.dart';

class MissingDrinkScreen extends StatefulWidget {
  const MissingDrinkScreen({super.key});

  @override
  _MissingDrinkScreenState createState() => _MissingDrinkScreenState();
}

class _MissingDrinkScreenState extends State<MissingDrinkScreen> {
  final TextEditingController _pubNameController = TextEditingController();
  final TextEditingController _pubAddressController = TextEditingController();
  final TextEditingController _drinkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _drinkTypes = ['draught', 'bottle', 'can', 'wine', 'spirit'];
  final List<bool> _selectedTypeToggle = [false, false, false, false, false];
  String _selectedType = '';

  Future<void> _submitMissingDrink() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedType.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a drink type',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('missingDrinksReported')
            .add({'pub_name': _pubNameController.text, 'pub_address': _pubAddressController.text, 'drink': _drinkController.text, 'type': _selectedType, 'resolved': false});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Drink information submitted successfully!',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 5),
          ),
        );

        _pubNameController.clear();
        _pubAddressController.clear();
        _drinkController.clear();
        setState(() {
          _selectedTypeToggle.fillRange(0, _selectedTypeToggle.length, false);
          _selectedType = '';
        });
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit drink information: ${e.toString()}',
              textAlign: TextAlign.center,
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('missing drink information'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Please be as accurate as possible and we'll update our database asap. Currently we only have London venues",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: _pubNameController,
                    decoration: InputDecoration(
                      labelText: 'venue name',
                      labelStyle: TextStyle(
                        fontFamily: 'Anton',
                        letterSpacing: 1,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: canColour),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: canColour),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: canColour),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'please enter the pub name' : null,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pubAddressController,
                    decoration: InputDecoration(
                      labelText: 'venue address',
                      labelStyle: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Anton',
                        letterSpacing: 1,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: draughtColour),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: draughtColour),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: draughtColour),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'please enter the pub address' : null,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _drinkController,
                    decoration: InputDecoration(
                      labelText: 'drink',
                      labelStyle: TextStyle(
                        fontFamily: 'Anton',
                        letterSpacing: 1,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: spiritColour),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: spiritColour),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: spiritColour),
                      ),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'please enter the drink' : null,
                    cursorColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 16),
                  ToggleButtons(
                    isSelected: _selectedTypeToggle,
                    splashColor: Colors.transparent,
                    direction: Axis.vertical,
                    onPressed: (index) {
                      setState(() {
                        for (int i = 0; i < _selectedTypeToggle.length; i++) {
                          _selectedTypeToggle[i] = i == index;
                        }
                        _selectedType = _drinkTypes[index];
                      });
                    },
                    fillColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                    constraints: const BoxConstraints(minHeight: 48),
                    renderBorder: false,
                    children: _drinkTypes
                        .map((type) => Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Theme.of(context).colorScheme.onPrimary),
                                  color: _selectedType == type ? _getDrinkTypeColor(type) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(5)),
                              width: (MediaQuery.of(context).size.width - 20),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Anton',
                                  letterSpacing: 1,
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: _submitMissingDrink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: wineColour,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        ),
                        child: Text(
                          'submit',
                          style: TextStyle(
                            fontFamily: 'Anton',
                            letterSpacing: 1,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDrinkTypeColor(String type) {
    switch (type) {
      case 'draught':
        return draughtColour;
      case 'bottle':
        return bottleColour;
      case 'can':
        return canColour;
      case 'wine':
        return wineColour;
      case 'spirit':
        return spiritColour;
      default:
        return Colors.transparent;
    }
  }
}
