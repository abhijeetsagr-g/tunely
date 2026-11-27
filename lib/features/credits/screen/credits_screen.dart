import 'package:flutter/material.dart';
import 'package:tunely/features/credits/data/credits_data.dart';
import 'package:tunely/features/credits/widget/rolling_credits_list.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _CreditsBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.keyboard_arrow_left),
                      ),
                      Expanded(
                        child: Text(
                          'Credits',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: RollingCreditsList(entries: appCredits)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditsBackground extends StatelessWidget {
  const _CreditsBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 1.0],
          colors: [
            colorScheme.primary.withAlpha(isDark ? 70 : 35),
            colorScheme.surface.withAlpha(isDark ? 30 : 10),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
