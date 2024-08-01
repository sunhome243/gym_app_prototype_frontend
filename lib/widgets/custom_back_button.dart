import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 24,
          color: Colors.black87,
        ),
      ),
    );
  }
}