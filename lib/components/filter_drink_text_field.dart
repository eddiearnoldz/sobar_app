import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';

class FilterDrinkTextField extends StatefulWidget {
  final List<Drink> filteredDrinks;
  final Function(String) onSearchChanged;
  final Function(Drink) onDrinkSelected;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final Function() unfocusTextField;

  const FilterDrinkTextField({
    super.key,
    required this.filteredDrinks,
    required this.onSearchChanged,
    required this.onDrinkSelected,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.unfocusTextField,
  });

  @override
  _FilterDrinkTextFieldState createState() => _FilterDrinkTextFieldState();
}

class _FilterDrinkTextFieldState extends State<FilterDrinkTextField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.unfocusTextField,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.onPrimary,
                cursorHeight: 15,
                controller: widget.controller,
                focusNode: widget.focusNode,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search for a drink...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  fillColor: Theme.of(context).colorScheme.primary.withOpacity(widget.isFocused ? 1.0 : 0.6),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onChanged: (value) {
                  widget.onSearchChanged(value);
                  if (value.isEmpty) {
                    widget.unfocusTextField();
                  }
                },
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty && widget.filteredDrinks.isNotEmpty)
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width - 56,
              child: ListView.builder(
                padding: EdgeInsets.only(left: 10),
                scrollDirection: Axis.horizontal,
                itemCount: widget.filteredDrinks.length,
                itemBuilder: (context, index) {
                  final drink = widget.filteredDrinks[index];
                  return GestureDetector(
                    onTap: () => {widget.onDrinkSelected(drink), widget.controller.clear()},
                    child: Container(
                      width: MediaQuery.of(context).size.width - 86,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(top: 5, right: 5),
                      decoration: BoxDecoration(
                        color: _getDrinkColor(drink.type),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.network(drink.imageUrl, width: 40, height: 40, fit: BoxFit.contain),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(drink.name, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                              Row(
                                children: [
                                  Text('abv:${drink.abv}', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  if (drink.isVegan)
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  if (drink.isVegan) Text(' *vegan', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  if (drink.isGlutenFree) Text(' *gf', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  if (drink.isGlutenFree)
                                    const SizedBox(
                                      width: 5,
                                    ),
                                  if (drink.calories.toString().isNotEmpty) Text(' *${drink.calories.round().toString()}cals', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getDrinkColor(String type) {
    switch (type) {
      case 'draught':
        return Colors.purple.withOpacity(0.9);
      case 'bottle':
        return Colors.red.withOpacity(0.9);
      case 'can':
        return Colors.blue.withOpacity(0.9);
      case 'wine':
        return Colors.green.withOpacity(0.9);
      case 'spirit':
        return Colors.yellow.withOpacity(0.9);
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.9);
    }
  }
}
