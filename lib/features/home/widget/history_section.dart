import 'package:flutter/material.dart';
import 'package:tunely/features/home/widget/recent_list.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: RecentList());
  }
}
