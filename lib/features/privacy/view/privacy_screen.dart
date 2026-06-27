// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
// import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';

// import '../../../core/constants/app_strings.dart';
// import '../../../shared/components/doodle_text.dart';
// import '../../../shared/components/sticker_icon_button.dart';
// import '../../../shared/utils/interaction_feedback.dart';

// class PrivacyScreen extends StatelessWidget {
//   const PrivacyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.transparent,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         systemNavigationBarDividerColor: Colors.transparent,
//         systemStatusBarContrastEnforced: false,
//         systemNavigationBarContrastEnforced: false,
//       ),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFFFFBF3),
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
//                 child: Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: SizedBox(
//                         height: 90,
//                         // width: double.infinity,
//                         child: Stack(
//                           children: [
//                             ClipPath(
//                               clipper: AppBarClipper(),
//                               child: Container(
//                                 height: 120,
//                                 margin: EdgeInsets.only(bottom: 10),
//                                 color: const Color(0xff3b9499),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(20.0),
//                                       child: SidebarIcon(
//                                         icon: Icons.arrow_back_rounded,
//                                         assetName:
//                                             'assets/images/pop-button.png',
//                                         onPressed: () {
//                                           Navigator.pop(context);
//                                         },
//                                       ),
//                                     ),

//                                     // Title
//                                     // Title
//                                     Expanded(
//                                       child: Center(
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           child: Stack(
//                                             alignment: Alignment.center,
//                                             children: [
//                                               // Shadow Layer
//                                               Transform.translate(
//                                                 offset: const Offset(6, 6),
//                                                 child: Text(
//                                                   "PRIVACY",
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     fontSize: 30,
//                                                     fontFamily: "Regular",
//                                                     fontWeight: FontWeight.w900,
//                                                     color: Colors.black
//                                                         .withOpacity(0.35),
//                                                     letterSpacing: 1,
//                                                   ),
//                                                 ),
//                                               ),

//                                               // Pink 3D Layer
//                                               Transform.translate(
//                                                 offset: const Offset(3, 3),
//                                                 child: Text(
//                                                   "PRIVACY",
//                                                   textAlign: TextAlign.center,
//                                                   style: const TextStyle(
//                                                     fontSize: 30,
//                                                     fontFamily: "Regular",
//                                                     fontWeight: FontWeight.w900,
//                                                     color: Color(0xFFFF4FA3),
//                                                     letterSpacing: 1,
//                                                   ),
//                                                 ),
//                                               ),

//                                               // Main White Text
//                                               Text(
//                                                 "PRIVACY",
//                                                 textAlign: TextAlign.center,
//                                                 style: const TextStyle(
//                                                   fontSize: 30,
//                                                   fontFamily: "Regular",
//                                                   fontWeight: FontWeight.w900,
//                                                   color: Colors.white,
//                                                   letterSpacing: 1,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),

//                                     const SizedBox(width: 60),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Padding(
//               //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
//               //   child: Row(
//               //     children: <Widget>[
//               //       Expanded(
//               //         child: SizedBox(
//               //           height: 140,
//               //           // width: double.infinity,
//               //           child: Stack(
//               //             children: [
//               //               ClipPath(
//               //                 clipper: AppBarClipper(),
//               //                 child: Container(
//               //                   height: 140,
//               //                   color: const Color(0xff3b9499),
//               //                   child: Row(
//               //                     children: [
//               //                       Padding(
//               //                         padding: const EdgeInsets.all(8.0),
//               //                         child: SidebarIcon(
//               //                           icon: Icons.arrow_back_rounded,
//               //                           assetName:
//               //                               'assets/images/pop-button.png',
//               //                           onPressed: () {
//               //                             Navigator.pop(context);
//               //                           },
//               //                         ),
//               //                       ),

//               // // Title
//               // Expanded(
//               //   child: Center(
//               //     child: FittedBox(
//               //       fit: BoxFit.scaleDown,
//               //       child: Stack(
//               //         alignment: Alignment.center,
//               //         children: [
//               //           // Shadow Layer
//               //           Transform.translate(
//               //             offset: const Offset(6, 6),
//               //             child: Text(
//               //               "PRIVACY",
//               //               textAlign: TextAlign.center,
//               //               style: TextStyle(
//               //                 fontSize: 50,
//               //                 fontFamily: "Regular",
//               //                 fontWeight: FontWeight.w900,
//               //                 color: Colors.black
//               //                     .withOpacity(0.35),
//               //                 letterSpacing: 1,
//               //               ),
//               //             ),
//               //           ),

//               //           // Pink 3D Layer
//               //           Transform.translate(
//               //             offset: const Offset(3, 3),
//               //             child: Text(
//               //               "PRIVACY",
//               //               textAlign: TextAlign.center,
//               //               style: const TextStyle(
//               //                 fontSize: 50,
//               //                 fontFamily: "Regular",
//               //                 fontWeight: FontWeight.w900,
//               //                 color: Color(0xFFFF4FA3),
//               //                 letterSpacing: 1,
//               //               ),
//               //             ),
//               //           ),

//               //           // Main White Text
//               //           Text(
//               //             "PRIVACY",
//               //             textAlign: TextAlign.center,
//               //             style: const TextStyle(
//               //               fontSize: 50,
//               //               fontFamily: "Regular",
//               //               fontWeight: FontWeight.w900,
//               //               color: Colors.white,
//               //               letterSpacing: 1,
//               //             ),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // ),

//               //                       const SizedBox(width: 60),
//               //                     ],
//               //                   ),
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ),
//               //       ),

