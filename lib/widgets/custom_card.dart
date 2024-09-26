import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCard extends StatelessWidget {
  final String? title;
  final List<Widget>? children;
  final Widget? child;
  final Color titleColor;
  final double titleFontSize;
  final Widget? trailing;

  const CustomCard({
    Key? key,
    this.title,
    this.children,
    this.child,
    this.titleColor = Colors.black,
    this.titleFontSize = 20,
    this.trailing,
  }) : assert(children == null || child == null, 'Cannot provide both children and child'),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || trailing != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.lato(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            if (title != null || trailing != null)
              const SizedBox(height: 12),
            if (child != null)
              child!
            else if (children != null)
              ...children!,
          ],
        ),
      ),
    );
  }
}