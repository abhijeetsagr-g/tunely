import 'package:flutter/material.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({
    super.key,
    required this.controller,

    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Songs, albums, artists...',
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(100), fontSize: 15),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: cs.onSurface.withAlpha(140),
          size: 20,
        ),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (_, _) => controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: cs.onSurface.withAlpha(140),
                    size: 18,
                  ),
                  onPressed: onClear,
                )
              : const SizedBox.shrink(),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withAlpha(180),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}