//               //       // SidebarIcon(
//               //       //   icon: Icons.arrow_back_rounded,
//               //       //   assetName: 'assets/images/pop-button.png',
//               //       //   onPressed: () {
//               //       //     Navigator.pop(context);
//               //       //   },
//               //       // ),

//               //       // // _HistoryIconButton(
//               //       // //   icon: Icons.arrow_back_rounded,
//               //       // //   onTap: () => Navigator.pop(context),
//               //       // // ),
//               //       // const SizedBox(width: 14),
//               //       // Expanded(
//               //       //   child: Text(
//               //       //     'Drawing History',
//               //       //     style: TextStyle(
//               //       //       fontSize: 28,
//               //       //       fontWeight: FontWeight.w700,
//               //       //       color: const Color(0xFF1F2A44),
//               //       //     ),
//               //       //   ),
//               //       // ),
//               //     ],
//               //   ),
//               // ),

//               // _SidebarIcon(

//               //   icon: Icons.arrow_back_rounded,
//               //   assetName: 'assets/images/pop-button.png',
//               //   onPressed: () {
//               //     Navigator.pop(context);
//               //   },
//               // ),
//               // const SizedBox(height: 22),
//               // const Center(
//               //   child: DoodleText(
//               //     'PRIVACY',
//               //     fontSize: 34,
//               //     fillColor: Color(0xFF1FA8F4),
//               //   ),
//               // ),

//               const SizedBox(height: 22),

//               Container(
//                 margin: EdgeInsets.all(20),
//                 padding: const EdgeInsets.all(22),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   border: Border.all(color: const Color(0xFF222222), width: 2),
//                   boxShadow: const <BoxShadow>[
//                     BoxShadow(
//                       color: Color(0x22000000),
//                       blurRadius: 0,
//                       offset: Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: const Text(
//                   'This is a temporary in-app privacy placeholder. Replace this with your final privacy text or website URL when ready.',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontFamily: "Regular",
//                     height: 1.4,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF222222),
//                   ),
//                 ),
//               ),
//               // const Spacer(),
//               // SizedBox(
//               //   width: double.infinity,
//               //   child: FilledButton(
//               //     onPressed: tapActionCallback(
//               //       context,
//               //       () => Navigator.pop(context),
//               //     ),
//               //     style: FilledButton.styleFrom(
//               //       backgroundColor: const Color(0xFF33E61F),
//               //       foregroundColor: Colors.white,
//               //       padding: const EdgeInsets.symmetric(vertical: 16),
//               //       shape: RoundedRectangleBorder(
//               //         borderRadius: BorderRadius.circular(24),
//               //       ),
//               //     ),
//               //     child: const Text(
//               //       AppStrings.back,
//               //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _SidebarIcon extends StatelessWidget {
//   const _SidebarIcon({
//     required this.icon,
//     this.assetName,
//     this.onPressed,
//   });

