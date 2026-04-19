String formatArtistName(List<String> delimiters, String artistName) {
  final pattern = RegExp(delimiters.map(RegExp.escape).join('|'));
  return artistName.replaceAll(pattern, " • ");
}
