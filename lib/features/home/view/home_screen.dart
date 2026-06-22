import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/features/coloring/view/coloring_screen.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/components/level_preview.dart';
import '../../../shared/utils/interaction_feedback.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loader.dart';
import '../../levels/model/level_model.dart';
import '../viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/activity_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOpeningLevel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppGradientBackground(
        child: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading && viewModel.content == null) {
                return const Loader();
              }
              if (viewModel.errorMessage != null && viewModel.content == null) {
                return _HomeError(
                  message: viewModel.errorMessage!,
                  onRetry: viewModel.load,
                );
              }

              // Only show levels for the selected category
              final selectedLevels = viewModel.levelsForSelectedCategory;
              if (selectedLevels.isEmpty) {
                return const SizedBox.shrink();
              }

              // ==========================================
              // BACKGROUND DYNAMIC LOGIC
              // ==========================================
              final firstLevel =
                  selectedLevels.isNotEmpty ? selectedLevels[0] : null;
              String categoryName = '';
              if (firstLevel != null && firstLevel.title != null) {
                categoryName = firstLevel.title.toString().toLowerCase();
              }

              String backgroundAsset =
                  'assets/images/bg.png'; // Default background
              var category = viewModel.selectedCategory;
              if (categoryName.contains('fruit') ||
                  categoryName.contains('apple')) {
                backgroundAsset = 'assets/images/fruitbg.png';
              } else if (category?.id?.contains('animals') == true) {
                backgroundAsset = 'assets/images/animalbg.png';
              } else if (category?.id?.contains('vegetables') == true) {
                backgroundAsset = 'assets/images/vegetable_bg.png';
              } else if (category?.id?.contains('vehicles') == true) {
                backgroundAsset = 'assets/images/vehiclesbg.png';
              } else if (category?.id?.contains('colors') == true) {
                backgroundAsset = 'assets/images/bg.png';
              } else if (category?.id?.contains('alphabets') == true) {
                backgroundAsset = 'assets/images/alphaets.png';
              }
              // ==========================================

              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(backgroundAsset),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.4),
                      BlendMode.lighten,
                    ),
                  ),
                ),
                height: double.infinity,
                width: double.infinity,
                child: RefreshIndicator(
                  onRefresh: _isOpeningLevel ? () async {} : viewModel.load,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
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
                                                    viewModel.selectedCategory
                                                            ?.title ??
                                                        AppStrings.appTitle,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 30,
                                                      fontFamily: "Regular",
                                                      fontWeight:
                                                          FontWeight.w900,
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
                                                    viewModel.selectedCategory
                                                            ?.title ??
                                                        AppStrings.appTitle,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontFamily: "Regular",
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Color(0xFFFF4FA3),
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),

                                                // Main White Text
                                                Text(
                                                  viewModel.selectedCategory
                                                          ?.title ??
                                                      AppStrings.appTitle,
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

                        //  SizedBox(
                        //   height: 140,
                        //   width: double.infinity,
                        //   child:
                        //   Stack(
                        //     children: [
                        //       ClipPath(
                        //         clipper: AppBarClipper(),
                        //         child: Container(
                        //           height: 140,
                        //           color: const Color(0xff3b9499),
                        //           child: Row(
                        //             children: [
                        //               Padding(
                        //                 padding: const EdgeInsets.all(8.0),
                        //                 child: SidebarIcon(
                        //                   icon: Icons.arrow_back_rounded,
                        //                   assetName:
                        //                       'assets/images/pop-button.png',
                        //                   onPressed: () {
                        //                     Navigator.pop(context);
                        //                   },
                        //                 ),
                        //               ),

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
                        //               viewModel.selectedCategory
                        //                       ?.title ??
                        //                   AppStrings.appTitle,
                        //               textAlign: TextAlign.center,
                        //               style: TextStyle(
                        //                 fontSize: 50,
                        //                 fontFamily: "Regular",
                        //                 fontWeight:
                        //                     FontWeight.w900,
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
                        //               viewModel.selectedCategory
                        //                       ?.title ??
                        //                   AppStrings.appTitle,
                        //               textAlign: TextAlign.center,
                        //               style: const TextStyle(
                        //                 fontSize: 50,
                        //                 fontFamily: "Regular",
                        //                 fontWeight:
                        //                     FontWeight.w900,
                        //                 color: Color(0xFFFF4FA3),
                        //                 letterSpacing: 1,
                        //               ),
                        //             ),
                        //           ),

                        //           // Main White Text
                        //           Text(
                        //             viewModel.selectedCategory
                        //                     ?.title ??
                        //                 AppStrings.appTitle,
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

                        //               const SizedBox(width: 60),
                        //             ],
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final columns = _columnCountForWidth(
                                constraints.crossAxisExtent);
                            return SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final level = selectedLevels[index];
                                  final levelNumber = index + 1;
                                  final isLocked = viewModel.isLevelLockedAt(
                                    index,
                                    selectedLevels,
                                  );
                                  return LevelCard(
                                      key: ValueKey(level.id),
                                      level: level,
                                      levelNumber: levelNumber,
                                      palette: _paletteFor(index),
                                      isLocked: isLocked,
                                      isBusy: _isOpeningLevel,
                                      onTap: () {
                                        debugPrint("Level: ${level.title}");
                                        debugPrint(
                                            "Image Path: ${level.activityItem?.imagePath}");

                                        final coloringProvider =
                                            Provider.of<ColoringProvider>(
                                                context,
                                                listen: false);
                                        final activity = level.activityItem ??
                                            ActivityItem(
                                              id: level.id,
                                              label: level.title,
                                              display: level.title,
                                              color: Colors.red,
                                              imagePath: level.imagePath ??
                                                  'assets/images/un_border_apple.webp',
                                            );
                                        coloringProvider.setItem(activity, 1,
                                            level: level);

                                        handleTapAction(context, () {});
                                        _openLevel(context, viewModel, level);
                                      });
                                },
                                childCount: selectedLevels.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: _aspectRatioForWidth(
                                  constraints.crossAxisExtent,
                                  columns,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int _columnCountForWidth(double width) {
    if (width >= 900) return 5;
    if (width >= 700) return 4;
    if (width >= 520) return 3;
    return 2;
  }

  double _aspectRatioForWidth(double width, int columns) {
    if (columns >= 5) return 0.76;
    if (columns == 4) return 0.75;
    if (columns == 3) return 0.74;
    return 0.73;
  }

  Future<void> _openLevel(
    BuildContext context,
    HomeViewModel viewModel,
    LevelModel level,
  ) async {
    if (_isOpeningLevel) return;

    if (viewModel.isLevelLocked(level)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.lockedLevelMessage)),
      );
      return;
    }

    setState(() {
      _isOpeningLevel = true;
    });

    try {
      final isReady = await viewModel.prepareLevel(level.id);
      if (!context.mounted) return;

      if (!isReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.lockedLevelMessage)),
        );
        return;
      }

      String assetPath = level.imagePath ?? 'assets/images/apple.webp';

      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ColoringScreen(imagePath: assetPath)),
      );

      if (!context.mounted) return;
      // Cheap refresh first — instantly re-evaluates lock states.
      await context.read<HomeViewModel>().refreshProgress();
      // Full reload to pick up coins / content changes from storage.
      if (context.mounted) await context.read<HomeViewModel>().load();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningLevel = false;
        });
      }
    }
  }

  CardPalette _paletteFor(int index) {
    const palettes = <CardPalette>[
      CardPalette(
        outerTop: Color(0xFF66BAF9),
        outerBottom: Color(0xFF2F8BDB),
        innerTop: Color(0xFF95D8FF),
        innerBottom: Color(0xFF66BDF4),
        edge: Color(0xFF2674C3),
      ),
      CardPalette(
        outerTop: Color(0xFFFFD34D),
        outerBottom: Color(0xFFF0B52B),
        innerTop: Color(0xFFFFE27B),
        innerBottom: Color(0xFFFFCF49),
        edge: Color(0xFFD39B16),
      ),
      CardPalette(
        outerTop: Color(0xFF63DDD7),
        outerBottom: Color(0xFF27B7B6),
        innerTop: Color(0xFF96F0E4),
        innerBottom: Color(0xFF59D3CF),
        edge: Color(0xFF219795),
      ),
      CardPalette(
        outerTop: Color(0xFFB6ED64),
        outerBottom: Color(0xFF7DC83B),
        innerTop: Color(0xFFD4F68F),
        innerBottom: Color(0xFFB0E45D),
        edge: Color(0xFF69AB2A),
      ),
      CardPalette(
        outerTop: Color(0xFFFFB156),
        outerBottom: Color(0xFFF37A22),
        innerTop: Color(0xFFFFCB82),
        innerBottom: Color(0xFFFFA14A),
        edge: Color(0xFFD36A18),
      ),
      CardPalette(
        outerTop: Color(0xFFFFAE58),
        outerBottom: Color(0xFFF18832),
        innerTop: Color(0xFFFFD295),
        innerBottom: Color(0xFFFFA550),
        edge: Color(0xFFD26A21),
      ),
      CardPalette(
        outerTop: Color(0xFFBC86FF),
        outerBottom: Color(0xFF8B52DF),
        innerTop: Color(0xFFD9B0FF),
        innerBottom: Color(0xFFB67BF8),
        edge: Color(0xFF7542C9),
      ),
      CardPalette(
        outerTop: Color(0xFFA7DEFF),
        outerBottom: Color(0xFF65BEEB),
        innerTop: Color(0xFFCDEEFF),
        innerBottom: Color(0xFF99D6F8),
        edge: Color(0xFF529FC9),
      ),
      CardPalette(
        outerTop: Color(0xFFFFA6C8),
        outerBottom: Color(0xFFEC6796),
        innerTop: Color(0xFFFFCBDF),
        innerBottom: Color(0xFFFF96BE),
        edge: Color(0xFFD55282),
      ),
      CardPalette(
        outerTop: Color(0xFFFF7FD0),
        outerBottom: Color(0xFFD93FAE),
        innerTop: Color(0xFFFFA8E2),
        innerBottom: Color(0xFFFF74CF),
        edge: Color(0xFFBA2C91),
      ),
    ];

    return palettes[index % palettes.length];
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 54),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomButton(
              label: AppStrings.retry,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class LevelCard extends StatefulWidget {
  const LevelCard({
    super.key,
    required this.level,
    required this.levelNumber,
    required this.palette,
    required this.isLocked,
    required this.isBusy,
    required this.onTap,
  });

  final dynamic level;
  final int levelNumber;
  final dynamic palette;
  final bool isLocked;
  final bool isBusy;
  final VoidCallback onTap;

  String get difficulty {
    if (levelNumber <= 10) return "Easy";
    if (levelNumber <= 20) return "Medium";
    return "Hard";
  }

  @override
  State<LevelCard> createState() => LevelCardState();
}

class LevelCardState extends State<LevelCard> {
  bool _isPressed = false;

  void _updatePressed(bool value) {
    if (_isPressed == value) return;
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // === YAHAN CHANGES KI HAIN ===
    // Lock hone par bhi original palettes wale bright colors hi show honge!
    final Color mainBodyColor = widget.palette.outerTop;
    final Color bottomBorderColor = widget.palette.edge;
    final Color innerWhiteBoxColor = Colors.white.withOpacity(0.35);

    Color getDifficultyColor() {
      switch (widget.difficulty) {
        case "Easy":
          return Colors.greenAccent;
        case "Medium":
          return Colors.orangeAccent;
        case "Hard":
          return Colors.redAccent;
        default:
          return Colors.blue;
      }
    }

    return IgnorePointer(
      ignoring: widget.isBusy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: widget.isBusy ? 0.72 : 1,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1,
          duration: Duration(milliseconds: _isPressed ? 110 : 320),
          curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _updatePressed(true),
            onTapUp: (_) => _updatePressed(false),
            onTapCancel: () => _updatePressed(false),
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 7.0, left: 4.0, right: 4.0, top: 4.0),
              decoration: BoxDecoration(
                color: bottomBorderColor,
                borderRadius: BorderRadius.circular(26.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: mainBodyColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 6,
                      left: 10,
                      child: Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: innerWhiteBoxColor,
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.5),
                                    width: 1),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                // child: Builder(
                                //   builder: (context) {
                                //     final title = widget.level.title
                                //             ?.toString()
                                //             .toLowerCase() ??
                                //         '';
                                //     String assetPath =
                                //         'assets/images/apple.webp';
                                //     if (title.contains('banana')) {
                                //       assetPath = 'assets/images/banana.webp';
                                //     } else if (title.contains('mango')) {
                                //       assetPath = 'assets/images/mango.jpg';
                                //     } else if (title.contains('orange')) {
                                //       assetPath = 'assets/images/orange.webp';
                                //     } else if (title.contains('apple')) {
                                //       assetPath = 'assets/images/apple.webp';
                                //     }
                                //     return Image.asset(assetPath);
                                //   },
                                // ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final previewSize =
                                        constraints.biggest.shortestSide;
                                    return LevelPreview(
                                      level: widget.level,
                                      size: previewSize,
                                      backgroundColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      borderRadius: BorderRadius.zero,
                                      style: LevelPreviewStyle.colored,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text(
                            (widget.level.title ??
                                    'LEVEL ${widget.levelNumber}')
                                .toUpperCase(),
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Regular",
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Colors
                                  .white, // Text hamesha white aur pyara dikhega
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.difficulty,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Regular",
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Colors
                                  .white, // Text hamesha white aur pyara dikhega
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.25),
                                  offset: const Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),

                            // style: TextStyle(
                            //   color: getDifficultyColor(),
                            //   fontSize: 20,
                            //   fontWeight: FontWeight.bold,
                            // ),
                          ),
                        ],
                      ),
                    ),

                    // === LOCK OVERLAY LAYER ===
                    // Agar level lock hoga, toh color ke upar sirf yeh semi-transparent lock overlay aayega!
                    if (widget.isLocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // Halke se black shade se transparent layer di hai taake peeche ka color bhi dikhe aur lock bhi pyara lage
                            color: Colors.black.withOpacity(0.28),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.white,
                                size: 38,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardPalette {
  final Color outerTop;
  final Color outerBottom;
  final Color innerTop;
  final Color innerBottom;
  final Color edge;

  const CardPalette({
    required this.outerTop,
    required this.outerBottom,
    required this.innerTop,
    required this.innerBottom,
    required this.edge,
  });
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
// import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
// import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
// import 'package:provider/provider.dart';

// import '../../../app/routes/app_routes.dart';
// import '../../../core/constants/app_spacing.dart';
// import '../../../core/constants/app_strings.dart';
// import '../../../shared/components/app_gradient_background.dart';
// import '../../../shared/components/level_preview.dart';
// import '../../../shared/utils/interaction_feedback.dart';
// import '../../../shared/widgets/custom_button.dart';
// import '../../../shared/widgets/loader.dart';
// import '../../levels/model/level_model.dart';
// import '../viewmodel/home_viewmodel.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   bool _isOpeningLevel = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: AppGradientBackground(
//         child: SafeArea(
//           child: Consumer<HomeViewModel>(
//             builder: (context, viewModel, _) {
//               if (viewModel.isLoading && viewModel.content == null) {
//                 return const Loader();
//               }
//               if (viewModel.errorMessage != null && viewModel.content == null) {
//                 return _HomeError(
//                   message: viewModel.errorMessage!,
//                   onRetry: viewModel.load,
//                 );
//               }

//               // Only show levels for the selected category
//               final selectedLevels = viewModel.levelsForSelectedCategory;
//               if (selectedLevels.isEmpty) {
//                 return const SizedBox.shrink();
//               }

//               // ==========================================
//               // BACKGROUND DYNAMIC LOGIC (YAHAN PE PERFECT CHALEGI)
//               // ==========================================
//               final firstLevel =
//                   selectedLevels.isNotEmpty ? selectedLevels[0] : null;
//               String categoryName = '';
//               if (firstLevel != null && firstLevel.title != null) {
//                 categoryName = firstLevel.title.toString().toLowerCase();
//               }

//               String backgroundAsset =
//                   'assets/images/bg.png'; // Default background
//               var category = viewModel.selectedCategory;
//               if (categoryName.contains('fruit') ||
//                   categoryName.contains('apple')) {
//                 backgroundAsset = 'assets/images/fruitbg.png';
//               } else if (category?.id?.contains('animals') == true ||
//                   category?.id?.contains('animals') == true) {
//                 backgroundAsset = 'assets/images/animalbg.png';
//               } else if (category?.id?.contains('sports') == true) {
//                 // Sports category added here
//                 backgroundAsset = 'assets/images/sportbg.png';
//               } else if (category?.id?.contains('vehicles') == true) {
//                 backgroundAsset = 'assets/images/vehiclesbg.png';
//               }
//               // ==========================================

//               return Container(
//                 // Hum ne backgroundAsset ko yahan use kar liya taake dynamic change ho ske
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage(backgroundAsset),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 height: double.infinity,
//                 width: double.infinity,
//                 child: RefreshIndicator(
//                   onRefresh: _isOpeningLevel ? () async {} : viewModel.load,
//                   child: CustomScrollView(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     slivers: <Widget>[
//                       SliverToBoxAdapter(
//                           child: SizedBox(
//                         height:
//                             140, // Jetni aapke curved bar ki height hai, utni hi yahan de dein
//                         width: double.infinity,
//                         child: Stack(
//                           children: [
//                             ClipPath(
//                               clipper: AppBarClipper(),
//                               child: Container(
//                                 height: 140,
//                                 color: const Color(0xff3b9499),
//                                 child: Row(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
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
//                                                   viewModel.selectedCategory
//                                                           ?.id ??
//                                                       AppStrings.appTitle,
//                                                   textAlign: TextAlign.center,
//                                                   style: TextStyle(
//                                                     fontSize: 50,
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
//                                                   viewModel.selectedCategory
//                                                           ?.id ??
//                                                       AppStrings.appTitle,
//                                                   textAlign: TextAlign.center,
//                                                   style: const TextStyle(
//                                                     fontSize: 50,
//                                                     fontWeight: FontWeight.w900,
//                                                     color: Color(0xFFFF4FA3),
//                                                     letterSpacing: 1,
//                                                   ),
//                                                 ),
//                                               ),

//                                               // Main White Text
//                                               Text(
//                                                 viewModel
//                                                         .selectedCategory?.id ??
//                                                     AppStrings.appTitle,
//                                                 textAlign: TextAlign.center,
//                                                 style: const TextStyle(
//                                                   fontSize: 50,
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

//                                     SizedBox(
//                                       width: 60,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                           ),
//                       SliverPadding(
//                         padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
//                         sliver: SliverLayoutBuilder(
//                           builder: (context, constraints) {
//                             final columns = _columnCountForWidth(
//                                 constraints.crossAxisExtent);
//                             return SliverGrid(
//                               delegate: SliverChildBuilderDelegate(
//                                 (context, index) {
//                                   final level = selectedLevels[index];
//                                   final levelNumber = index + 1;
//                                   final isLocked = viewModel.isLevelLockedAt(
//                                     index,
//                                     selectedLevels,
//                                   );
//                                   return LevelCard(
//                                     level: level,
//                                     levelNumber: levelNumber,
//                                     palette: _paletteFor(index),
//                                     isLocked: isLocked,
//                                     isBusy: _isOpeningLevel,
//                                     onTap: () =>
//                                         _openLevel(context, viewModel, level),
//                                   );
//                                 },
//                                 childCount: selectedLevels.length,
//                               ),
//                               gridDelegate:
//                                   SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: columns,
//                                 mainAxisSpacing: 12,
//                                 crossAxisSpacing: 12,
//                                 childAspectRatio: _aspectRatioForWidth(
//                                   constraints.crossAxisExtent,
//                                   columns,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   int _columnCountForWidth(double width) {
//     if (width >= 900) return 5;
//     if (width >= 700) return 4;
//     if (width >= 520) return 3;
//     return 2;
//   }

//   double _aspectRatioForWidth(double width, int columns) {
//     if (columns >= 5) return 0.76;
//     if (columns == 4) return 0.75;
//     if (columns == 3) return 0.74;
//     return 0.73;
//   }

//   Future<void> _openLevel(
//     BuildContext context,
//     HomeViewModel viewModel,
//     LevelModel level,
//   ) async {
//     if (_isOpeningLevel) return;

//     if (viewModel.isLevelLocked(level)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(AppStrings.lockedLevelMessage)),
//       );
//       return;
//     }

//     setState(() {
//       _isOpeningLevel = true;
//     });

//     try {
//       final isReady = await viewModel.prepareLevel(level.id);
//       if (!context.mounted) return;

//       if (!isReady) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text(AppStrings.lockedLevelMessage)),
//         );
//         return;
//       }

//       await Navigator.pushNamed(
//         context,
//         AppRoutes.drawing,
//         arguments: DrawingRouteArgs(
//           levelId: level.id,
//           levelTitle: level.title,
//           levelNumber: viewModel.levelNumberFor(level.id),
//         ),
//       );

//       if (!context.mounted) return;
//       await context.read<HomeViewModel>().load();
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isOpeningLevel = false;
//         });
//       }
//     }
//   }

//   _CardPalette _paletteFor(int index) {
//     const palettes = <_CardPalette>[
//       _CardPalette(
//         outerTop: Color(0xFF66BAF9),
//         outerBottom: Color(0xFF2F8BDB),
//         innerTop: Color(0xFF95D8FF),
//         innerBottom: Color(0xFF66BDF4),
//         edge: Color(0xFF2674C3),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFFFD34D),
//         outerBottom: Color(0xFFF0B52B),
//         innerTop: Color(0xFFFFE27B),
//         innerBottom: Color(0xFFFFCF49),
//         edge: Color(0xFFD39B16),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFF63DDD7),
//         outerBottom: Color(0xFF27B7B6),
//         innerTop: Color(0xFF96F0E4),
//         innerBottom: Color(0xFF59D3CF),
//         edge: Color(0xFF219795),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFB6ED64),
//         outerBottom: Color(0xFF7DC83B),
//         innerTop: Color(0xFFD4F68F),
//         innerBottom: Color(0xFFB0E45D),
//         edge: Color(0xFF69AB2A),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFFFB156),
//         outerBottom: Color(0xFFF37A22),
//         innerTop: Color(0xFFFFCB82),
//         innerBottom: Color(0xFFFFA14A),
//         edge: Color(0xFFD36A18),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFFFAE58),
//         outerBottom: Color(0xFFF18832),
//         innerTop: Color(0xFFFFD295),
//         innerBottom: Color(0xFFFFA550),
//         edge: Color(0xFFD26A21),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFBC86FF),
//         outerBottom: Color(0xFF8B52DF),
//         innerTop: Color(0xFFD9B0FF),
//         innerBottom: Color(0xFFB67BF8),
//         edge: Color(0xFF7542C9),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFA7DEFF),
//         outerBottom: Color(0xFF65BEEB),
//         innerTop: Color(0xFFCDEEFF),
//         innerBottom: Color(0xFF99D6F8),
//         edge: Color(0xFF529FC9),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFFFA6C8),
//         outerBottom: Color(0xFFEC6796),
//         innerTop: Color(0xFFFFCBDF),
//         innerBottom: Color(0xFFFF96BE),
//         edge: Color(0xFFD55282),
//       ),
//       _CardPalette(
//         outerTop: Color(0xFFFF7FD0),
//         outerBottom: Color(0xFFD93FAE),
//         innerTop: Color(0xFFFFA8E2),
//         innerBottom: Color(0xFFFF74CF),
//         edge: Color(0xFFBA2C91),
//       ),
//     ];

//     return palettes[index % palettes.length];
//   }
// }

// class _HomeError extends StatelessWidget {
//   const _HomeError({
//     required this.message,
//     required this.onRetry,
//   });

//   final String message;
//   final Future<void> Function() onRetry;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(AppSpacing.xl),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             const Icon(Icons.cloud_off_rounded, size: 54),
//             const SizedBox(height: AppSpacing.md),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const SizedBox(height: AppSpacing.md),
//             CustomButton(
//               label: AppStrings.retry,
//               onPressed: onRetry,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // LevelCard class ko waise hi rehne diya hai jaisa aap ne bheja tha...
// class LevelCard extends StatefulWidget {
//   const LevelCard({
//     super.key,
//     required this.level,
//     required this.levelNumber,
//     required this.palette,
//     required this.isLocked,
//     required this.isBusy,
//     required this.onTap,
//   });

//   final dynamic level;
//   final int levelNumber;
//   final dynamic palette;
//   final bool isLocked;
//   final bool isBusy;
//   final VoidCallback onTap;

//   @override
//   State<LevelCard> createState() => LevelCardState();
// }

// class LevelCardState extends State<LevelCard> {
//   bool _isPressed = false;

//   void _updatePressed(bool value) {
//     if (_isPressed == value) return;
//     setState(() {
//       _isPressed = value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Color mainBodyColor =
//         widget.isLocked ? Colors.grey.shade400 : widget.palette.outerTop;
//     final Color bottomBorderColor =
//         widget.isLocked ? Colors.grey.shade600 : widget.palette.edge;

//     final Color innerWhiteBoxColor =
//         widget.isLocked ? Colors.grey.shade300 : Colors.white.withOpacity(0.35);

//     return IgnorePointer(
//       ignoring: widget.isBusy,
//       child: AnimatedOpacity(
//         duration: const Duration(milliseconds: 160),
//         opacity: widget.isBusy ? 0.72 : 1,
//         child: AnimatedScale(
//           scale: _isPressed ? 0.94 : 1,
//           duration: Duration(milliseconds: _isPressed ? 110 : 320),
//           curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
//           child: GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onTapDown: (_) => _updatePressed(true),
//             onTapUp: (_) => _updatePressed(false),
//             onTapCancel: () => _updatePressed(false),
//             onTap: widget.onTap,
//             child: Container(
//               padding: const EdgeInsets.only(
//                   bottom: 7.0, left: 4.0, right: 4.0, top: 4.0),
//               decoration: BoxDecoration(
//                 color: bottomBorderColor,
//                 borderRadius: BorderRadius.circular(26.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.15),
//                     blurRadius: 4,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: mainBodyColor,
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       top: 6,
//                       left: 10,
//                       child: Container(
//                         width: 24,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.4),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10.0, vertical: 10.0),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               width: double.infinity,
//                               margin: const EdgeInsets.only(bottom: 8),
//                               decoration: BoxDecoration(
//                                 color: innerWhiteBoxColor,
//                                 borderRadius: BorderRadius.circular(16.0),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(10.0),
//                                 child: LayoutBuilder(
//                                   builder: (context, constraints) {
//                                     final previewSize =
//                                         constraints.biggest.shortestSide;
//                                     return LevelPreview(
//                                       level: widget.level,
//                                       size: previewSize,
//                                       backgroundColor: Colors.transparent,
//                                       padding: EdgeInsets.zero,
//                                       borderRadius: BorderRadius.zero,
//                                       style: LevelPreviewStyle.colored,
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Text(
//                             (widget.level.title ??
//                                     'LEVEL ${widget.levelNumber}')
//                                 .toUpperCase(),
//                             maxLines: 1,
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: 0.5,
//                               color: widget.isLocked
//                                   ? Colors.grey.shade700
//                                   : Colors.white,
//                               shadows: widget.isLocked
//                                   ? []
//                                   : [
//                                       Shadow(
//                                         color: Colors.black.withOpacity(0.25),
//                                         offset: const Offset(0, 2),
//                                         blurRadius: 2,
//                                       ),
//                                     ],
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                         ],
//                       ),
//                     ),
//                     if (widget.isLocked)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             color: Colors.black.withOpacity(0.15),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Dummy classes/Palettes for smooth compilation
// class _CardPalette {
//   final Color outerTop;
//   final Color outerBottom;
//   final Color innerTop;
//   final Color innerBottom;
//   final Color edge;

//   const _CardPalette({
//     required this.outerTop,
//     required this.outerBottom,
//     required this.innerTop,
//     required this.innerBottom,
//     required this.edge,
//   });
// }
