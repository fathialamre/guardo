import 'package:flutter/material.dart';

/// A simple wrapper widget for lock screen content
class LockScreen extends StatelessWidget {
  /// The child widget to display in the lock screen
  final Widget child;

  /// Background color of the lock screen
  final Color? backgroundColor;

  /// Whether to wrap in MaterialApp
  final bool wrapInMaterialApp;

  const LockScreen({
    super.key,
    required this.child,
    this.backgroundColor,
    this.wrapInMaterialApp = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(backgroundColor: backgroundColor, body: child);

    if (wrapInMaterialApp) {
      return MaterialApp(home: content);
    }

    return content;
  }
}
