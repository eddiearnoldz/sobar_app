import 'package:flutter/material.dart';
import 'package:sobar_app/models/drink.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/utils/map_provider.dart';

class FilterDrinkTextField extends StatefulWidget {
  final List<Drink> filteredDrinks;
  final Function(String) onSearchChanged;
  final Function(Drink) onDrinkSelected;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final Function() unfocusTextField;

  const FilterDrinkTextField({
    Key? key,
    required this.filteredDrinks,
    required this.onSearchChanged,
    required this.onDrinkSelected,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.unfocusTextField,
  }) : super(key: key);

  @override
  _FilterDrinkTextFieldState createState() => _FilterDrinkTextFieldState();
}

class _FilterDrinkTextFieldState extends State<FilterDrinkTextField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.unfocusTextField,
      child: Column(
        children: [
          SizedBox(
            height: 40,
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
              onChanged: widget.onSearchChanged,
            ),
          ),
          if (widget.filteredDrinks.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: widget.filteredDrinks.length,
                itemBuilder: (context, index) {
                  final drink = widget.filteredDrinks[index];
                  return GestureDetector(
                    onTap: () => widget.onDrinkSelected(drink),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(5),
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
                              Text(drink.name, style: const TextStyle(color: Colors.white)),
                              Text(drink.abv, style: const TextStyle(color: Colors.white)),
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
        return Colors.purple.withOpacity(0.7);
      case 'bottle':
        return Colors.red.withOpacity(0.7);
      case 'can':
        return Colors.blue.withOpacity(0.7);
      case 'wine':
        return Colors.green.withOpacity(0.7);
      case 'spirit':
        return Colors.yellow.withOpacity(0.7);
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.7);
    }
  }
}
