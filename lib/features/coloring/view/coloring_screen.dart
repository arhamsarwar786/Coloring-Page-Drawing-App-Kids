import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/coloring/view/coloring_completion_screen.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/coloring/widgets/coloring_board.dart';
import 'package:play_craft_kids/features/coloring/widgets/delete_dialog.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/levels/model/level_model.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({
    Key? key,
    this.imagePath,
    this.level, // optional: pass to enable points callbacks
  }) : super(key: key);

  final String? imagePath;

  /// The [LevelModel] being played. When provided, [HomeViewModel.addCompletionPoints]
  /// is called automatically when the coloring activity finishes.
  final LevelModel? level;

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  ColoringProvider? _provider;
  bool _didNavigateToCompletion = false;
  var loader = false;
  @override
  void initState() {
    super.initState();
    // MusicService.instance.stopBackgroundMusic();

    // Register provider listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = Provider.of<ColoringProvider>(context, listen: false);
      _provider?.addListener(_onProviderChange);
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    // MusicService.instance.stopLetterSound();
    // MusicService.instance.startBackgroundMusic();
    super.dispose();
  }

  void _onProviderChange() async {
    final provider = _provider;
    if (provider == null || !mounted) return;

    // Reset flag if the user hit "Try Again" and the provider is no longer complete
    if (!provider.isPartByPartComplete && _didNavigateToCompletion) {
      _didNavigateToCompletion = false;
    }

    if (provider.isPartByPartComplete && !_didNavigateToCompletion) {
      _didNavigateToCompletion = true;

      // Award completion points via HomeViewModel (if level was passed in)
      if (widget.level != null && mounted) {
        try {
          await context.read<HomeViewModel>().addCompletionPoints(0);
        } catch (_) {
          // HomeViewModel not in tree — skip silently
        }
      }

      // Slower zoom duration is 1.2s, let's wait 1.8s for the full zoom out & settle down!
      await Future.delayed(const Duration(milliseconds: 1800));

      if (!mounted) return;

      provider.calculateScore();
      final img = await provider.captureMasterpiece(
        const Size(400, 400),
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ColoringCompletionScreen(coloredImage: img),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        // !loader
        //     ? Scaffold(
        //         body: Center(
        //           child: CircularProgressIndicator(),
        //         ),
        //       )
        //     :
        Consumer<ColoringProvider>(
      builder: (context, provider, _) {
        // final itemName = provider.currentItem?.label ?? "Drawing";

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // ── Compact Header ──────────────────────────────────────────
                  // Back button | Animal title | 👆 hint icon | 🔍 zoom toggle
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SidebarIcon(
                          icon: Icons.arrow_back_rounded,
                          assetName: 'assets/images/pop-button.png',
                          // onPressed: () {
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  BackNavigationDialog(screenContext: context),
                            );
                            // };
                            // Pop back to home levels screen (not all the way to root)
                            // Navigator.of(context).pop();
                          },
                        ),

                        // // ── Coin counter badge ─────────────────────────────────────────

                        // ── Coin counter badge ─────────────────────────────────────────
                        Consumer<HomeViewModel>(
                          builder: (context, homeVM, _) {
                            // Session check
                            final session =
                                Supabase.instance.client.auth.currentSession;
                            final bool isLoggedIn = session != null;
                            final coins = homeVM.databaseCoins;
                            // final coins = homeVM.earnedCoins;

                            return GestureDetector(
                              onTap: () {
                                if (!isLoggedIn) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LoginScreen()));
                                } else {
                                  // Logged in hai, toh apna modal ya action yahan call karo
                                  print("User logged in, coins: $coins");
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutBack,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD700),
                                      Color(0xFFFF9100)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withOpacity(0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),

                                // duration: const Duration(milliseconds: 400),
                                // Style waisa hi rakhein
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Logic: Agar logged in hai toh Coin icon, warna Person/Lock icon
                                    Text(isLoggedIn ? '🪙' : '👤',
                                        style: const TextStyle(fontSize: 20)),
                                    const SizedBox(width: 4),

                                    // Logic: Agar logged in hai toh coins count, warna 'Login' text
                                    Text(
                                      isLoggedIn ? '$coins' : 'Login',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Regular",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Consumer<HomeViewModel>(
                        //   builder: (context, homeVM, _) {
                        //     final coins = homeVM.earnedCoins;
                        //     return AnimatedContainer(
                        //       duration: const Duration(milliseconds: 400),
                        //       curve: Curves.easeOutBack,
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 12, vertical: 6),
                        //       decoration: BoxDecoration(
                        //         gradient: const LinearGradient(
                        //           colors: [
                        //             Color(0xFFFFD700),
                        //             Color(0xFFFF9100)
                        //           ],
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //         ),
                        //         borderRadius: BorderRadius.circular(20),
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: const Color(0xFFFFD700)
                        //                 .withOpacity(0.45),
                        //             blurRadius: 8,
                        //             offset: const Offset(0, 3),
                        //           ),
                        //         ],
                        //       ),
                        //       child: Row(
                        //         mainAxisSize: MainAxisSize.min,
                        //         children: [
                        //           const Text('🪙',
                        //               style: TextStyle(fontSize: 16)),
                        //           const SizedBox(width: 4),
                        //           Text(
                        //             '$coins',
                        //             style: TextStyle(
                        //               fontSize: 16,
                        //               fontFamily: "Regular",
                        //               fontWeight: FontWeight.w700,
                        //               color: Colors.white,
                        //               shadows: const [
                        //                 Shadow(
                        //                     color: Colors.black26,
                        //                     blurRadius: 3,
                        //                     offset: Offset(0, 1)),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   },
                        // ),

                        AnimatedPreviewButton(
                          onPressed: () {
                            final coloredPath =
                                getColoredImagePath(widget.imagePath ?? '');
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Preview",
                              barrierColor: Colors.black.withOpacity(0.55),
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              pageBuilder: (dialogContext, animation,
                                  secondaryAnimation) {
                                return PreviewImageDialog(
                                    imagePath: coloredPath);
                              },
                              transitionBuilder:
                                  (ctx, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.elasticOut,
                                    ),
                                    child: child,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        SidebarIcon(
                          icon: Icons.settings_rounded,
                          assetName: 'assets/images/setting.png',
                          onPressed: () {
                            // showGeneralDialog(
                            //   context: context,
                            //   barrierDismissible: true,
                            //   barrierLabel: "Settings",
                            //   barrierColor: Colors.transparent,
                            //   transitionDuration:
                            //       const Duration(milliseconds: 250),
                            //   pageBuilder: (_, __, ___) =>
                            //       const SettingsDialog(),
                            //   transitionBuilder:
                            //       (_, animation, __, child) {
                            //     return FadeTransition(
                            //       opacity: animation,
                            //       child: ScaleTransition(
                            //         scale: CurvedAnimation(
                            //           parent: animation,
                            //           curve: Curves.easeOutBack,
                            //         ),
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(
                                  0.45), // Piche ka area dark karne ke liye
                              builder: (BuildContext context) {
                                return const Center(
                                  child:
                                      KidsSettingsDialog(), // Humara naya settings dialog widget
                                );
                              },
                            );
                          },
                        ),
                        // const SizedBox(height: 16),

                        // Text(
                        //   'LEVEL ${provider ?? 1}',
                        //   style: TextStyle(
                        //     fontSize: 30,
                        //     fontWeight: FontWeight.w700,
                        //     color: const Color(0xFF222222),
                        //     letterSpacing: 2.0,
                        //   ),
                        // ),
                        // Column(
                        //   children: [
                        //     SidebarIcon(
                        //       icon: Icons.settings_rounded,
                        //       assetName: 'assets/images/setting.png',
                        //       onPressed: () {
                        //         // showGeneralDialog(
                        //         //   context: context,
                        //         //   barrierDismissible: true,
                        //         //   barrierLabel: "Settings",
                        //         //   barrierColor: Colors.transparent,
                        //         //   transitionDuration:
                        //         //       const Duration(milliseconds: 250),
                        //         //   pageBuilder: (_, __, ___) =>
                        //         //       const SettingsDialog(),
                        //         //   transitionBuilder:
                        //         //       (_, animation, __, child) {
                        //         //     return FadeTransition(
                        //         //       opacity: animation,
                        //         //       child: ScaleTransition(
                        //         //         scale: CurvedAnimation(
                        //         //           parent: animation,
                        //         //           curve: Curves.easeOutBack,
                        //         //         ),
                        //         showDialog(
                        //           context: context,
                        //           barrierColor: Colors.black.withOpacity(
                        //               0.45), // Piche ka area dark karne ke liye
                        //           builder: (BuildContext context) {
                        //             return const Center(
                        //               child:
                        //                   KidsSettingsDialog(), // Humara naya settings dialog widget
                        //             );
                        //           },
                        //         );
                        //       },
                        //     ),
                        //     const SizedBox(height: 16),

                        //     InkWell(
                        //         onTap: () {
                        //           final coloredPath = getColoredImagePath(
                        //               widget.imagePath ?? '');
                        //           showGeneralDialog(
                        //             context: context,
                        //             barrierDismissible: true,
                        //             barrierLabel: "Preview",
                        //             barrierColor:
                        //                 Colors.black.withOpacity(0.55),
                        //             transitionDuration:
                        //                 const Duration(milliseconds: 400),
                        //             pageBuilder: (dialogContext, animation,
                        //                 secondaryAnimation) {
                        //               return PreviewImageDialog(
                        //                   imagePath: coloredPath);
                        //             },
                        //             transitionBuilder: (ctx, animation,
                        //                 secondaryAnimation, child) {
                        //               return FadeTransition(
                        //                 opacity: animation,
                        //                 child: ScaleTransition(
                        //                   scale: CurvedAnimation(
                        //                     parent: animation,
                        //                     curve: Curves.elasticOut,
                        //                   ),
                        //                   child: child,
                        //                 ),
                        //               );
                        //             },
                        //           );
                        //         },
                        //         child: Container(
                        //           child: Image.asset("assets/images/star.webp"),
                        //           height: 50,
                        //         )),
                        //     // AnimatedPreviewButton(
                        //     //   onPressed: () {
                        //     //     final coloredPath =
                        //     //         getColoredImagePath(widget.imagePath ?? '');
                        //     //     showGeneralDialog(
                        //     //       context: context,
                        //     //       barrierDismissible: true,
                        //     //       barrierLabel: "Preview",
                        //     //       barrierColor: Colors.black.withOpacity(0.55),
                        //     //       transitionDuration:
                        //     //           const Duration(milliseconds: 400),
                        //     //       pageBuilder: (dialogContext, animation,
                        //     //           secondaryAnimation) {
                        //     //         return PreviewImageDialog(
                        //     //             imagePath: coloredPath);
                        //     //       },
                        //     //       transitionBuilder: (ctx, animation,
                        //     //           secondaryAnimation, child) {
                        //     //         return FadeTransition(
                        //     //           opacity: animation,
                        //     //           child: ScaleTransition(
                        //     //             scale: CurvedAnimation(
                        //     //               parent: animation,
                        //     //               curve: Curves.elasticOut,
                        //     //             ),
                        //     //             child: child,
                        //     //           ),
                        //     //         );
                        //     //       },
                        //     //     );
                        //     //   },

                        //     // ),
                        //     // const SizedBox(height: 16),
                        //     // SidebarIcon(
                        //     //   icon: Icons.edit_rounded,
                        //     //   assetName: 'assets/images/pen.png',
                        //     //   onPressed: () =>
                        //     //       Navigator.pushNamed(context, AppRoutes.skins),
                        //     // ),
                        //     const SizedBox(height: 16),
                        //     // SidebarIcon(
                        //     //   icon: Icons.photo_library_rounded,
                        //     //   assetName: 'assets/images/photo.png',
                        //     //   onPressed: () async {
                        //     //     await persistHistorySnapshot(
                        //     //         captureThumbnail: true);
                        //     //     if (context.mounted) {
                        //     //       Navigator.pushNamed(
                        //     //           context, AppRoutes.levels);
                        //     //     }
                        //     //   },
                        //     // ),
                        //   ],
                        // ),

                        // SidebarIcon(
                        //   icon: Icons.edit_rounded,
                        //   assetName: 'assets/images/pen.png',
                        //   onPressed: () {
                        //     // un-awaited: Yeh background mein chalta rahega
                        //     // persistHistorySnapshot(captureThumbnail: true);

                        //     // Fauran next screen par bhej dein
                        //     if (context.mounted) {
                        //       Navigator.pushNamed(context, AppRoutes.skins);
                        //     }
                        //   },
                        // ),

                        // SidebarIcon(
                        //   icon: Icons.photo_library_rounded,
                        //   assetName: 'assets/images/photo.png',
                        //   onPressed: () async {
                        //     // await persistHistorySnapshot(
                        //     //     captureThumbnail: true);
                        //     // if (context.mounted) {
                        //     //   Navigator.pushNamed(context, AppRoutes.levels);
                        //     // }
                        //   },
                        // ),

                        // Item name title
                        // Expanded(
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(
                        //       vertical: 7,
                        //       horizontal: 12,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(18),
                        //       boxShadow: [
                        //         BoxShadow(
                        //           // color: AppColors.primaryPurple.withValues(
                        //           //   alpha: 0.1,
                        //           // ),
                        //           blurRadius: 8,
                        //           offset: const Offset(0, 3),
                        //         ),
                        //       ],
                        //     ),
                        //     child: Text(
                        //       "Muqadas",
                        //       // itemName,
                        //       style: const TextStyle(
                        //         fontSize: 20,
                        //         fontWeight: FontWeight.w900,
                        //         // color: AppColors.primaryPurple,
                        //         letterSpacing: 0.4,
                        //       ),
                        //       textAlign: TextAlign.center,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 8),

                        // // Gesture hint icon — tap to see tooltip
                        // Tooltip(
                        //   message: '1 finger to color · 2 fingers to zoom',
                        //   triggerMode: TooltipTriggerMode.tap,
                        //   preferBelow: true,
                        //   child: Container(
                        //     width: 40,
                        //     height: 40,
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       shape: BoxShape.circle,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           // color: AppColors.primaryPurple.withValues(
                        //           //   alpha: 0.12,
                        //           // ),
                        //           blurRadius: 6,
                        //           offset: const Offset(0, 2),
                        //         ),
                        //       ],
                        //     ),
                        //     child: const Icon(
                        //       Icons.touch_app_rounded,
                        //       // color: AppColors.primaryPurple,
                        //       size: 20,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 8),

                        // Auto-zoom toggle — filled purple = ON, white = OFF

                        // Tooltip(
                        //   message: provider.autoZoomEnabled
                        //       ? 'Auto-zoom ON'
                        //       : 'Auto-zoom OFF',
                        //   triggerMode: TooltipTriggerMode.tap,
                        //   child: GestureDetector(
                        //     onTap: () => provider.setAutoZoomEnabled(
                        //       !provider.autoZoomEnabled,
                        //     ),
                        //     child: AnimatedContainer(
                        //       duration: const Duration(milliseconds: 200),
                        //       width: 40,
                        //       height: 40,
                        //       decoration: BoxDecoration(
                        //         color: Colors.amber,
                        //         // provider.autoZoomEnabled
                        //         //     ? AppColors.primaryPurple
                        //         //     : Colors.white,
                        //         shape: BoxShape.circle,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             // color: AppColors.primaryPurple.withValues(
                        //             //   alpha: 0.18,
                        //             // ),
                        //             blurRadius: 6,
                        //             offset: const Offset(0, 2),
                        //           ),
                        //         ],
                        //       ),
                        //       child: Icon(
                        //         Icons.zoom_in_map_rounded,
                        //         // color: provider.autoZoomEnabled
                        //         //     ? Colors.white
                        //         //     : AppColors.primaryPurple.withValues(
                        //         //         alpha: 0.45,
                        //         //       ),
                        //         size: 20,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Coloring Board — fills ALL remaining space ────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ColoringBoard(provider: provider),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Preview popup & animations helper ────────────────────────────────────────

String getColoredImagePath(String outlinePath) {
  final parts = outlinePath.split('/');
  if (parts.isEmpty) return outlinePath;
  final fileName = parts.last;
  String cleanName = fileName
      .replaceFirst('un_colored-_', '')
      .replaceFirst('un_colored_', '')
      .replaceFirst('un_border_', '')
      .replaceFirst('un_color_', '')
      .replaceFirst('un_colorder_', '')
      .replaceFirst('uncolored_', '');

  if (cleanName == 'mango.webp') {
    cleanName = 'mango.png';
  } else if (cleanName == 'grapes.webp') {
    cleanName = 'grapes.png';
  } else if (cleanName == 'strawberry.webp') {
    cleanName = 'strawberry.png';
  } else if (cleanName == 'plum.webp') {
    cleanName = 'plum.png';
  } else if (cleanName == 'camel.jpeg') {
    cleanName = 'camel.webp';
  } else if (cleanName == 'hamster.jpeg') {
    cleanName = 'hamster.webp';
  } else if (cleanName == 'hen.jpeg') {
    cleanName = 'hen.webp';
  } else if (cleanName == 'rooster.jpeg') {
    cleanName = 'rooster.webp';
  } else if (cleanName == 'yak.jpeg') {
    cleanName = 'yak.webp';
  } else if (cleanName == 'rabbit.webp') {
    cleanName = 'Rabbit.webp';
  } else if (cleanName == 'donkey.webp') {
    cleanName = 'Donkey.webp';
  }

  parts[parts.length - 1] = cleanName;
  return parts.join('/');
}

class AnimatedPreviewButton extends StatefulWidget {
  const AnimatedPreviewButton({Key? key, required this.onPressed})
      : super(key: key);
  final VoidCallback onPressed;

  @override
  State<AnimatedPreviewButton> createState() => _AnimatedPreviewButtonState();
}

class _AnimatedPreviewButtonState extends State<AnimatedPreviewButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.visibility_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class PreviewImageDialog extends StatefulWidget {
  const PreviewImageDialog({Key? key, required this.imagePath})
      : super(key: key);
  final String imagePath;

  @override
  State<PreviewImageDialog> createState() => _PreviewImageDialogState();
}

class _PreviewImageDialogState extends State<PreviewImageDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 300,
            height: 340,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "LOOK & COLOR!",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Regular",
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFFEB3B), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
