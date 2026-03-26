import 'package:flutter/material.dart';

class MyFilterChip extends StatelessWidget {
  const MyFilterChip({
    super.key,
    required this.text,
    required this.onSelect,
    required this.selected,
  });

  final String text;
  final bool selected;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      selected: selected,
      onSelected: onSelect,
    );
  }
}
