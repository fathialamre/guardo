import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A simple wrapper widget for lock screen content
class LockScreen extends StatelessWidget {
  /// The child widget to display in the lock screen
  final Widget child;

  /// Background color of the lock screen
  final Color? backgroundColor;

  /// Whether to wrap in MaterialApp
  final bool wrapInMaterialApp;

  /// Semantic label for the lock screen
  final String? semanticLabel;

  const LockScreen({
    super.key,
    required this.child,
    this.backgroundColor,
    this.wrapInMaterialApp = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: backgroundColor,
      body: Semantics(
        label: semanticLabel ?? 'Application lock screen',
        child: child,
      ),
    );

    if (wrapInMaterialApp) {
      return MaterialApp(
        home: content,
        theme: ThemeData(
          // Ensure good contrast for accessibility
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      );
    }

    return content;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(FlagProperty('wrapInMaterialApp', value: wrapInMaterialApp));
    properties.add(StringProperty('semanticLabel', semanticLabel));
  }
}
