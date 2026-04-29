import 'dart:typed_data';

import 'package:asmr_coloring_app/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/level_preview.dart';
import '../../../shared/utils/interaction_feedback.dart';
import '../../../shared/widgets/loader.dart';
import '../../drawing/model/color_model.dart';
import '../../levels/model/level_model.dart';
import '../services/save_service.dart';
import 'controllers/guided_painting_controllers.dart';
import 'widgets/canvas_widget.dart';
import '../viewmodel/drawing_viewmodel.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final GlobalKey _canvasRepaintKey = GlobalKey();
  final SaveService _saveService = const SaveService();
  String? _handledCompletionLevelId;
  Future<Uint8List?>? _rewardCaptureFuture;
  GuidedCanvasPhase _canvasPhase = GuidedCanvasPhase.outline;
  bool _coloringEnabled = false;
  bool _awaitingPartTick = false;
  bool _showCompletionCelebration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<DrawingViewModel>();
      viewModel.loadLevel(widget.levelId);
      viewModel.addListener(_onViewModelChange);
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
      _playCompletionCelebration(viewModel, level);
    }
  }

  @override
  void dispose() {
    try {
      context.read<DrawingViewModel>().removeListener(_onViewModelChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DrawingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelId != widget.levelId) {
      _handledCompletionLevelId = null;
      _rewardCaptureFuture = null;
      _canvasPhase = GuidedCanvasPhase.outline;
      _coloringEnabled = false;
      _awaitingPartTick = false;
      _showCompletionCelebration = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DrawingViewModel>().loadLevel(widget.levelId);
      });
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
        body: SafeArea(
          child: Consumer<DrawingViewModel>(
            builder: (context, viewModel, _) {
              final isReady =
                  !viewModel.isLoading && viewModel.level?.id == widget.levelId;

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
                  decoration: const BoxDecoration(
                    color: Colors.white,
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
                          const SizedBox(height: 32),
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
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: SizedBox(
                                    width: 2048,
                                    height: 2048,
                                    child: CanvasWidget(
                                      level: level,
                                      repaintBoundaryKey: _canvasRepaintKey,
                                      guideAsset: null, // we use paths n
                                      filledRegions: viewModel.filledRegions,
                                      onFill: viewModel.fillRegionAt,
                                      enableColoring: _coloringEnabled &&
                                          !_awaitingPartTick,
                                      onPhaseChanged: _onCanvasPhaseChanged,
                                      onRegionFilled: _onRegionFilled,
                                    ),
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
                        top: 16,
                        child: Column(
                          children: [
                            _SidebarIcon(
                              icon: Icons.arrow_back_rounded,
                              assetName: 'assets/images/pop-button.png',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 16),
                            _SidebarIcon(
                              icon: Icons.edit_rounded,
                              assetName: 'assets/images/pen.png',
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.skins),
                            ),
                            const SizedBox(height: 16),
                            // _SidebarIcon(
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
                        top: 16,
                        child: Column(
                          children: [
                            _SidebarIcon(
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
                                  transitionBuilder: (_, animation, __, child) {
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
                            // _SidebarIcon(
                            //   icon: Icons.edit_rounded,
                            //   assetName: 'assets/images/pen.png',
                            //   onPressed: () =>
                            //       Navigator.pushNamed(context, AppRoutes.skins),
                            // ),
                            const SizedBox(height: 16),
                            _SidebarIcon(
                              icon: Icons.photo_library_rounded,
                              assetName: 'assets/images/photo.png',
                              onPressed: () => Navigator.pushNamed(
                                  context, AppRoutes.levels),
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
    );
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
    } else if (isColorPhase && _coloringEnabled) {
      actionChild = _ColorPaletteRow(
        palette: level.palette,
        selectedColorId: viewModel.selectedColor?.id,
        onSelect: viewModel.selectColor,
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

    setState(() {
      _canvasPhase = phase;
      if (phase == GuidedCanvasPhase.outline) {
        _coloringEnabled = false;
        _awaitingPartTick = false;
      }
    });
  }

  void _startColoringPhase() {
    if (_canvasPhase != GuidedCanvasPhase.coloring) return;
    setState(() {
      _coloringEnabled = true;
      _awaitingPartTick = false;
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
    });
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
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        // border: Border.all(color: const Color(0xFFEAF5FF), width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Small preview of the completed level
          LevelPreview(
            level: level,
            size: 48,
            backgroundColor: const Color(0xFFF8FBFF),
            padding: const EdgeInsets.all(6),
            borderRadius: BorderRadius.circular(12),
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
