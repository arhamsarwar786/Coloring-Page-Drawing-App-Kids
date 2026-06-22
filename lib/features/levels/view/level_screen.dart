import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../drawing/view/drawing_screen.dart';
import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/widgets/loader.dart';
import '../../home/components/app_bar_clipper.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../home/view/home_screen.dart';
import '../../levels/model/level_model.dart';
import '../../coloring/viewmodel/coloring_viewmodel.dart';
import '../../coloring/view/coloring_screen.dart';
import '../../tracing/viewmodel/activity_item.dart';
import '../../../shared/utils/interaction_feedback.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool _isOpeningLevel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeViewModel>().load();
      }
    });
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

  Future<void> _openLevel(
    BuildContext context,
    HomeViewModel viewModel,
    LevelModel level,
  ) async {
    if (_isOpeningLevel) return;

    setState(() {
      _isOpeningLevel = true;
    });

    try {
      final isReady = await viewModel.prepareLevel(level.id);
      if (!context.mounted) return;

      if (!isReady) {
        return;
      }

      String assetPath = level.imagePath ?? 'assets/images/apple.webp';

      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ColoringScreen(imagePath: assetPath)),
      );

      if (!context.mounted) return;
      await context.read<HomeViewModel>().refreshProgress();
      if (context.mounted) await context.read<HomeViewModel>().load();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningLevel = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/color.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading && viewModel.content == null) {
                return const Loader();
              }

              final completedLevels = viewModel.categories
                  .expand((c) => c.levels)
                  .where((l) => l.isCompleted)
                  .toList();

              return RefreshIndicator(
                onRefresh: viewModel.load,
                // CustomScrollView ab root par hai
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    // 1. Header ko SliverToBoxAdapter mein rakha
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    //     child: Row(
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.all(8.0),
                    //           child: SidebarIcon(
                    //             icon: Icons.arrow_back_rounded,
                    //             assetName: 'assets/images/pop-button.png',
                    //             onPressed: () => Navigator.pop(context),
                    //           ),
                    //         ),
                    //         Expanded(
                    //           child: Center(
                    //             child: Text(
                    //               "Color History",
                    //               style: const TextStyle(
                    //                 fontSize: 40,
                    //                 fontWeight: FontWeight.w900,
                    //                 color: Colors.white,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 60),
                    //       ],
                    //     ),
                    //   ),
                    // ),

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
                                                  "Color History",
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
                                                  "Color History",
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
                                                "Color History",
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

                    // SliverToBoxAdapter(
                    //   child: SizedBox(
                    //     height: 140,
                    //     width: double.infinity,
                    //     child: Stack(
                    //       children: [
                    //         ClipPath(
                    //           clipper: AppBarClipper(),
                    //           child: Container(
                    //             height: 140,
                    //             color: const Color(0xff3b9499),
                    //             child: Row(
                    //               children: [
                    //                 Padding(
                    //                   padding: const EdgeInsets.all(8.0),
                    //                   child: SidebarIcon(
                    //                     icon: Icons.arrow_back_rounded,
                    //                     assetName:
                    //                         'assets/images/pop-button.png',
                    //                     onPressed: () {
                    //                       Navigator.pop(context);
                    //                     },
                    //                   ),
                    //                 ),

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
                    //               "Color History",
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
                    //               "Color History",
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
                    //             "Color History",
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

                    //                 const SizedBox(width: 60),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // 2. Body: Grid ya Empty State
                    if (completedLevels.isEmpty)
                      const SliverFillRemaining(
                        child: _EmptyHistoryState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            final columns = _columnCountForWidth(
                                constraints.crossAxisExtent);
                            return SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final level = completedLevels[index];
                                  return LevelCard(
                                    key: ValueKey(level.id),
                                    level: level,
                                    levelNumber:
                                        viewModel.levelNumberFor(level.id) ??
                                            (index + 1),
                                    palette: _paletteFor(index),
                                    isLocked: false,
                                    isBusy: _isOpeningLevel,
                                    onTap: () {
                                      final coloringProvider =
                                          Provider.of<ColoringProvider>(context,
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
                                    },
                                  );
                                },
                                childCount: completedLevels.length,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: _aspectRatioForWidth(
                                    constraints.crossAxisExtent, columns),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       decoration: const BoxDecoration(
  //         image: DecorationImage(
  //           image: AssetImage("assets/images/color.png"),
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //       child: SafeArea(
  //         child: Consumer<HomeViewModel>(
  //           builder: (context, viewModel, _) {
  //             if (viewModel.isLoading && viewModel.content == null) {
  //               return const Loader();
  //             }

  //             final completedLevels = viewModel.categories
  //                 .expand((c) => c.levels)
  //                 .where((l) => l.isCompleted)
  //                 .toList();

  //             return CustomScrollView(
  //               physics: const AlwaysScrollableScrollPhysics(),
  //               slivers: <Widget>[
  //                 SliverToBoxAdapter(
  //                   child: Row(
  //                     children: <Widget>[
  //                       Expanded(
  //                         child: SizedBox(
  //                           height: 140,
  //                           child: Stack(
  //                             children: [
  //                               ClipPath(
  //                                 clipper: AppBarClipper(),
  //                                 child: Container(
  //                                   height: 140,
  //                                   color: const Color(0xff3b9499),
  //                                   child: Row(
  //                                     children: [
  //                                       Padding(
  //                                         padding: const EdgeInsets.all(8.0),
  //                                         child: SidebarIcon(
  //                                           icon: Icons.arrow_back_rounded,
  //                                           assetName:
  //                                               'assets/images/pop-button.png',
  //                                           onPressed: () {
  //                                             Navigator.pop(context);
  //                                           },
  //                                         ),
  //                                       ),

  //                                       // Title
  //                                       Expanded(
  //                                         child: Center(
  //                                           child: FittedBox(
  //                                             fit: BoxFit.scaleDown,
  //                                             child: Stack(
  //                                               alignment: Alignment.center,
  //                                               children: [
  //                                                 // Shadow Layer
  //                                                 Transform.translate(
  //                                                   offset: const Offset(6, 6),
  //                                                   child: Text(
  //                                                     "Color History",
  //                                                     textAlign:
  //                                                         TextAlign.center,
  //                                                     style: TextStyle(
  //                                                       fontSize: 50,
  //                                                       fontFamily: "Regular",
  //                                                       fontWeight:
  //                                                           FontWeight.w900,
  //                                                       color: Colors.black
  //                                                           .withOpacity(0.35),
  //                                                       letterSpacing: 1,
  //                                                     ),
  //                                                   ),
  //                                                 ),

  //                                                 // Pink 3D Layer
  //                                                 Transform.translate(
  //                                                   offset: const Offset(3, 3),
  //                                                   child: Text(
  //                                                     "Color History",
  //                                                     textAlign:
  //                                                         TextAlign.center,
  //                                                     style: const TextStyle(
  //                                                       fontSize: 50,
  //                                                       fontFamily: "Regular",
  //                                                       fontWeight:
  //                                                           FontWeight.w900,
  //                                                       color:
  //                                                           Color(0xFFFF4FA3),
  //                                                       letterSpacing: 1,
  //                                                     ),
  //                                                   ),
  //                                                 ),

  //                                                 // Main White Text
  //                                                 Text(
  //                                                   "Color History",
  //                                                   textAlign: TextAlign.center,
  //                                                   style: const TextStyle(
  //                                                     fontSize: 50,
  //                                                     fontFamily: "Regular",
  //                                                     fontWeight:
  //                                                         FontWeight.w900,
  //                                                     color: Colors.white,
  //                                                     letterSpacing: 1,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       ),

  //                                       const SizedBox(width: 60),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: RefreshIndicator(
  //                     onRefresh: viewModel.load,
  //                     child: completedLevels.isEmpty
  //                         ? const _EmptyHistoryState()
  //                         : CustomScrollView(
  //                             physics: const AlwaysScrollableScrollPhysics(),
  //                             slivers: <Widget>[
  //                               SliverPadding(
  //                                 padding:
  //                                     const EdgeInsets.fromLTRB(12, 8, 12, 24),
  //                                 sliver: SliverLayoutBuilder(
  //                                   builder: (context, constraints) {
  //                                     final columns = _columnCountForWidth(
  //                                         constraints.crossAxisExtent);
  //                                     return SliverGrid(
  //                                       delegate: SliverChildBuilderDelegate(
  //                                         (context, index) {
  //                                           final level =
  //                                               completedLevels[index];
  //                                           final levelNumber = viewModel
  //                                                   .levelNumberFor(level.id) ??
  //                                               (index + 1);
  //                                           return LevelCard(
  //                                             key: ValueKey(level.id),
  //                                             level: level,
  //                                             levelNumber: levelNumber,
  //                                             palette: _paletteFor(index),
  //                                             isLocked: false,
  //                                             isBusy: _isOpeningLevel,
  //                                             onTap: () {
  //                                               debugPrint(
  //                                                   "History Level: ${level.title}");
  //                                               final coloringProvider =
  //                                                   Provider.of<
  //                                                           ColoringProvider>(
  //                                                       context,
  //                                                       listen: false);
  //                                               final activity =
  //                                                   level.activityItem ??
  //                                                       ActivityItem(
  //                                                         id: level.id,
  //                                                         label: level.title,
  //                                                         display: level.title,
  //                                                         color: Colors.red,
  //                                                         imagePath: level
  //                                                                 .imagePath ??
  //                                                             'assets/images/un_border_apple.webp',
  //                                                       );
  //                                               coloringProvider.setItem(
  //                                                   activity, 1,
  //                                                   level: level);

  //                                               handleTapAction(context, () {});
  //                                               _openLevel(
  //                                                   context, viewModel, level);
  //                                             },
  //                                           );
  //                                         },
  //                                         childCount: completedLevels.length,
  //                                       ),
  //                                       gridDelegate:
  //                                           SliverGridDelegateWithFixedCrossAxisCount(
  //                                         crossAxisCount: columns,
  //                                         mainAxisSpacing: 12,
  //                                         crossAxisSpacing: 12,
  //                                         childAspectRatio:
  //                                             _aspectRatioForWidth(
  //                                           constraints.crossAxisExtent,
  //                                           columns,
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                   ),
  //                 ),

  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      children: <Widget>[
        Image.asset(
          "assets/images/colors.png",
          width: size.width * .5,
          height: size.height * .5,
        )
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        //   decoration: BoxDecoration(
        //     color: Colors.white.withValues(alpha: 0.94),
        //     borderRadius: BorderRadius.circular(28),
        //     boxShadow: <BoxShadow>[
        //       BoxShadow(
        //         color: const Color(0x1A16325C),
        //         blurRadius: 24,
        //         offset: const Offset(0, 14),
        //       ),
        //     ],
        //   ),
        //   child: Column(
        //     children: <Widget>[
        //       Container(
        //         width: 88,
        //         height: 88,
        //         decoration: const BoxDecoration(
        //           color: Color(0xFFFFF1D8),
        //           shape: BoxShape.circle,
        //         ),
        //         child: const Icon(
        //           Icons.palette_outlined,
        //           size: 40,
        //           color: Color(0xFFF28B1D),
        //         ),
        //       ),
        //       const SizedBox(height: 18),
        //       Text(
        //         'No levels colored yet',
        //         style: TextStyle(
        //           fontSize: 24,
        //           fontFamily: "Regular",
        //           fontWeight: FontWeight.w700,
        //           color: const Color(0xFF1F2A44),
        //         ),
        //       ),
        //       const SizedBox(height: 8),
        //       Text(
        //         'Start coloring and your completed levels will appear here automatically.',
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           fontSize: 16,
        //           fontFamily: "Regular",
        //           fontWeight: FontWeight.w500,
        //           color: const Color(0xFF65738A),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
