import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomModalTheme { blue, red }

class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<CustomModalAction> actions;
  final CustomModalTheme theme;
  final IconData? icon;

  const CustomModal({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.theme = CustomModalTheme.blue,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeColors = _getThemeColors();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, color: themeColors.primary, size: 28),
                if (icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: themeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((action) => _buildActionButton(action, themeColors)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(CustomModalAction action, _ThemeColors themeColors) {
    final Color buttonColor = action.backgroundColor ?? (action.isDefaultAction ? themeColors.primary : Colors.transparent);
    final Color textColor = action.textColor ?? (action.isDefaultAction ? Colors.white : themeColors.primary);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: action.isDefaultAction ? BorderSide.none : BorderSide(color: themeColors.primary),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(
          action.text,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  _ThemeColors _getThemeColors() {
    switch (theme) {
      case CustomModalTheme.blue:
        return _ThemeColors(
          primary: Colors.blue,
          secondary: Colors.blue.shade100,
        );
      case CustomModalTheme.red:
        return _ThemeColors(
          primary: Colors.red,
          secondary: Colors.red.shade100,
        );
    }
  }
}

class _ThemeColors {
  final Color primary;
  final Color secondary;

  _ThemeColors({required this.primary, required this.secondary});
}

class CustomModalAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDefaultAction;
  final Color? backgroundColor;
  final Color? textColor;

  CustomModalAction({
    required this.text,
    required this.onPressed,
    this.isDefaultAction = false,
    this.backgroundColor,
    this.textColor,
  });
}