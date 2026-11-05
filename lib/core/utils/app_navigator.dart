import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';

/// The app's root navigator.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

BuildContext? get rootNavigatorOverlayContext =>
    rootNavigatorKey.currentState?.overlay?.context;

/// Restarts the app UI by returning to the splash screen.
void reloadApp() {
  final navigator = rootNavigatorKey.currentState;
  if (navigator == null) return;

  navigator.pushNamedAndRemoveUntil(AppRoute.splash, (route) => false);
}
