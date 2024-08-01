import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'backButton',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ),
    );
  }
}