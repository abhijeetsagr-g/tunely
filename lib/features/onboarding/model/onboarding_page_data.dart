import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.body,
    this.isPermission = false,
    this.isTheme = false,
    this.imageAsset,
    this.icon,
  });

  final IconData? icon;
  final String? imageAsset;
  final String title;
  final String subtitle;
  final String body;
  final bool isPermission;
  final bool isTheme;
}
