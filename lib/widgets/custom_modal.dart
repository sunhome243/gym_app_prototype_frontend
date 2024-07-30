import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final Color? titleColor;
  final IconData? icon;
  final Color? iconColor;

  const CustomModal({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.titleColor,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? Colors.blue, size: 30),
                if (icon != null)
                  const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: titleColor ?? Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}