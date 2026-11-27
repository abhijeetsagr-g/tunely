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

    // Song Lyrics
    "You Got That Yummy-yum",
    "Once I Was Seven Years Old",
    "Bye Bye Bye",
    "I'll be there for you (clap)",

    // Games
    "Life is...weird",
  ];
  messages.shuffle();

  return messages.first;
}
