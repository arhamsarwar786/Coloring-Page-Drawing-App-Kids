import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CenterCade extends StatelessWidget {
  final String imagePath;
  final String name;
  const CenterCade({super.key, required this.imagePath, required this.name});

  @override
  Widget build(
    BuildContext context,
  ) {
    // final charColor = Color(0xff8C0000);
    return Container(
      // height: 200,
      decoration: BoxDecoration(
          // color: Colors.white,
          // borderRadius: BorderRadius.circular(32),
          // border: Border.all(color: Colors.white, width: 2),
          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   // colors: [
          //   //   Colors.white,
          //   //   // charColor.withValues(alpha: 0.05),
          //   //   // charColor.withValues(alpha: 0.15),
          //   // ],
          //   // // stops: const [0.0, 0.6, 1.0],
          // ),
          // boxShadow: [
          //   BoxShadow(
          //     color: charColor.withValues(alpha: 0.3),
          //     blurRadius: 20,
          //     offset: const Offset(0, 15),
          //   ),
          //   BoxShadow(
          //     color: charColor.withValues(alpha: 0.6),
          //     blurRadius: 0,
          //     offset: const Offset(0, 8),
          //   ),
          //   const BoxShadow(
          //     color: Colors.white,
          //     blurRadius: 0,
          //     offset: Offset(0, -2),
          //   ),
          // ],
          ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Positioned(
          //   top: -20,
          //   right: -20,
          //   child: Container(
          //     width: constraints.maxWidth * 0.6,
          //     height: constraints.maxWidth * 0.6,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       gradient: RadialGradient(
          //         colors: [
          //           charColor.withValues(alpha: 0.3),
          //           charColor.withValues(alpha: 0.0),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // Positioned(
          //   bottom: 20,
          //   left: -30,
          //   child: Container(
          //     width: constraints.maxWidth * 0.5,
          //     height: constraints.maxWidth * 0.5,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       gradient: RadialGradient(
          //         colors: [
          //           charColor.withValues(alpha: 0.2),
          //           charColor.withValues(alpha: 0.0),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final circleSize = constraints.maxWidth * 0.8;

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Circle Background
                          Container(
                            width: circleSize,
                            height: circleSize,
                            decoration: BoxDecoration(
                              // shape: BoxShape.circle,
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  // color: charColor.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 4,
                                  offset: Offset(-2, -2),
                                ),
                              ],
                            ),
                          ),

                          // Avatar Image (Perfect Proportion Control)
                          Positioned(
                            top: -circleSize *
                                0.3, // 👈 dynamic overflow (IMPORTANT)
                            bottom: circleSize * 0.04, // 👈 bottom spacing
                            left: 0,
                            right: 0,

                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                      circleSize), // 👈 dynamic radius
                                  bottomRight: Radius.circular(circleSize),
                                ),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                  // height: 500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // const SizedBox(height: 12),
                // Container(
                //   // flex: 2,
                //   child: FittedBox(
                //     fit: BoxFit.scaleDown,
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 12, vertical: 4),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(20),
                //         boxShadow: [
                //           BoxShadow(
                //             // color: charColor.withValues(alpha: 0.2),
                //             blurRadius: 8,
                //             offset: const Offset(0, 4),
                //           ),
                //         ],
                //         border: Border.all(
                //           // color: charColor.withValues(alpha: 0.1),
                //           width: 1,
                //         ),
                //       ),
                //       child: Text(
                //         name.toUpperCase(),
                //         maxLines: 1,
                //         style: GoogleFonts.outfit(
                //           fontSize: 16,
                //           fontWeight: FontWeight.w900,
                //           color: Colors.black87,
                //           letterSpacing: 1.0,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
