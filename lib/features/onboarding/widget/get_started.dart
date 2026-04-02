import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_const.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),
            Image.asset(AppConst.primaryIcon, height: 120),
            Text(
              "Your Tunes",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Experience your favorite songs with synced lyrics and smooth playback.",
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Let's get you in",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                FloatingActionButton(
                  onPressed: onTap,
                  child: const Icon(Icons.play_arrow),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Created with love and Flutter❣️",
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
