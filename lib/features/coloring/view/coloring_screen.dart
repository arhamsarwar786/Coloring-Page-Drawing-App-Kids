import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/coloring/view/coloring_completion_screen.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
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

                        // Item name title
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  // color: AppColors.primaryPurple.withValues(
                                  //   alpha: 0.1,
                                  // ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "Muqadas",
                              // itemName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                // color: AppColors.primaryPurple,
                                letterSpacing: 0.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Gesture hint icon — tap to see tooltip
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
                        Tooltip(
                          message: provider.autoZoomEnabled
                              ? 'Auto-zoom ON'
                              : 'Auto-zoom OFF',
                          triggerMode: TooltipTriggerMode.tap,
                          child: GestureDetector(
                            onTap: () => provider.setAutoZoomEnabled(
                              !provider.autoZoomEnabled,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                // provider.autoZoomEnabled
                                //     ? AppColors.primaryPurple
                                //     : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    // color: AppColors.primaryPurple.withValues(
                                    //   alpha: 0.18,
                                    // ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.zoom_in_map_rounded,
                                // color: provider.autoZoomEnabled
                                //     ? Colors.white
                                //     : AppColors.primaryPurple.withValues(
                                //         alpha: 0.45,
                                //       ),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
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
