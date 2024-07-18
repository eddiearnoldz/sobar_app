import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sobar_app/models/pub.dart';
import 'package:sobar_app/utils/map_provider.dart';

class FilterPubTextField extends StatefulWidget {
  final List<Pub> filteredPubs;
  final Function(String) onSearchChanged;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final Function() unfocusTextField;

  const FilterPubTextField({
    super.key,
    required this.filteredPubs,
    required this.onSearchChanged,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.unfocusTextField,
  });

  @override
  _FilterPubTextFieldState createState() => _FilterPubTextFieldState();
}

class _FilterPubTextFieldState extends State<FilterPubTextField> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.unfocusTextField,
      child: SizedBox(
        height: 40,
        width: (MediaQuery.of(context).size.width / 2) - 5,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Stack(alignment: Alignment.centerRight, children: [
            TextField(
              cursorColor: Theme.of(context).colorScheme.onPrimary,
              cursorHeight: 15,
              controller: widget.controller,
              focusNode: widget.focusNode,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'search venues...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(widget.isFocused ? 1.0 : 0.8),
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
                  Provider.of<MapProvider>(context, listen: false).setPubSearchResults([]);
                }
              },
              onTap: () {
                Provider.of<MapProvider>(context, listen: false).setDrinkSearchResults([]);
              },
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  widget.controller.clear();
                  FocusScope.of(context).unfocus();
                  Provider.of<MapProvider>(context, listen: false).setPubSearchResults([]);
                },
              ),
          ]),
        ),
      ),
    );
  }
}
