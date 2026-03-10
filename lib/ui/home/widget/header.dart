import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour <= 11) {
      return "Good Morning";
    } else if (hour >= 12 && hour <= 17) {
      return "Bruh";
    } else if (hour >= 18 && hour <= 21) {
      return "Watch Sunset";
    } else {
      return "Sleep Tight";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        _getGreeting(),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
