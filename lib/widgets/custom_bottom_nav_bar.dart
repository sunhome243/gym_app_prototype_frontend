import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<CustomBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items
              .asMap()
              .entries
              .map(
                (entry) => _buildNavItem(context, entry.key, entry.value),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, CustomBottomNavItem item) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          _onItemTapped(context, index);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 0.8),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Icon(
          item.icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    onIndexChanged(index);

    if (items[index].targetScreen != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder( 
          pageBuilder: (context, animation1, animation2) => items[index].targetScreen!,
          transitionDuration: Duration.zero, 
        ),
      );
    }
  }
}

class CustomBottomNavItem {
  final IconData icon;
  final Widget? targetScreen;

  CustomBottomNavItem({
    required this.icon,
    this.targetScreen,
  });
}