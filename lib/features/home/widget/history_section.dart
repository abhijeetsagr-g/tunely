import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/features/history/history_cubit.dart';
import 'package:tunely/features/home/widget/most_played_list.dart';
import 'package:tunely/features/home/widget/recent_list.dart';

class HistorySection extends StatefulWidget {
  const HistorySection({super.key});

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        final isEmpty = state.recentTunes.isEmpty && state.topTunes.isEmpty;
        if (isEmpty) return const SliverToBoxAdapter(child: SizedBox());

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: SizedBox(
                  height: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        // height: 330,
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i),
                          children: const [RecentList(), MostPlayedList()],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(2, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
