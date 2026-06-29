import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  // final VoidCallback? backOnPressed;
  const CustomAppBar({
    super.key,
    required this.title,
    // this.backOnPressed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              height: 90,
              // width: double.infinity,
              child: Stack(
                children: [
                  ClipPath(
                    clipper: AppBarClipper(),
                    child: Container(
                      height: 120,
                      margin: EdgeInsets.only(bottom: 10),
                      color: const Color(0xff3b9499),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Tooltip(
                              message: "Back",
                              child: SidebarIcon(
                                icon: Icons.arrow_back_rounded,
                                assetName: 'assets/images/pop-button.png',
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),

                          // Title
                          // Title
                          Expanded(
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Shadow Layer
                                    Transform.translate(
                                      offset: const Offset(6, 6),
                                      child: Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontFamily: "Regular",
                                          fontWeight: FontWeight.w900,
                                          color: const Color.fromARGB(
                                                  255, 173, 162, 162)
                                              .withOpacity(0.35),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),

                                    // Pink 3D Layer
                                    Transform.translate(
                                      offset: const Offset(3, 3),
                                      child: Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 30,
                                          fontFamily: "Regular",
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFFF4FA3),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),

                                    // Main White Text
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontFamily: "Regular",
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class AppBar extends StatelessWidget {
//   final String title;
//   const AppBar({
//     super.key,
//     required this.title,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
//       child: SizedBox(
//         height: 90,
//         child: Stack(
//           children: [
//             ClipPath(
//               clipper: AppBarClipper(),
//               child: Container(
//                 height: 120,
//                 color: const Color(0xff3b9499),
//                 child: Row(
//                   children: [
//                     // Back Button
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: Tooltip(
//                         message: "Back",
//                         child: SidebarIcon(
//                           icon: Icons.arrow_back_rounded,
//                           assetName: 'assets/images/pop-button.png',
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ),
//                     ),

//                     // Title Area - Centered
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                             right: 80.0), // Offsets the back button
//                         child: FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // Shadow Layer
//                               Transform.translate(
//                                 offset: const Offset(6, 6),
//                                 child: Text(title,
//                                     style: _textStyle(
//                                         Colors.black.withOpacity(0.35))),
//                               ),
//                               // Pink 3D Layer
//                               Transform.translate(
//                                 offset: const Offset(3, 3),
//                                 child: Text(title,
//                                     style: _textStyle(const Color(0xFFFF4FA3))),
//                               ),
//                               // Main White Text
//                               Text(title, style: _textStyle(Colors.white)),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper to keep code clean
//   TextStyle _textStyle(Color color) => TextStyle(
//         fontSize: 30,
//         fontFamily: "Regular",
//         fontWeight: FontWeight.w900,
//         color: color,
//         letterSpacing: 1,
//       );
// }
