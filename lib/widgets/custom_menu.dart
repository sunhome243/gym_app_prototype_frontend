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

  const CustomMenu({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) => _buildMenuItem(item, context)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(CustomMenuItem item, BuildContext context) {
    return AnimatedInkWell(
      onTap: () {
        Navigator.of(context).pop();
        item.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.color ?? Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Text(
              item.text,
              style: GoogleFonts.lato(
                color: item.color ?? Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomMenu(BuildContext context, Offset position, List<CustomMenuItem> items) {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final RelativeRect positionRect = RelativeRect.fromRect(
    Rect.fromPoints(position, position),
    Offset.zero & overlay.size,
  );

  showMenu(
    context: context,
    position: positionRect,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    elevation: 4,
    items: [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: CustomMenu(items: items),
      ),
    ],
  );
}