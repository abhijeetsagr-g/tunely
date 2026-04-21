import 'package:flutter/material.dart';

enum RouteTransition { slide, fade, scale }

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required super.settings,
    required WidgetBuilder builder,
    RouteTransition transition = RouteTransition.slide,
  }) : super(
         transitionDuration: const Duration(milliseconds: 500),
         reverseTransitionDuration: const Duration(milliseconds: 400),
         pageBuilder: (context, _, _) => builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curved = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutQuint,
             reverseCurve: Curves.easeInQuint,
           );

           return switch (transition) {
             RouteTransition.slide => SlideTransition(
               position: Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                   .animate(
                     CurvedAnimation(
                       parent: animation,
                       curve: Curves.easeOutExpo,
                       reverseCurve: Curves.easeInExpo,
                     ),
                   ),
               child: child,
             ),

             RouteTransition.fade => FadeTransition(
               opacity: curved,
               child: SlideTransition(
                 position: Tween(
                   begin: const Offset(0.0, 0.04), // subtle upward drift
                   end: Offset.zero,
                 ).animate(curved),
                 child: child,
               ),
             ),

             RouteTransition.scale => ScaleTransition(
               scale: Tween(begin: 0.94, end: 1.0).animate(curved),
               child: FadeTransition(
                 opacity: curved,
                 child: SlideTransition(
                   position: Tween(
                     begin: const Offset(0.0, 0.03), // rises as it scales
                     end: Offset.zero,
                   ).animate(curved),
                   child: child,
                 ),
               ),
             ),
           };
         },
       );
}
