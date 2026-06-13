import 'package:flutter/material.dart';

class HomeSections extends StatelessWidget {
  const HomeSections({
    super.key,
    required this.headline,
    this.onTap,
    this.onTapTitle = "Reload",
    this.child,
  });

  final String headline;
  final String onTapTitle;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                headline,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (onTap != null)
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  onPressed: onTap,
                  label: Text(onTapTitle),
                  icon: const Icon(Icons.keyboard_arrow_right),
                ),
            ],
          ),

          ?child,
        ],
      ),
    );
  }
}
