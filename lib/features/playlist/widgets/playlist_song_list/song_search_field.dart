import 'package:flutter/material.dart';

/// Search field used to filter the "Add Songs" suggestions.
class SongSearchField extends StatefulWidget {
  const SongSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<SongSearchField> createState() => _SongSearchFieldState();
}

class _SongSearchFieldState extends State<SongSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: 'Search songs',
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(100), fontSize: 15),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: cs.onSurface.withAlpha(140),
          size: 20,
        ),
        suffixIcon: ListenableBuilder(
          listenable: _controller,
          builder: (_, _) => _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: cs.onSurface.withAlpha(140),
                    size: 18,
                  ),
                  onPressed: _clear,
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
