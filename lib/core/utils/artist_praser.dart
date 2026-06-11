class ArtistParser {
  static List<String> parse(String raw, List<String> delimiters) {
    if (raw.isEmpty || raw == '<unknown>') return ['Unknown Artist'];
    if (delimiters.isEmpty) return [raw.trim()];

    // build regex pattern from delimiters (escaped)
    final pattern = delimiters.map(RegExp.escape).join('|');
    final regex = RegExp(pattern);

    return raw
        .split(regex)
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();
  }
}
