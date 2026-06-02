import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/app/routes/app_routes.dart';
import 'package:play_craft_kids/features/coloring/view/coloring_completion_screen.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/activity_item.dart';
import 'package:provider/provider.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/coloring/widgets/coloring_board.dart';

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({Key? key, this.imagePath}) : super(key: key);

  final String? imagePath;

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
      // var model = ActivityItem(
      //   id: '1',
      //   label: 'one',
      //   display: '1',
      //   color: Colors.red,
      //   // Prefer imagePath passed via widget, fallback to provider's current item, then default asset
      //   imagePath: widget.imagePath ??
      //       _provider?.currentItem?.imagePath ??
      //       "assets/images/un_colored_dolphin.webp",
      // );
      //   _provider?.setItem(model, 1);
      //   setState(() {
      //     loader = true;
      //   });
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

    if (provider.isPartByPartComplete && !_didNavigateToCompletion) {
      _didNavigateToCompletion = true;

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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // const AppBackButton(),
                        const SizedBox(width: 8),

                        SidebarIcon(
                          icon: Icons.arrow_back_rounded,
                          assetName: 'assets/images/pop-button.png',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),

                        // Text(
                        //   'LEVEL ${provider ?? 1}',
                        //   style: GoogleFonts.fredoka(
                        //     fontSize: 30,
                        //     fontWeight: FontWeight.w700,
                        //     color: const Color(0xFF222222),
                        //     letterSpacing: 2.0,
                        //   ),
                        // ),
                        Positioned(
                          right: 16,
                          top: 1,
                          child: Column(
                            children: [
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
                                  //         child: child,
                                  //       ),
                                  //     );
                                  //   },
                                  // );

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
                              // SidebarIcon(
                              //   icon: Icons.edit_rounded,
                              //   assetName: 'assets/images/pen.png',
                              //   onPressed: () =>
                              //       Navigator.pushNamed(context, AppRoutes.skins),
                              // ),
                              const SizedBox(height: 16),
                              // SidebarIcon(
                              //   icon: Icons.photo_library_rounded,
                              //   assetName: 'assets/images/photo.png',
                              //   onPressed: () async {
                              //     await persistHistorySnapshot(
                              //         captureThumbnail: true);
                              //     if (context.mounted) {
                              //       Navigator.pushNamed(
                              //           context, AppRoutes.levels);
                              //     }
                              //   },
                              // ),
                            ],
                          ),
                        ),

                        // SidebarIcon(
                        //         icon: Icons.edit_rounded,
                        //         assetName: 'assets/images/pen.png',
                        //         onPressed: () {
                        //           // un-awaited: Yeh background mein chalta rahega
                        //           persistHistorySnapshot(
                        //               captureThumbnail: true);

                        //           // Fauran next screen par bhej dein
                        //           if (context.mounted) {
                        //             Navigator.pushNamed(
                        //                 context, AppRoutes.skins);
                        //           }
                        //         },
                        //       ),

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
