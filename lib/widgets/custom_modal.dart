import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomModalTheme { blue, green, red }

class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<CustomModalAction> actions;
  final CustomModalTheme theme;
  final IconData? icon;

  const CustomModal({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.theme = CustomModalTheme.blue,
    this.icon,
  });

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(themeColors),
            const SizedBox(height: 16),
            Flexible(child: content),
            const SizedBox(height: 24),
            _buildActions(themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(_ThemeColors themeColors) {
    return Row(
      children: [
        if (icon != null)
          Icon(icon, color: themeColors.primary, size: 24),
        if (icon != null) const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(_ThemeColors themeColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions.map((action) => _buildActionButton(action, themeColors)).toList(),
    );
  }

  Widget _buildActionButton(CustomModalAction action, _ThemeColors themeColors) {
    final bool isDefaultAction = action.isDefaultAction;
    final Color textColor = isDefaultAction ? Colors.white : themeColors.primary;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: isDefaultAction ? themeColors.primary : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(
          action.text,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  _ThemeColors _getThemeColors() {
    switch (theme) {
      case CustomModalTheme.blue:
        return _ThemeColors(primary: const Color(0xFF2196F3));
      case CustomModalTheme.green:
        return _ThemeColors(primary: const Color(0xFF4CAF50));
      case CustomModalTheme.red:
        return _ThemeColors(primary: const Color(0xFFF44336));
    }
  }
}

class _ThemeColors {
  final Color primary;

  _ThemeColors({required this.primary});
}

class CustomModalAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDefaultAction;

  CustomModalAction({
    required this.text,
    required this.onPressed,
    this.isDefaultAction = false,
  });
}

// Utility function to show CustomModal
void showCustomModal({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<CustomModalAction> actions,
  CustomModalTheme theme = CustomModalTheme.blue,
  IconData? icon,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomModal(
        title: title,
        content: content,
        actions: actions,
        theme: theme,
        icon: icon,
      );
    },
  );
}