import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tunely/shared/model/tune.dart';

/// Holds all playlist picker state: search query, suggestions, and the
/// ordered selection.
///
/// Contains no widget code, so it can be unit tested independently of UI.
class PlaylistSelectionController extends ChangeNotifier {
  PlaylistSelectionController({
    required List<Tune> tunes,
    List<String> initialSelected = const [],
    this.onSelectionChanged,
    this.maxSuggestions = 5,
    this.searchDebounce = const Duration(milliseconds: 200),
  }) {
    _rebuildIndex(tunes);
    _setSelection(initialSelected, notify: false);
  }

  /// Called with the ordered selected paths whenever the selection changes.
  final ValueChanged<List<String>>? onSelectionChanged;

  final int maxSuggestions;
  final Duration searchDebounce;

  Timer? _debounce;
  String _query = '';
  List<({Tune tune, String haystack})> _index = const [];
  Map<String, Tune> _tuneByPath = const {};
  List<String> _selectedPaths = [];
  Set<String> _selectedSet = {};
  int _selectionVersion = 0;
  int _tunesVersion = 0;

  List<Tune>? _suggestionsCache;
  String _suggestionsQuery = '';
  int _suggestionsVersion = -1;
  int _suggestionsTunesVersion = -1;

  String get query => _query;

  bool get hasSelection => _selectedPaths.isNotEmpty;

  int get selectedCount => _selectedPaths.length;

  List<String> get selectedPaths => List.unmodifiable(_selectedPaths);

  List<Tune> get selectedTunes => [
    for (final path in _selectedPaths) ?_tuneByPath[path],
  ];

  /// Up to [maxSuggestions] songs matching the query that are not selected.
  List<Tune> get suggestions {
    if (_suggestionsCache != null &&
        _suggestionsQuery == _query &&
        _suggestionsVersion == _selectionVersion &&
        _suggestionsTunesVersion == _tunesVersion) {
      return _suggestionsCache!;
    }

    final result = <Tune>[];
    for (final entry in _index) {
      if (_selectedSet.contains(entry.tune.path)) continue;
      if (_query.isNotEmpty && !entry.haystack.contains(_query)) continue;
      result.add(entry.tune);
      if (result.length >= maxSuggestions) break;
    }

    _suggestionsCache = result;
    _suggestionsQuery = _query;
    _suggestionsVersion = _selectionVersion;
    _suggestionsTunesVersion = _tunesVersion;
    return result;
  }

  /// Rebuilds the search index. Set [notify] to false when called from
  /// `didUpdateWidget`, where the owning widget is already rebuilding.
  void setTunes(List<Tune> tunes, {bool notify = true}) {
    _rebuildIndex(tunes);
    if (notify) notifyListeners();
  }

  /// Replaces the selection, preserving the given order. Paths that no longer
  /// exist in the current tune list are dropped.
  void setSelection(List<String> paths, {bool notify = true}) {
    _setSelection(paths, notify: notify);
  }

  /// Debounces the query before filtering. Empty input applies immediately.
  void search(String value) {
    _debounce?.cancel();
    final q = value.trim().toLowerCase();
    if (q.isEmpty) {
      _applyQuery('');
      return;
    }
    _debounce = Timer(searchDebounce, () => _applyQuery(q));
  }

  void clearSearch() {
    _debounce?.cancel();
    _applyQuery('');
  }

  void add(Tune tune) {
    if (_selectedSet.contains(tune.path)) return;
    _selectedPaths.add(tune.path);
    _selectedSet.add(tune.path);
    _selectionChanged();
  }

  void remove(String path) {
    if (!_selectedSet.remove(path)) return;
    _selectedPaths.remove(path);
    _selectionChanged();
  }

  void clearSelection() {
    if (_selectedPaths.isEmpty) return;
    _selectedPaths.clear();
    _selectedSet.clear();
    _selectionChanged();
  }

  /// Moves an item. [newIndex] is expected to be already adjusted for the
  /// removed item (as provided by `SliverReorderableList.onReorderItem`).
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _selectedPaths.length) return;
    if (newIndex < 0 || newIndex >= _selectedPaths.length) return;
    final path = _selectedPaths.removeAt(oldIndex);
    _selectedPaths.insert(newIndex, path);
    _selectionChanged();
  }

  void _selectionChanged() {
    _selectionVersion++;
    _suggestionsCache = null;
    notifyListeners();
    onSelectionChanged?.call(List.of(_selectedPaths));
  }

  void _applyQuery(String query) {
    if (_query == query) return;
    _query = query;
    _suggestionsCache = null;
    notifyListeners();
  }

  void _setSelection(List<String> paths, {required bool notify}) {
    _selectedPaths = [
      for (final path in paths)
        if (_tuneByPath.containsKey(path)) path,
    ];
    _selectedSet = _selectedPaths.toSet();
    _selectionVersion++;
    _suggestionsCache = null;
    if (notify) notifyListeners();
  }

  void _rebuildIndex(List<Tune> tunes) {
    _index = [
      for (final t in tunes)
        (
          tune: t,
          haystack: '${t.title} ${t.artist} ${t.artists.join(' ')}'
              .toLowerCase(),
        ),
    ];
    _tuneByPath = {for (final t in tunes) t.path: t};
    _tunesVersion++;
    _suggestionsCache = null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
