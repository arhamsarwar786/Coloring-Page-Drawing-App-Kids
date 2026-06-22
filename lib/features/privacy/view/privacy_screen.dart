import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/components/doodle_text.dart';
import '../../../shared/components/sticker_icon_button.dart';
import '../../../shared/utils/interaction_feedback.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBF3),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
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
                                      child: SidebarIcon(
                                        icon: Icons.arrow_back_rounded,
                                        assetName:
                                            'assets/images/pop-button.png',
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
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

              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              //   child: Row(
              //     children: <Widget>[
              //       Expanded(
              //         child: SizedBox(
              //           height: 140,
              //           // width: double.infinity,
              //           child: Stack(
              //             children: [
              //               ClipPath(
              //                 clipper: AppBarClipper(),
              //                 child: Container(
              //                   height: 140,
              //                   color: const Color(0xff3b9499),
              //                   child: Row(
              //                     children: [
              //                       Padding(
              //                         padding: const EdgeInsets.all(8.0),
              //                         child: SidebarIcon(
              //                           icon: Icons.arrow_back_rounded,
              //                           assetName:
              //                               'assets/images/pop-button.png',
              //                           onPressed: () {
              //                             Navigator.pop(context);
              //                           },
              //                         ),
              //                       ),

              // // Title
              // Expanded(
              //   child: Center(
              //     child: FittedBox(
              //       fit: BoxFit.scaleDown,
              //       child: Stack(
              //         alignment: Alignment.center,
              //         children: [
              //           // Shadow Layer
              //           Transform.translate(
              //             offset: const Offset(6, 6),
              //             child: Text(
              //               "PRIVACY",
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 fontSize: 50,
              //                 fontFamily: "Regular",
              //                 fontWeight: FontWeight.w900,
              //                 color: Colors.black
              //                     .withOpacity(0.35),
              //                 letterSpacing: 1,
              //               ),
              //             ),
              //           ),

              //           // Pink 3D Layer
              //           Transform.translate(
              //             offset: const Offset(3, 3),
              //             child: Text(
              //               "PRIVACY",
              //               textAlign: TextAlign.center,
              //               style: const TextStyle(
              //                 fontSize: 50,
              //                 fontFamily: "Regular",
              //                 fontWeight: FontWeight.w900,
              //                 color: Color(0xFFFF4FA3),
              //                 letterSpacing: 1,
              //               ),
              //             ),
              //           ),

              //           // Main White Text
              //           Text(
              //             "PRIVACY",
              //             textAlign: TextAlign.center,
              //             style: const TextStyle(
              //               fontSize: 50,
              //               fontFamily: "Regular",
              //               fontWeight: FontWeight.w900,
              //               color: Colors.white,
              //               letterSpacing: 1,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              //                       const SizedBox(width: 60),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),

              //       // SidebarIcon(
              //       //   icon: Icons.arrow_back_rounded,
              //       //   assetName: 'assets/images/pop-button.png',
              //       //   onPressed: () {
              //       //     Navigator.pop(context);
              //       //   },
              //       // ),

              //       // // _HistoryIconButton(
              //       // //   icon: Icons.arrow_back_rounded,
              //       // //   onTap: () => Navigator.pop(context),
              //       // // ),
              //       // const SizedBox(width: 14),
              //       // Expanded(
              //       //   child: Text(
              //       //     'Drawing History',
              //       //     style: TextStyle(
              //       //       fontSize: 28,
              //       //       fontWeight: FontWeight.w700,
              //       //       color: const Color(0xFF1F2A44),
              //       //     ),
              //       //   ),
              //       // ),
              //     ],
              //   ),
              // ),

              // _SidebarIcon(

              //   icon: Icons.arrow_back_rounded,
              //   assetName: 'assets/images/pop-button.png',
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              // const SizedBox(height: 22),
              // const Center(
              //   child: DoodleText(
              //     'PRIVACY',
              //     fontSize: 34,
              //     fillColor: Color(0xFF1FA8F4),
              //   ),
              // ),

              const SizedBox(height: 22),

              Container(
                margin: EdgeInsets.all(20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF222222), width: 2),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'This is a temporary in-app privacy placeholder. Replace this with your final privacy text or website URL when ready.',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Regular",
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              // const Spacer(),
              // SizedBox(
              //   width: double.infinity,
              //   child: FilledButton(
              //     onPressed: tapActionCallback(
              //       context,
              //       () => Navigator.pop(context),
              //     ),
              //     style: FilledButton.styleFrom(
              //       backgroundColor: const Color(0xFF33E61F),
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(vertical: 16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(24),
              //       ),
              //     ),
              //     child: const Text(
              //       AppStrings.back,
              //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  const _SidebarIcon({
    required this.icon,
    this.assetName,
    this.onPressed,
  });

  final IconData icon;
  final String? assetName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapActionCallback(context, onPressed),
      child: SizedBox(
        width: 42,
        height: 42,
        child: assetName != null
            ? Image.asset(assetName!, fit: BoxFit.contain)
            : Icon(
                icon,
                color: const Color(0xFF666666),
                size: 28,
              ),
      ),
    );
  }
}
