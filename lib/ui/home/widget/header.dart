import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour <= 11) {
      return "Morning Sunshine";
    } else if (hour >= 12 && hour <= 17) {
      return "MidDay Fun";
    } else if (hour >= 18 && hour <= 21) {
      return "Good Evening";
    } else {
      return "Nighty Night";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(fontWeight: .bold, fontSize: 28),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
    );
  }
}
