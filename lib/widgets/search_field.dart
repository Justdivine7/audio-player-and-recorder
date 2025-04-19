import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String) searchFunction;

  const SearchField(
      {super.key,
      required this.searchController,
      required this.searchFunction});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: searchFunction,
      onSubmitted: searchFunction,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.shade400,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).highlightColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).highlightColor,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
        hintText: 'Search',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
