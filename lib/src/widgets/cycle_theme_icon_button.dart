import 'package:flutter/material.dart';

import '../provider/theme_provider.dart';

/// Simple [IconButton] which cycles themes when pressed.
/// Use as a descendant of [ThemeProvider].
class CycleThemeIconButton extends StatelessWidget {

  const CycleThemeIconButton({final Key? key, this.icon = Icons.palette})
      : super(key: key);
  final IconData icon;

  @override
  Widget build(final BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: ThemeProvider.controllerOf(context).nextTheme,
    );
  }
}
