import 'package:flutter/material.dart';

class FadeInRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;
  final Object? arguments;

  FadeInRoute(this.page, this.routeName, {this.arguments})
      : super(
          settings: RouteSettings(name: routeName, arguments: arguments),
          pageBuilder: (context, animation, secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}
