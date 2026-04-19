import 'package:flutter/material.dart';
import 'package:tunely/features/root/ui/view/home/home_view.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: HomeView());
  }
}
