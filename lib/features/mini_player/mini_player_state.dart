import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';

final ValueNotifier<bool> miniPlayerVisible = ValueNotifier(true);
final ValueNotifier<double> miniPlayerBottom = ValueNotifier(16);

class MiniPlayerObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _update(route);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null) _update(previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) _update(newRoute);
  }

  void _update(Route route) {
    if (route is PopupRoute) {
      miniPlayerVisible.value = false;
      return;
    }

    final name = route.settings.name;

    switch (name) {
      case AppRoute.player:
      case AppRoute.lyrics:
      case AppRoute.splash:
      case AppRoute.onboard:
        miniPlayerVisible.value = false;
        break;

      case AppRoute.root:
        miniPlayerVisible.value = true;
        miniPlayerBottom.value = 100;
        break;

      default:
        miniPlayerVisible.value = true;
        miniPlayerBottom.value = 16;
    }
  }
}
