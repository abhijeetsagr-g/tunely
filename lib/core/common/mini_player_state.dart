import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_route.dart';

final ValueNotifier<bool> miniPlayerVisible = ValueNotifier(false);
final ValueNotifier<double> miniPlayerBottom = ValueNotifier(80);

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
    final name = route.settings.name;
    switch (name) {
      case AppRoute.player:
        miniPlayerVisible.value = false;
      case AppRoute.splash:
        miniPlayerVisible.value = false;
      case AppRoute.root:
        miniPlayerVisible.value = true;
        miniPlayerBottom.value = 20;
      default:
        miniPlayerVisible.value = true;
        miniPlayerBottom.value = 16;
    }
  }
}
