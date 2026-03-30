import 'package:flutter/material.dart';

enum LibraryFilter { songs, albums, artists }

class SegmentedControl extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final LibraryFilter current;
  final ValueChanged<LibraryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildItem(context, 'Songs', LibraryFilter.songs),
        _buildItem(context, 'Albums', LibraryFilter.albums),
        _buildItem(context, 'Artists', LibraryFilter.artists),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String text, LibraryFilter value) {
    final isSelected = current == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text),
      ),
    );
  }
}
