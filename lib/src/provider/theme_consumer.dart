import 'package:flutter/material.dart';
import '../../theme_provider.dart';

/// Wrap a widget to use the theme of the closest app theme of the [ThemeProvider].
/// If you have multiple screens, wrap each entry point with this widget.
class ThemeConsumer extends StatelessWidget {

  /// Wrap a widget to use the theme of the closest app theme of the [ThemeProvider].
  /// If you have multiple screens, wrap each entry point with this widget.
  const ThemeConsumer({final Key? key, required this.child}) : super(key: key);
  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return Theme(
      data: ThemeProvider.themeOf(context).data,
      child: child,
    );
  }
}
