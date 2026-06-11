import 'package:flutter/material.dart';

Widget AppBottomBar({
  required Widget child,
  required Color topColor,
  required Color bottomColor,
  required VoidCallback onTap,
  required bool isSelected, // <-- 1. Yeh naya parameter add kiya hai
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            topColor,
            bottomColor,
          ],
        ),
        // 2. Agar click hoga (isSelected true hoga) toh border mota aur prominent ho jayega
        border: Border.all(
          color: isSelected
              ? const Color.fromARGB(255, 253, 235, 68)
              // Selected button ka border color (e.g., White ya koi aur sharp color)
              : Colors.white,
          width: isSelected
              ? 4.0
              : 1.8, // Click hone par border mota (4.0) ho jayega
        ),
        boxShadow: [
          // outer shadow (Selected hone par shadow thodi barha di hai taake prominent lage)
          BoxShadow(
            color: isSelected
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.18),
            blurRadius: isSelected ? 8 : 6,
            offset: const Offset(0, 4),
          ),
          // inner dark bottom effect
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glossy top shine
          Positioned(
            top: 7,
            child: Container(
              width: 30,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),

          // icon

          SizedBox(
            width: 40,
            height: 40,
            child: child,
          )
        ],
      ),
    ),
  );
}