//   final IconData icon;
//   final String? assetName;
//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: tapActionCallback(context, onPressed),
//       child: SizedBox(
//         width: 42,
//         height: 42,
//         child: assetName != null
//             ? Image.asset(assetName!, fit: BoxFit.contain)
//             : Icon(
//                 icon,
//                 color: const Color(0xFF666666),
//                 size: 28,
//               ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  // Helper function to create styled text
  Widget _buildSection(String heading, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 5),
        Text(body, style: const TextStyle(fontSize: 15, height: 1.4)),
        const SizedBox(height: 15), // Spacing between sections
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/reward.webp"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.5),
            BlendMode.lighten,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
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
                                          assetName:
                                              'assets/images/pop-button.png',
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
                                                  "PRIVACY",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontFamily: "Regular",
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black
                                                        .withOpacity(0.35),
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),

                                              // Pink 3D Layer
                                              Transform.translate(
                                                offset: const Offset(3, 3),
                                                child: Text(
                                                  "PRIVACY",
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
                                                "PRIVACY",
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
              ),
              // Container(
              //   margin: EdgeInsets.all(20),
              //   padding: const EdgeInsets.all(16.0),
              //   decoration: BoxDecoration(
              //     color: Color(0xFFF1E4CE),
              //     border: Border.all(color: Colors.black, width: 2),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(titleText,
              //           style: const TextStyle(
              //               fontWeight: FontWeight.bold, fontSize: 19)),
              //       const Divider(thickness: 1),
              //       const SizedBox(height: 10),
              //       _buildSection(whatWeCollectHeading, whatWeCollectBody),
              //       _buildSection(whyWeCollectHeading, whyWeCollectBody),
              //       _buildSection(howWeShareHeading, howWeShareBody),
              //       _buildSection(rightsHeading, rightsBody),
              //       _buildSection(securityHeading, securityBody),
              //       _buildSection(updatesHeading, updatesBody),
              //     ],
              //   ),
              // ),

              // ... inside your build method, replace the Container with this:

              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 226, 221, 211),
                  border: Border.all(color: Color(0xff3b9499), width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Your Data, Our Care: App Privacy Polic",
                        style: const TextStyle(
                            color: Color(0xff3b9499),
                            fontWeight: FontWeight.bold,
                            fontSize: 19)),
                    const Divider(
                      thickness: 2,
                      color: Color(0xff3b9499),
                    ),
                    const SizedBox(height: 10),

                    // What We Collect
                    Text("What We Collect:",
                        style: const TextStyle(
                            color: Color(0xff3b9499),
                            fontWeight: FontWeight.bold,
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "We collect information to improve our app for you, including:\n"
                        "- Account details (username, profile info).\n"
                        "- Information from app usage and device data.\n"
                        "- Information for gift delivery: mother's name, child's name, phone number, address, and location.",
                        style: const TextStyle(
                            color: Color(0xff3b9499),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.4)),
                    const SizedBox(height: 15),

                    // Why We Collect It
                    Text("Why We Collect It:",
                        style: const TextStyle(
                            color: Color(0xff3b9499),
                            fontWeight: FontWeight.bold,
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "This helps us:\n"
                        "- Manage your coin-to-reward system.\n"
                        "- Facilitate gift delivery and reward distribution.\n"
                        "- Welcome new users with first-time login bonuses.",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            height: 1.4)),
                    const SizedBox(height: 15),

                    // How We Share
                    Text("How We Share Your Info:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "We value your privacy. We do not sell personal information. We share it only with trusted service providers to fulfill gift requests.",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            height: 1.4)),
                    const SizedBox(height: 15),

                    // Your Rights
                    Text("Your Rights & Choices:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "You can review/update your profile details in settings or contact our team for data deletion requests.",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            height: 1.4)),
                    const SizedBox(height: 15),

                    // Data Security
                    Text("Data Security:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "We employ robust security measures to protect your information.",
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            height: 1.4)),
                    const SizedBox(height: 15),

                    // Policy Updates
                    Text("Policy Updates:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3b9499),
                            fontSize: 17)),
                    const SizedBox(height: 5),
                    Text(
                        "We will notify you of any changes directly within the app.",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xff3b9499),
                            height: 1.4)),
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
