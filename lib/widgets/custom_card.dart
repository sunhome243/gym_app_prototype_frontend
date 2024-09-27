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
    super.key,
    this.title,
    this.children,
    this.child,
    this.titleColor = Colors.black,
    this.titleFontSize = 18,
    this.trailing,
  }) : assert(children == null || child == null,
            'Cannot provide both children and child');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 이 줄을 추가
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || trailing != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: GoogleFonts.lato(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: child ??
                (children != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children!,
                      )
                    : Container()),
          ),
        ],
      ),
    );
  }
}
