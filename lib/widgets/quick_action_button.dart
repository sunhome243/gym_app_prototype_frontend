// lib/widgets/quick_action_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animated_inkwell.dart'; // Make sure the path is correct for AnimatedInkWell

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedInkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}