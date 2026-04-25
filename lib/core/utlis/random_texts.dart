String randomMessages() {
  final List<String> messages = [
    "What's Your Favourate Scary Movie?",
    "Good Day",
    "Good Night Ig?",
    "You And Me Against The World",
    "...Assemble",
    "Numbers Are Cool",
    "Simple Yet Smart",
    "Better then your ex",
    "hey babygirl",

    // Song Lyrics
    "You Got That Yummy-yum",
    "Despacito",
    "Once I Was Seven Years Old",
    "You Look Perfect Tonight",
  ];
  messages.shuffle();

  return messages.first;
}
