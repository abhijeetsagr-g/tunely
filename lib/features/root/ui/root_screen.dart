import 'package:flutter/material.dart';
import 'package:tunely/features/root/ui/view/library/library_view.dart';
import 'package:tunely/features/search/view/search_test_view.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchTestView()),
          );
        },
      ),
      body: LibraryView(),
    );
  }
}
