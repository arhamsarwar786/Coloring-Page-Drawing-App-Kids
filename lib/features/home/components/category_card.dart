


// import 'package:flutter/material.dart';

// class CategoryCard extends StatelessWidget {
//   final String title;
//   final String ? imagePath; // Agar assets se icon lagana ho
//   final Widget? iconWidget; // Agar direct widget pass karna ho (like Icons ya Custom Image)
//   final Color baseColor;
//   final Color borderColor;
//   final VoidCallback onTap;

//   const CategoryCard({
//     Key? key,
//     required this.title,
//     this.imagePath,
//     this.iconWidget,
//     required this.baseColor,
//     required this.borderColor,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         // Outer Container for the thick border look
//         padding: const EdgeInsets.all(5.0), // Border thickness control karta hai
//         decoration: BoxDecoration(
//           color: borderColor,
//           borderRadius: BorderRadius.circular(28.0), // Rounded corners like image
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.15),
//               blurRadius: 4,
//               offset: const Offset(0, 4), // Bottom shadow
//             ),
//           ],
//         ),
//         child: Container(
//           // Inner Container for main body
//           decoration: BoxDecoration(
//             color: baseColor,
//             borderRadius: BorderRadius.circular(23.0), // Slightly smaller radius for inner content
//           ),
//           child: Stack(
//             children: [
//               // 1. Top-Left White Glossy Highlight Effect (Same to same game style look)
//               Positioned(
//                 top: 6,
//                 left: 10,
//                 child: Container(
//                   width: 25,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.4),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
              
//               // 2. Main Content (Icon + Text)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // Icon/Image Section
//                     Expanded(
//                       child: Center(
//                         child: iconWidget ?? (imagePath != null 
//                             ? Image.asset(imagePath!, fit: BoxFit.contain)
//                             : const SizedBox()),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     // Text Section with proper styling
//                     Text(
//                       title.toUpperCase(),
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w900, // Extra Bold fonts like cartoons/games
//                         letterSpacing: 0.5,
//                         shadows: [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 2.0,
//                             color: Colors.black, // Text drop shadow
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String? imagePath;
  final Color baseColor;
  final Color borderColor;
  final VoidCallback onTap;

  const CategoryCard({
    Key? key,
    required this.title,
    this.imagePath,
    required this.baseColor,
    required this.borderColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5.0), // Border thickness
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [borderColor.withOpacity(0.8), borderColor],
          ),
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(23.0),
          ),
          child: Stack(
            children: [
              // Top-Left Glossy Highlight Effect
              Positioned(
                top: 6,
                left: 10,
                child: Container(
                  width: 25,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic Image
                    Expanded(
                      child: Center(
                        child: imagePath != null
    ? Image.asset(imagePath!, fit: BoxFit.contain)
    : Icon(Icons.image_not_supported, size: 48, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Dynamic Text
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 2.0,
                            color: Colors.black,
          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


