import 'package:flutter/material.dart';

enum RouteTransition { slide, fade, scale }

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required super.settings,
    required WidgetBuilder builder,
    RouteTransition transition = RouteTransition.slide,
  }) : super(
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 250),
         pageBuilder: (context, _, _) => builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           return switch (transition) {
             RouteTransition.slide => SlideTransition(
               position: Tween(
                 begin: const Offset(1.0, 0.0),
                 end: Offset.zero,
               ).animate(curved),
               child: child,
             ),
             RouteTransition.fade => FadeTransition(
               opacity: curved,
               child: child,
             ),
             RouteTransition.scale => ScaleTransition(
               scale: Tween(begin: 0.92, end: 1.0).animate(curved),
               child: FadeTransition(opacity: curved, child: child),
             ),
           };
         },
       );
}
