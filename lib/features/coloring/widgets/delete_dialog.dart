// import 'package:flutter/material.dart';
// import 'package:play_craft_kids/core/constants/app_strings.dart';
// import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
// import 'package:play_craft_kids/features/settings/viewmodel/settings_viewmodel.dart';
// import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';
// import 'package:provider/provider.dart';

// class DeleteDialog extends StatelessWidget {
//   const DeleteDialog({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () =>
//           Navigator.pop(context), // Background tap karne par dialog close hoga
//       child: Material(
//         borderRadius: BorderRadius.circular(36),
//         color: Colors.transparent,
//         child: GestureDetector(
//           onTap: () {}, // Dialog ke andar tap karne par dialog band nahi hoga
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               // Main Clay Styled Box Structure Container
//               Container(
//                 width: 290,
//                 height: 290,
//                 padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
//                 decoration: BoxDecoration(
//                   color:
//                       const Color(0xFFC7A885), // Outer darker clay base plate
//                   borderRadius: BorderRadius.circular(36.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 12,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: const Color(
//                         0xFFF1E4CE), // Inner main smooth clay body surface
//                     borderRadius: BorderRadius.circular(26.0),
//                   ),
//                   child: Consumer<SettingsViewModel>(
//                     builder: (_, viewModel, __) {
//                       return Column(
//                         children: [
//                           const SizedBox(height: 16),
//                           // Heading Banner Header
//                           DialogHeaderBanner(
//                               text: AppStrings.settingsTitle.toUpperCase()),
//                           const SizedBox(height: 28),

//                           // // Core Utility Options Configuration Row (Logic + Image Assets Added!)
//                           // Row(
//                           //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           //   children: [
//                           //     // Music Icon Tile Button
//                           //     CustomVolumeDialIcon(
//                           //       assetName: viewModel.musicEnabled
//                           //           ? 'assets/images/music.png'
//                           //           : 'assets/images/music-off.png',
//                           //       onTap: viewModel.toggleMusic,
//                           //     ),

//                           //     // Sound Effects Icon Tile Button
//                           //     // CustomVolumeDialIcon(
//                           //     //   assetName: viewModel.soundEnabled
//                           //     //       ? 'assets/images/sound.png'
//                           //     //       : 'assets/images/sound-off.png',
//                           //     //   onTap: viewModel.toggleSound,
//                           //     // ),
//                           //   ],
//                           // ),

//                           const Spacer(),

//                           // Embedded Action Button Action Layer (Privacy Policy Logic Triggered)
//                           // GestureDetector(
//                           //   onTap: tapActionCallback(context, () {
//                           //     return Navigator.pushNamed(
//                           //       context,
//                           //       AppRoutes.privacy,
//                           //     );
//                           //   }),
//                           //   child: const GameMenuActionButton(
//                           //       label: "PRIVACY POLICY"),
//                           // ),
//                           const SizedBox(height: 18),
//                           // const SizedBox(height: 10),

//                           // GestureDetector(
//                           //   onTap: () async {
//                           //     final shouldLogout = await showDialog<bool>(
//                           //       context: context,
//                           //       builder: (context) => AlertDialog(
//                           //         title: const Text('Logout'),
//                           //         content: const Text(
//                           //           'Are you sure you want to logout?',
//                           //         ),
//                           //         actions: [
//                           //           TextButton(
//                           //             onPressed: () =>
//                           //                 Navigator.pop(context, false),
//                           //             child: const Text('Cancel'),
//                           //           ),
//                           //           TextButton(
//                           //             onPressed: () =>
//                           //                 Navigator.pop(context, true),
//                           //             child: const Text('Logout'),
//                           //           ),
//                           //         ],
//                           //       ),
//                           //     );

//                           //     if (shouldLogout == true) {
//                           //       await Supabase.instance.client.auth.signOut();

//                           //       Navigator.push(
//                           //           context,
//                           //           MaterialPageRoute(
//                           //               builder: (_) => const LoginScreen()));
//                           //       // pushNamedAndRemoveUntil(
//                           //       //   context,
//                           //       //   AppRoutes.login,
//                           //       //   (route) => false,
//                           //       // );
//                           //     }
//                           //   },
//                           //   // onTap: () async {
//                           //   //   await Supabase.instance.client.auth.signOut();

//                           //   //   Navigator.pushNamedAndRemoveUntil(
//                           //   //     context,
//                           //   //     AppRoutes.login,
//                           //   //     (route) => false,
//                           //   //   );
//                           //   // },
//                           //   // child: const GameMenuActionButton(
//                           //   //   label: "LOGOUT",
//                           //   // ),
//                           // ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),

//               // Circular External Close Frame Controller (Top Right Cross Button Logic)
//               Positioned(
//                 top: -10,
//                 right: -10,
//                 child: StickerIconButton(
//                   icon: Icons.arrow_back_rounded,
//                   assetName: 'assets/images/close.png',
//                   size: 48,
//                   backgroundColor: Colors.white,
//                   iconColor: const Color(0xFF17A7F2),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 // GestureDetector(
//                 //   onTap: () => Navigator.pop(
//                 //       context), // Click karne par pop out/close hoga
//                 //   child: const DialogDismissButton(),
//                 // ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';

class DeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm; // Delete ka action yahan se aayega
  final VoidCallback ontap;
  const DeleteDialog({super.key, required this.onConfirm, required this.ontap});

  @override
  Widget build(BuildContext context) {
    // final provider = widget.provider;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Dialog ke andar click band na ho
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7A885),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "DELETE ?",
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Regular",
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B3FE4),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // No Button
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent),
                              child: const Text(
                                "NO",
                              ),
                            ),
                            // Yes Button
                            ElevatedButton(
                              onPressed: () {
                                ontap();
                                // onConfirm(); // Delete logic trigger
                                Navigator.pop(context); // Dialog close
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text("YES"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
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

class UndoDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const UndoDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 300,
                  height: 220,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7A885),
                    borderRadius: BorderRadius.circular(36.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E4CE),
                      borderRadius: BorderRadius.circular(26.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "UNDO?", // Yahan Undo likha hai
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B3FE4),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("NO"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onConfirm(); // Yahan Undo ka logic chalega
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text("YES"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Close button yahan pehle ki tarah...
                Positioned(
                  top: -10,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close,
                    assetName: 'assets/images/close.png',
                    size: 48,
                    backgroundColor: Colors.white,
                    iconColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
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
