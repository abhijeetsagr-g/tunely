import 'package:flutter/material.dart';
import 'package:tunely/data/model/lyric_result.dart';

class UnsyncedLyricWidget extends StatelessWidget {
  final LyricResult result;

  const UnsyncedLyricWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final lines = result.plain?.split('\n') ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: lines.map((line) {
          final isEmpty = line.trim().isEmpty;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: isEmpty ? 8 : 4),
            child: isEmpty
                ? const SizedBox.shrink()
                : Text(
                    line,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }
}
