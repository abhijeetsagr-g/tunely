String randomMessages() {
  final List<String> messages = [
    "What's Your Favourate Scary Movie?",
    "Good Day",
    "Good Night Ig?",
    "...Assemble",
    "Numbers Are Cool",
    "Simple Yet Smart",
    "Better then your ex",
    "Simply Lovely",
    "You can do better later",
    "Technoblade Never Dies",

    // Song Lyrics
    "You Got That Yummy-yum",
    "Despacito",
    "Once I Was Seven Years Old",
    "Bye Bye Bye",
    "I'll be there for you (clap)",
  ];
  messages.shuffle();

  return messages.first;
}
