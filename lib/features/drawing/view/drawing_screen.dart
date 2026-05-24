import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
import 'package:play_craft_kids/features/skins/viewmodel/skins_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/level_preview.dart';
import '../../../shared/utils/interaction_feedback.dart';
import '../../../shared/widgets/loader.dart';
import '../model/drawing_brush_size.dart';
import '../../drawing/model/color_model.dart';
import '../../drawing/model/drawing_session_snapshot.dart';
import '../../levels/model/level_model.dart';
import '../services/save_service.dart';
import 'controllers/guided_painting_controllers.dart';
import 'widgets/canvas_widget.dart';
import '../viewmodel/drawing_viewmodel.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({
    super.key,
    required this.levelId,
    this.drawingSessionId,
  });

  final String levelId;
  final String? drawingSessionId;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen>
    with WidgetsBindingObserver {
  final GlobalKey _canvasRepaintKey = GlobalKey();
  final GlobalKey _canvasWidgetKey = GlobalKey();
  final SaveService _saveService = const SaveService();
  String? _handledCompletionLevelId;
  Future<Uint8List?>? _rewardCaptureFuture;
  GuidedCanvasPhase _canvasPhase = GuidedCanvasPhase.outline;
  bool _coloringEnabled = false;
  bool _awaitingPartTick = false;
  bool _showCompletionCelebration = false;
  bool _showColorPalette = false;
  bool _showPreviewOverlay = false;
  bool _showAgainButton = false;
  bool _showAgainUsed = false;
  DrawingSessionSnapshot? _latestSnapshot;
  Timer? _historySaveDebounce;
  bool _isSavingHistory = false;
  Future<void>? _pendingSaveTask;
  late final DrawingViewModel _viewModel;
  late final DrawingStepController _previewDrawingController;
  late final ColoringStepController _previewColoringController;
  final ActivePartHighlighter _previewHighlighter =
      const ActivePartHighlighter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = context.read<DrawingViewModel>();
    _previewDrawingController = DrawingStepController();
    _previewColoringController = ColoringStepController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _viewModel.markActive(true);
      _viewModel.loadLevel(
        widget.levelId,
        drawingSessionId: widget.drawingSessionId,
      );
      _viewModel.addListener(_onViewModelChange);
    });
  }

  void _onViewModelChange() {
    if (!mounted) return;
    final viewModel = context.read<DrawingViewModel>();
    final level = viewModel.level;

    if (level != null &&
        level.id == widget.levelId &&
        viewModel.isCompleted &&
        viewModel.rewardStars != null &&
        _handledCompletionLevelId != level.id) {
      _handledCompletionLevelId = level.id;
      _showFeedbackAndEvaluationDialog(viewModel, level);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _historySaveDebounce?.cancel();
    _previewDrawingController.dispose();
    _previewColoringController.dispose();
    _persistHistorySnapshot(captureThumbnail: true);
    try {
      _viewModel.removeListener(_onViewModelChange);
      _viewModel.markActive(false);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DrawingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId ||
        oldWidget.drawingSessionId != widget.drawingSessionId) {
      _handledCompletionLevelId = null;
      _rewardCaptureFuture = null;
      _canvasPhase = GuidedCanvasPhase.outline;
      _coloringEnabled = false;
      _awaitingPartTick = false;
      _showCompletionCelebration = false;
      _showColorPalette = false;
      _latestSnapshot = null;
      _historySaveDebounce?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _viewModel.loadLevel(
          widget.levelId,
          drawingSessionId: widget.drawingSessionId,
        );
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _persistHistorySnapshot(captureThumbnail: true);
    }
  }

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
          backgroundColor: Colors.white,
          body: PopScope(
            canPop: false,
            onPopInvoked: (didPop) async {
              if (didPop) return;

              // Capture final state before exiting
              await _persistHistorySnapshot(captureThumbnail: true);

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: SafeArea(
              child: Consumer<DrawingViewModel>(
                builder: (context, viewModel, _) {
                  final isReady = !viewModel.isLoading &&
                      viewModel.level?.id == widget.levelId;

                  if (!isReady) {
                    if (viewModel.errorMessage != null) {
                      return Center(child: Text(viewModel.errorMessage!));
                    }
                    return const Loader();
                  }

                  final level = viewModel.level!;

                  return Center(
                    child: Container(
                      // constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/bg.png"),
                              fit: BoxFit.cover)
                          // color: Colors.white,
                          // borderRadius: BorderRadius.circular(32),
                          // boxShadow: const [
                          //   BoxShadow(
                          //     color: Color(0x33000000),
                          //     blurRadius: 35,
                          //     offset: Offset(0, 15),
                          //   ),
                          // ],
                          ),
                      child: Stack(
                        children: [
                          // Center Content
                          Column(
                            children: [
                              // const SizedBox(height: 32),
                              // Preview Overlay - shows at top when active
                              // if (_showPreviewOverlay)
                              //   Container(
                              //     width: double.infinity,
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 16, vertical: 12),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       borderRadius: BorderRadius.circular(12),
                              //     ),
                              //     child: Column(
                              //       children: [
                              //         Text(
                              //           'Color like this:',
                              //           style: GoogleFonts.fredoka(
                              //             fontSize: 20,
                              //             fontWeight: FontWeight.w600,
                              //             color: Colors.black87,
                              //           ),
                              //         ),
                              //         const SizedBox(height: 12),
                              //         Container(
                              //           width: 160,
                              //           height: 160,
                              //           decoration: BoxDecoration(
                              //             color: Colors.white,
                              //             borderRadius:
                              //                 BorderRadius.circular(12),
                              //             border: Border.all(
                              //                 color: Colors.grey.shade300,
                              //                 width: 2),
                              //           ),
                              //           child: CustomPaint(
                              //             painter: AdvancedCanvasPainter(
                              //               level: level,
                              //               paths: Map.fromEntries(
                              //                 level.regions.map((r) {
                              //                   return MapEntry(
                              //                       r.id,
                              //                       r.toPath(
                              //                           const Size(160, 160)));
                              //                 }),
                              //               ),
                              //               paintPaths: {},
                              //               dashedPaths: {},
                              //               metricsCache: {},
                              //               filledRegions: Map.fromEntries(
                              //                 level.regions.map((r) {
                              //                   final targetColorId = level
                              //                       .getTargetColorIdForRegion(
                              //                           r.id);
                              //                   if (targetColorId != null) {
                              //                     for (final color
                              //                         in level.palette) {
                              //                       if (color.id ==
                              //                           targetColorId) {
                              //                         return MapEntry(
                              //                             r.id, color.color);
                              //                       }
                              //                     }
                              //                   }
                              //                   return MapEntry(
                              //                       r.id, Colors.white);
                              //                 }),
                              //               ),
                              //               drawingController:
                              //                   _previewDrawingController,
                              //               coloringController:
                              //                   _previewColoringController,
                              //               activePartHighlighter:
                              //                   _previewHighlighter,
                              //               fillAnimationValue: 0,
                              //               activeFillRegionId: null,
                              //               activeFillRegionOriginalColor: null,
                              //               repaint: Listenable.merge([]),
                              //             ),
                              //             size: const Size(160, 160),
                              //           ),
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // // Show Again button (appears after 10 seconds, only once)
                              // if (_showAgainButton && !_showPreviewOverlay)
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 16, vertical: 8),
                              //     child: ElevatedButton(
                              //       onPressed: () {
                              //         // Call Show Again handler in CanvasWidget
                              //         final canvasState = _canvasWidgetKey
                              //             .currentState as dynamic;
                              //         try {
                              //           canvasState?.showPreviewAgain();
                              //         } catch (_) {}
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: Colors.blue.shade600,
                              //         foregroundColor: Colors.white,
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(24),
                              //         ),
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 40, vertical: 16),
                              //         elevation: 8,
                              //       ),
                              //       child: Text(
                              //         'Show Again',
                              //         style: GoogleFonts.fredoka(
                              //           fontSize: 18,
                              //           fontWeight: FontWeight.w600,
                              //         ),
                              //       ),
                              //     ),
                              //   ),

                              // if (!_showPreviewOverlay) ...[

                              // ],
                              Text(
                                'LEVEL ${viewModel.levelNumber ?? 1}',
                                style: GoogleFonts.fredoka(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF222222),
                                  letterSpacing: 2.0,
                                ),
                              ),
                              // const SizedBox(height: 8),
                              // Text(
                              //   'Filled: ${viewModel.filledRegions.length} / ${level.regions.length}',
                              //   style: const TextStyle(
                              //     color: Colors.grey,
                              //     fontSize: 12,
                              //   ),
                              // ),
                              const SizedBox(height: 8),
                              _LevelBadge(
                                title: level.title,
                                levelNumber: viewModel.levelNumber ?? 1,
                                level: level,
                              ),
                              const SizedBox(height: 10),
                              _BrushSizeSelector(viewModel: viewModel),

                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      // width: 2048,
                                      height: 2048,
                                      child: CanvasWidget(
                                        key: _canvasWidgetKey,
                                        level: level,
                                        repaintBoundaryKey: _canvasRepaintKey,
                                        guideAsset: null, // we use paths n
                                        filledRegions: viewModel.filledRegions,
                                        onFill: viewModel.fillRegionAt,
                                        enableColoring: _coloringEnabled &&
                                            !_awaitingPartTick,
                                        onPhaseChanged: _onCanvasPhaseChanged,
                                        onRegionFilled: _onRegionFilled,
                                        initialSnapshot:
                                            viewModel.initialSessionSnapshot,
                                        onSnapshotChanged:
                                            _handleCanvasSnapshotChanged,
                                        onPreviewStateChanged: (isShowing) {
                                          setState(() {
                                            _showPreviewOverlay = isShowing;
                                          });
                                        },
                                        onShowAgainButtonStateChanged:
                                            (isShowing) {
                                          setState(() {
                                            _showAgainButton = isShowing;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              _buildBottomAction(level, viewModel),
                              const SizedBox(height: 32),
                            ],
                          ),

                          // Left Column Icons
                          Positioned(
                            left: 16,
                            top: 1,
                            child: Column(
                              children: [
                                SidebarIcon(
                                  icon: Icons.arrow_back_rounded,
                                  assetName: 'assets/images/pop-button.png',
                                  onPressed: () {
                                    // PopScope handles the final capture
                                    Navigator.pop(context);
                                  },
                                ),
                                const SizedBox(height: 16),
                                // SidebarIcon(
                                //   icon: Icons.edit_rounded,
                                //   assetName: 'assets/images/pen.png',
                                //   onPressed: () async {
                                //     await _persistHistorySnapshot(
                                //         captureThumbnail: true);
                                //     if (context.mounted) {
                                //       Navigator.pushNamed(
                                //           context, AppRoutes.skins);
                                //     }
                                //   },
                                // ),
                                SidebarIcon(
                                  icon: Icons.edit_rounded,
                                  assetName: 'assets/images/pen.png',
                                  onPressed: () {
                                    // un-awaited: Yeh background mein chalta rahega
                                    _persistHistorySnapshot(
                                        captureThumbnail: true);

                                    // Fauran next screen par bhej dein
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                          context, AppRoutes.skins);
                                    }
                                  },
                                ),

                                const SizedBox(height: 16),
                                // SidebarIcon(
                                //   icon: Icons.photo_library_rounded,
                                //   assetName: 'assets/images/photo.png',
                                //   onPressed: () => Navigator.pushNamed(
                                //       context, AppRoutes.levels),
                                // ),
                              ],
                            ),
                          ),
// Right Column Icons
                          Positioned(
                            right: 16,
                            top: 1,
                            child: Column(
                              children: [
                                SidebarIcon(
                                  icon: Icons.settings_rounded,
                                  assetName: 'assets/images/setting.png',
                                  onPressed: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: "Settings",
                                      barrierColor: Colors.transparent,
                                      transitionDuration:
                                          const Duration(milliseconds: 250),
                                      pageBuilder: (_, __, ___) =>
                                          const SettingsDialog(),
                                      transitionBuilder:
                                          (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutBack,
                                            ),
                                            child: child,
                                          ),
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
                                SidebarIcon(
                                  icon: Icons.photo_library_rounded,
                                  assetName: 'assets/images/photo.png',
                                  onPressed: () async {
                                    await _persistHistorySnapshot(
                                        captureThumbnail: true);
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                          context, AppRoutes.levels);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (_showCompletionCelebration)
                            const Positioned.fill(
                              child: IgnorePointer(
                                child: _LevelCompleteCelebration(),
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
        ));
  }

  Widget _buildBottomAction(LevelModel level, DrawingViewModel viewModel) {
    final isColorPhase = _canvasPhase == GuidedCanvasPhase.coloring;
    Widget actionChild = const SizedBox(height: 86);

    if (_awaitingPartTick && isColorPhase) {
      actionChild = _TickActionButton(
        onPressed: _unlockNextColorPart,
      );
    } else if (isColorPhase && !_coloringEnabled) {
      actionChild = _TickActionButton(
        onPressed: _startColoringPhase,
      );
    } else if (isColorPhase && _coloringEnabled && _showColorPalette) {
      actionChild = _ColorPaletteRow(
        palette: level.palette,
        selectedColorId: viewModel.selectedColor?.id,
        onSelect: _handleColorSelected,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        actionChild,
      ],
    );
  }

  void _onCanvasPhaseChanged(GuidedCanvasPhase phase) {
    if (!mounted) return;
    if (_canvasPhase == phase) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _canvasPhase = phase;
        if (phase == GuidedCanvasPhase.outline) {
          _coloringEnabled = false;
          _awaitingPartTick = false;
          _showColorPalette = false;
        } else if (phase == GuidedCanvasPhase.coloring) {
          final viewModel = context.read<DrawingViewModel>();
          if (viewModel.activeDrawingSessionId != null) {
            _coloringEnabled = true;
            _awaitingPartTick = false;
            _showColorPalette = true;
          }
        }
      });
    });
  }

  void _startColoringPhase() {
    if (_canvasPhase != GuidedCanvasPhase.coloring) return;
    setState(() {
      _coloringEnabled = true;
      _awaitingPartTick = false;
      _showColorPalette = true;
    });
  }

  void _onRegionFilled(String _) {
    if (!mounted) return;
    final viewModel = context.read<DrawingViewModel>();
    if (viewModel.isCompleted) return;
    if (_canvasPhase != GuidedCanvasPhase.coloring) return;

    setState(() {
      _awaitingPartTick = true;
    });
  }

  void _unlockNextColorPart() {
    if (!mounted) return;
    setState(() {
      _awaitingPartTick = false;
      _showColorPalette = true;
    });
  }

  void _handleColorSelected(DrawingColorModel color) {
    final viewModel = context.read<DrawingViewModel>();
    viewModel.selectColor(color);
    if (!mounted) return;
    setState(() {
      _showColorPalette = false;
    });
  }

  void _handleCanvasSnapshotChanged(DrawingSessionSnapshot snapshot) {
    _latestSnapshot = snapshot;
    _historySaveDebounce?.cancel();
    _historySaveDebounce = Timer(
      const Duration(milliseconds: 900),
      () => _persistHistorySnapshot(captureThumbnail: false),
    );
  }

  Future<void> _persistHistorySnapshot({
    required bool captureThumbnail,
  }) async {
    if (_isSavingHistory) {
      if (!captureThumbnail) return;
      if (_pendingSaveTask != null) {
        await _pendingSaveTask;
      }
    }

    final snapshot = _latestSnapshot;
    if (snapshot == null ||
        !snapshot.hasVisibleProgress ||
        (!mounted && !captureThumbnail)) {
      return;
    }

    _isSavingHistory = true;
    final completer = Completer<void>();
    _pendingSaveTask = completer.future;

    try {
      Uint8List? thumbnailBytes;
      if (captureThumbnail) {
        thumbnailBytes = await _saveService.capture(
          _canvasRepaintKey,
          pixelRatioOverride: 0.5,
        );
      }

      await _viewModel.saveHistorySnapshot(
        snapshot: snapshot,
        thumbnailBytes: thumbnailBytes,
      );
    } catch (_) {
      // ignore silently to prevent ui crashes
    } finally {
      _isSavingHistory = false;
      completer.complete();
    }
  }

  Future<void> _openRewardScreen(
    DrawingViewModel viewModel,
    LevelModel level,
  ) async {
    final completedImageBytes =
        await (_rewardCaptureFuture ?? _saveService.capture(_canvasRepaintKey));
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.reward,
      arguments: RewardRouteArgs(
        levelId: level.id,
        levelTitle: level.title,
        levelNumber: viewModel.levelNumber ?? 1,
        coins: viewModel.rewardCoins ?? level.rewardCoins,
        stars: viewModel.rewardStars ?? level.stars,
        nextLevelId: viewModel.nextLevelId,
        completedImageBytes: completedImageBytes,
      ),
    );
  }

  Future<void> _playCompletionCelebration(
    DrawingViewModel viewModel,
    LevelModel level,
  ) async {
    _rewardCaptureFuture ??= _saveService.capture(_canvasRepaintKey);

    if (mounted) {
      setState(() {
        _showCompletionCelebration = true;
      });
    }

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    try {
      // Keep the celebration overlay visible while we capture the canvas
      // and transition to the reward route, so there is no visual gap.
      await _openRewardScreen(viewModel, level);
    } finally {
      if (mounted) {
        setState(() {
          _showCompletionCelebration = false;
        });
      }
    }
  }

  void _openLevelById(String levelId) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.drawing,
      arguments: DrawingRouteArgs(levelId: levelId),
    );
  }

  Future<void> _showFeedbackAndEvaluationDialog(
    DrawingViewModel viewModel,
    LevelModel level,
  ) async {
    final score = viewModel.accuracyScore;
    final isSuccess = score >= 0.70;

    if (isSuccess) {
      _rewardCaptureFuture ??= _saveService.capture(_canvasRepaintKey);

      try {
        final skinsViewModel = context.read<SkinsViewModel>();
        skinsViewModel.unlockByLevel(viewModel.levelNumber ?? 1);
      } catch (_) {}
    }

    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Evaluation",
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _EvaluationDialogContent(
          level: level,
          score: score,
          isSuccess: isSuccess,
          coins: viewModel.rewardCoins ?? level.rewardCoins,
          stars: viewModel.rewardStars ?? level.stars,
          userFilledRegions: Map<String, Color>.from(viewModel.filledRegions),
          onTryAgain: () {
            Navigator.pop(dialogContext);
            viewModel.resetCanvas();
            _handledCompletionLevelId = null;
            if (mounted) {
              setState(() {
                // Keep in coloring phase — the child already drew the outline.
                // They only need to redo the coloring.
                _canvasPhase = GuidedCanvasPhase.coloring;
                _coloringEnabled = true;
                _awaitingPartTick = false;
                _showColorPalette = true;
              });
            }
          },
          onNextLevel: () {
            Navigator.pop(dialogContext);
            final nextLevelId = viewModel.nextLevelId;
            if (nextLevelId != null) {
              _openLevelById(nextLevelId);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (_) => false,
              );
            }
          },
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
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
  }
}

class _TickActionButton extends StatelessWidget {
  const _TickActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // This is a circular button with a check **Good** icon, used for both starting the coloring phase and confirming region fills.
    return GestureDetector(
      onTap: tapActionCallback(context, () async => onPressed()),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF31B24C),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SidebarIcon extends StatelessWidget {
  const SidebarIcon({
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
        width: 50,
        height: 50,
        child: assetName != null
            ? Image.asset(
                assetName!,
                fit: BoxFit.contain,
              )
            : Icon(
                icon,
                color: const Color(0xFF666666),
                size: 28,
              ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.title,
    required this.levelNumber,
    required this.level,
  });

  final String title;
  final int levelNumber;
  final LevelModel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEAF5FF), width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFFFE082),
            child: ClipOval(
              child: Image.asset(
                levelNumber % 2 == 0
                    ? 'assets/images/girl.png'
                    : 'assets/images/boy.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.face, size: 28, color: Colors.black54),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Bouncy, glowing preview button showing color guide when clicked
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showColoringGuideDialog(context, level);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFFD54F),
                  width: 2.5,
                ),
              ),
              child: LevelPreview(
                level: level,
                size: 52,
                backgroundColor: const Color(0xFFF8FBFF),
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(12),
                animate: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPaletteRow extends StatelessWidget {
  const _ColorPaletteRow({
    required this.palette,
    required this.selectedColorId,
    required this.onSelect,
  });

  final List<DrawingColorModel> palette;
  final String? selectedColorId;
  final Function(DrawingColorModel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      // mainAxisAlignment: MainAxisAlignment.center,
      children: palette.map((colorOption) {
        final isSelected = selectedColorId == colorOption.id;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () => onSelect(colorOption),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 70 : 66,
              height: isSelected ? 70 : 66,
              decoration: BoxDecoration(
                color: colorOption.color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : Colors.white.withValues(alpha: 0.6),
                  width: isSelected ? 4.0 : 2.5,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BrushSizeSelector extends StatelessWidget {
  const _BrushSizeSelector({required this.viewModel});

  final DrawingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DrawingBrushSize>(
      valueListenable: viewModel.brushSizeListenable,
      builder: (context, selectedSize, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: DrawingBrushSize.values.map((size) {
              final isSelected = size == selectedSize;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _BrushSizeButton(
                  size: size,
                  isSelected: isSelected,
                  onTap: () => viewModel.selectBrushSize(size),
                ),
              );
            }).toList(growable: false),
          ),
        );
      },
    );
  }
}

class _BrushSizeButton extends StatelessWidget {
  const _BrushSizeButton({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final DrawingBrushSize size;
  final bool isSelected;
  final VoidCallback onTap;

  double get _previewDiameter {
    switch (size) {
      case DrawingBrushSize.thin:
        return 8;
      case DrawingBrushSize.standard:
        return 13;
      case DrawingBrushSize.thick:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapActionCallback(context, onTap),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF2D7) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFFF9800) : const Color(0xFFE1E1E1),
            width: isSelected ? 2.2 : 1.4,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: _previewDiameter,
          height: _previewDiameter,
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFF111111) : const Color(0xFF666666),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LevelCompleteCelebration extends StatelessWidget {
  const _LevelCompleteCelebration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 420),
        child: Lottie.asset(
          'assets/data/celebrate.json',
          repeat: false,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _EvaluationDialogContent extends StatefulWidget {
  const _EvaluationDialogContent({
    required this.level,
    required this.score,
    required this.isSuccess,
    required this.coins,
    required this.stars,
    required this.userFilledRegions,
    required this.onTryAgain,
    required this.onNextLevel,
  });

  final LevelModel level;
  final double score;
  final bool isSuccess;
  final int coins;
  final int stars;
  final Map<String, Color> userFilledRegions;
  final VoidCallback onTryAgain;
  final VoidCallback onNextLevel;

  @override
  State<_EvaluationDialogContent> createState() =>
      _EvaluationDialogContentState();
}

class _EvaluationDialogContentState extends State<_EvaluationDialogContent>
    with SingleTickerProviderStateMixin {
  bool _showGuide = false;
  late final AnimationController _zoomController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _zoomController,
        curve: Curves.easeInOut,
      ),
    );
    _zoomController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accuracyPercent = (widget.score * 100).toInt();
    final themeColor =
        widget.isSuccess ? const Color(0xFF4CAF50) : const Color(0xFFFF5722);
    final darkThemeColor =
        widget.isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: themeColor,
                width: 6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isSuccess)
                  SizedBox(
                    height: 100,
                    child: Lottie.asset(
                      'assets/data/celebrate.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),

                const SizedBox(height: 12),

                // 3D Styled Feedback Header Title
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: darkThemeColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: darkThemeColor,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.isSuccess
                        ? (accuracyPercent >= 90 ? 'EXCELLENT!' : 'GOOD!')
                        : 'KEEP TRYING!',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        const Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Subtitle Feedback Text
                Text(
                  widget.isSuccess
                      ? 'Awesome work! You scored $accuracyPercent% correctly!'
                      : 'You scored $accuracyPercent%! Try again to match all colors!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 24),

                // Level Preview Image with interactive click guide & zoom
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showGuide = !_showGuide;
                    });
                    HapticFeedback.mediumImpact();
                  },
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 180,
                          height: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F8FF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _showGuide
                                  ? const Color(0xFFFFC107)
                                  : const Color(0xFFE0E0E0),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                              if (_showGuide)
                                BoxShadow(
                                  color: const Color(0xFFFFC107)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              LevelPreview(
                                level: widget.level,
                                size: 150,
                                animate: false,
                                filledRegions: _showGuide
                                    ? null
                                    : widget.userFilledRegions,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFFE082), width: 1.5),
                        ),
                        child: Text(
                          _showGuide
                              ? "Target Guide Image! 🌟"
                              : "Click image to see how to color!",
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stars rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isGolden = widget.isSuccess && (index < widget.stars);
                    return Icon(
                      isGolden
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 48,
                      color: isGolden
                          ? const Color(0xFFFFC107)
                          : Colors.grey.shade300,
                    );
                  }),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!widget.isSuccess)
                      Expanded(
                        child: _evaluationActionButton(
                          text: "TRY AGAIN",
                          backgroundColor: const Color(0xFFFF5722),
                          borderColor: const Color(0xFFD84315),
                          onTap: widget.onTryAgain,
                        ),
                      )
                    else ...[
                      Expanded(
                        child: _evaluationActionButton(
                          text: "REPLAY",
                          backgroundColor: const Color(0xFF5AA6FF),
                          borderColor: const Color(0xFF2D64C8),
                          onTap: widget.onTryAgain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _evaluationActionButton(
                          text: "NEXT",
                          backgroundColor: const Color(0xFF7DE952),
                          borderColor: const Color(0xFF45A92B),
                          onTap: widget.onNextLevel,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _evaluationActionButton({
    required String text,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showColoringGuideDialog(BuildContext context, LevelModel level) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "ColoringGuide",
    barrierColor: Colors.black.withValues(alpha: 0.7),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Material(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFC107),
                  width: 6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                  // BoxShadow(
                  //   color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                  //   blurRadius: 30,
                  //   spreadRadius: 8,
                  // ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Styled Header Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: const Color(0xFFFFA000), width: 4),
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: Color(0xFFFFA000),
                      //     offset: Offset(0, 6),
                      //   ),
                      // ],
                    ),
                    child: Text(
                      'COLOR GUIDE!',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        // shadows: const [
                        //   // Shadow(
                        //   //   color: Colors.black26,
                        //   //   offset: Offset(0, 2),
                        //   //   blurRadius: 2,
                        //   // ),
                        // ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Big beautiful Level Preview with a zoom effect
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(16),
                          // decoration: BoxDecoration(
                          //   image: DecorationImage(image: image),
                          //   color: const Color(0xFFF9FBE7),
                          //   shape: BoxShape.circle,
                          //   border: Border.all(
                          //     color: const Color(0xFFFFE082),
                          //     width: 5,
                          //   ),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.black.withValues(alpha: 0.1),
                          //       blurRadius: 15,
                          //       offset: const Offset(0, 8),
                          //     ),
                          //   ],
                          // ),

                          child: LevelPreview(
                            level: level,
                            size: 180,
                            animate: true,
                            style: LevelPreviewStyle.colored,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Guidance text
                  Text(
                    'Color your picture like this to score 100%!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // OK Button
                  GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      height: 52,
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF388E3C), width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF388E3C),
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'GOT IT!',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        ),
      );
    },
  );
}
