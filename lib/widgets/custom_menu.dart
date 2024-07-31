import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animated_inkwell.dart';

class CustomMenuItem {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? color;

  CustomMenuItem({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });
}

class CustomMenu extends StatelessWidget {
  final List<CustomMenuItem> items;
  final Offset tapPosition;

  const CustomMenu({super.key, required this.items, required this.tapPosition});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _calculateMenuLeftPosition(context),
      top: _calculateMenuTopPosition(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) => _buildMenuItem(item, context)).toList(),
          ),
        ),
      ),
    );
  }

  double _calculateMenuLeftPosition(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size overlaySize = overlay.size;
    const double menuWidth = 200; 

    double left = tapPosition.dx;

    if (left + menuWidth > overlaySize.width) {
      left = overlaySize.width - menuWidth;
    }

    return left;
  }

  double _calculateMenuTopPosition(BuildContext context) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size overlaySize = overlay.size;
    final double menuHeight = (items.length * 48).toDouble(); // Adjust 48 if item height changes

    double top = tapPosition.dy - menuHeight; 

    if (top < 0) {
      top = tapPosition.dy + 20; 
    }

    return top;
  }

  Widget _buildMenuItem(CustomMenuItem item, BuildContext context) {
    return AnimatedInkWell( // Make sure AnimatedInkWell is correctly imported
      onTap: () {
        Navigator.of(context).pop(); 
        item.onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (item.color ?? Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.color ?? Colors.blue, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              item.text,
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomMenu(BuildContext context, Offset tapPosition, List<CustomMenuItem> items) {
  OverlayEntry? menuOverlay;

  menuOverlay = OverlayEntry(
    builder: (context) => Stack( // <-- Use a Stack here
      children: [
        GestureDetector(
          onTap: () {
            menuOverlay?.remove();
          },
          child: Container(
            color: Colors.transparent,
          ),
        ),
        CustomMenu(items: items, tapPosition: tapPosition),
      ],
    ),
  );

  Overlay.of(context).insert(menuOverlay);
}