import 'package:flutter/material.dart';
import 'package:tunely/features/playback/view/player_view.dart';
import 'package:tunely/features/root/ui/view/library/library_view.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayerView()),
          );
        },
      ),
      body: LibraryView(),
    );
  }
}
