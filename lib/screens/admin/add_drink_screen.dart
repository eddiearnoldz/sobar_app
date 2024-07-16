import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:sobar_app/utils/globals.dart';

class AddDrinkScreen extends StatefulWidget {
  const AddDrinkScreen({super.key});

  @override
  _AddDrinkScreenState createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends State<AddDrinkScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _abvController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  bool _isVegan = false;
  bool _isGlutenFree = false;
  String _selectedType = 'draught';
  final List<String> _drinkTypes = ['draught', 'bottle', 'can', 'wine', 'spirit'];
  List<bool> _selectedTypeToggle = [true, false, false, false, false];

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _abvController.clear();
    _caloriesController.clear();
    setState(() {
      _isVegan = false;
      _isGlutenFree = false;
      _selectedType = 'draught';
      _selectedTypeToggle = [true, false, false, false, false];
    });
  }

  Future<void> _submitDrink() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newDrink = Drink(
        name: _nameController.text,
        abv: _abvController.text,
        isVegan: _isVegan,
        isGlutenFree: _isGlutenFree,
        averageRating: 0.0,
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/sobar-app.appspot.com/o/empty_pint_glass.jpg?alt=media&token=3722311f-555a-4bd9-916b-80b2a887a87b',
        type: _selectedType,
        ratingsCount: 0.0,
        calories: double.parse(_caloriesController.text),
      );

      try {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('drinks').add(newDrink.toJson());
        setState(() {
          newDrink.id = docRef.id; // Update the id of the drink
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'drink successfully added',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 5),
          ),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'failed to add drink',
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
        title: const Text('add drink'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'drink name',
                  labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a drink name' : null,
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _abvController,
                decoration: InputDecoration(
                  labelText: 'abv',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'please enter the abv with % e.g. 0.5%';
                  } else if (!value!.endsWith('%')) {
                    return 'abv must end with a % sign';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'calories',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'please enter the calories';
                  } else if (double.tryParse(value!) == null) {
                    return 'please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'type',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ToggleButtons(
                isSelected: _selectedTypeToggle,
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
                          color: _selectedType == type ? Colors.green : Colors.transparent,
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('vegan'),
                      value: _isVegan,
                      onChanged: (value) {
                        setState(() {
                          _isVegan = value ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('gluten free'),
                      value: _isGlutenFree,
                      onChanged: (value) {
                        setState(() {
                          _isGlutenFree = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _clearForm,
                    child: Text(
                      'clear',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: _submitDrink,
                    child: Text(
                      'submit',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
