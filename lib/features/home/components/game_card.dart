// import 'package:flutter/material.dart';

// class GameCard extends StatelessWidget {
//   final String title;
//   final String imagePath;
//   final Color mainColor;       // Card ka main center color
//   final Color borderColor;     // Card ka dark outer border
//   final Color? innerBoxColor;  // Image ke peeche jo light box hai (Image 2 ke liye)
//   final double aspectRatio;    // Card ki shape control karne ke liye
//   final VoidCallback onTap;

//   const GameCard({
//     Key? key,
//     required this.title,
//     required this.imagePath,
//     required this.mainColor,
//     required this.borderColor,
//     this.innerBoxColor,        // Yeh optional hai, na do toh Image 1 jaisa banega
//     this.aspectRatio = 0.85,   // Default ratio broad look ke liye
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AspectRatio(
//         aspectRatio: aspectRatio,
//         child: Container(
//           // Outer Border Layer (Thick game style border)
//           padding: const EdgeInsets.only(bottom: 6.0, left: 4.0, right: 4.0, top: 4.0),
//           decoration: BoxDecoration(
//             color: borderColor,
//             borderRadius: BorderRadius.circular(24.0),
//             boxShadow: [
//               // Bottom dark shadow for 3D effect
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.25),
//                 blurRadius: 5,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Container(
//             // Main Color Body
//             decoration: BoxDecoration(
//               color: mainColor,
//               borderRadius: BorderRadius.circular(18.0),
//             ),
//             child: Stack(
//               children: [
//                 // 1. Glossy White Top Shine
//                 Positioned(
//                   top: 5,
//                   left: 8,
//                   child: Container(
//                     width: 22,
//                     height: 7,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.4),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 // 2. Main Layout Content
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       // Image Area
//                       Expanded(
//                         child: innerBoxColor != null
//                             ? Container(
//                                 // Agar innerBoxColor diya hai (Image 2 style)
//                                 width: double.infinity,
//                                 margin: const EdgeInsets.only(bottom: 4),
//                                 decoration: BoxDecoration(
//                                   color: innerBoxColor,
//                                   borderRadius: BorderRadius.circular(14.0),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Image.asset(imagePath, fit: BoxFit.contain),
//                                 ),
//                               )
//                             : Center(
//                                 // Agar normal full size chahiye (Image 1 style)
//                                 child: Image.asset(imagePath, fit: BoxFit.contain),
//                               ),
//                       ),

//                       // Title Text Area
//                       const SizedBox(height: 4),
//                       Text(
//                         title.toUpperCase(),
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: innerBoxColor != null ? Colors.black: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w900, // Thick Cartoon Font look
//                           letterSpacing: 0.6,
//                           shadows: innerBoxColor != null ? [] : [
//                             const Shadow(
//                               offset: Offset(0, 1.5),
//                               blurRadius: 1.5,
//                               color: Colors.black38,
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isLocked;
  final dynamic palette; // Aapka custom _CardPalette yahan accept hoga
  final double aspectRatio;
  final VoidCallback onTap;

  const GameCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.isLocked,
    required this.palette,
    required this.aspectRatio,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Game themes ke standard colors set ho rahe hain aapki palette se
    final Color mainColor = isLocked ? Colors.grey.shade400 : palette.outerTop;
    final Color borderColor = isLocked ? Colors.grey.shade600 : palette.edge;

    // Image 2 jaisa inner shape cutout background box layer
    final Color innerBoxColor =
        isLocked ? Colors.grey.shade300 : Colors.white.withOpacity(0.35);

    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          // 1. Outer 3D Thick Border Layer
          padding: const EdgeInsets.only(
              bottom: 7.0, left: 4.0, right: 4.0, top: 4.0),
          decoration: BoxDecoration(
            color: borderColor,
            borderRadius: BorderRadius.circular(26.0),
            boxShadow: [
              // Bottom dark pop-shadow for 3D bounce feedback
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            // 2. Main Color Card Body
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Stack(
              children: [
                // 3. Top-Left Glossy Bubble Shine Effect (Same as Image)
                Positioned(
                  top: 6,
                  left: 10,
                  child: Container(
                    width: 24,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // 4. Content Layout (Inner Box Image + Text)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Column(
                    children: [
                      // Inner Cutout Container for Cartoon Image
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: innerBoxColor,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Bold Game Title Text Layer
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isLocked ? Colors.grey.shade700 : Colors.white,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900, // Extra thick blocky font look
                          letterSpacing: 0.5,
                          shadows: isLocked
                              ? []
                              : [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 2.0,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
