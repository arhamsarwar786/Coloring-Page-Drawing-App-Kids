import 'package:asmr_coloring_app/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/loader.dart';
import '../../drawing/model/color_model.dart';
import '../../levels/model/level_model.dart';
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
  String? _handledCompletionLevelId;
  GuidedCanvasPhase _canvasPhase = GuidedCanvasPhase.outline;
  bool _coloringEnabled = false;
  bool _awaitingPartTick = false;

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
      _openRewardScreen(viewModel, level);
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
      _canvasPhase = GuidedCanvasPhase.outline;
      _coloringEnabled = false;
      _awaitingPartTick = false;
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
                          const SizedBox(height: 30),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40),
                              child: Center(
                                child: CanvasWidget(
                                  level: level,
                                  guideAsset: null, // we use paths n
                                  filledRegions: viewModel.filledRegions,
                                  onFill: viewModel.fillRegionAt,
                                  enableColoring:
                                      _coloringEnabled && !_awaitingPartTick,
                                  onPhaseChanged: _onCanvasPhaseChanged,
                                  onRegionFilled: _onRegionFilled,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                            const SizedBox(height: 16),
                            _SidebarIcon(
                              icon: Icons.edit_rounded,
                              assetName: 'assets/images/pen.png',
                              onPressed: () =>
                                  Navigator.pushNamed(context, AppRoutes.skins),
                            ),
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

                      // Right Column Icons
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Column(
                          children: [
                            // _SidebarIcon(
                            //   icon: Icons.undo_rounded,
                            //   assetName: 'assets/images/retry.png',
                            //   onPressed: viewModel.undo,
                            // ),
                            // const SizedBox(height: 16),
                            // _SidebarIcon(
                            //   icon: Icons.ads_click,
                            //   assetName: 'assets/images/ads.png',
                            //   onPressed: () {},
                            //   opacity:
                            //       viewModel.nextLevelId != null ? 1.0 : 0.5,
                            // ),
                            const SizedBox(height: 120),
                            _SidebarIcon(
                              icon: Icons.fast_forward_rounded,
                              assetName: 'assets/images/forward.png',
                              onPressed: viewModel.isCompleted
                                  ? null
                                  : () {
                                      if (viewModel.nextLevelId != null) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.drawing,
                                          arguments: DrawingRouteArgs(
                                            levelId: viewModel.nextLevelId!,
                                          ),
                                        );
                                      }
                                    },
                              opacity: viewModel.nextLevelId != null &&
                                      !viewModel.isCompleted
                                  ? 1.0
                                  : 0.5,
                            ),
                          ],
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

    if (_awaitingPartTick && isColorPhase) {
      return _TickActionButton(
        onPressed: _unlockNextColorPart,
      );
    }

    if (isColorPhase && !_coloringEnabled) {
      return _TickActionButton(
        onPressed: _startColoringPhase,
      );
    }

    if (isColorPhase && _coloringEnabled) {
      return _ColorPaletteRow(
        palette: level.palette,
        selectedColorId: viewModel.selectedColor?.id,
        onSelect: viewModel.selectColor,
      );
    }

    return const SizedBox(height: 86);
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

  void _openRewardScreen(DrawingViewModel viewModel, LevelModel level) {
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
      ),
    );
  }
}

class _TickActionButton extends StatelessWidget {
  const _TickActionButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 92,
        height: 92,
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
          size: 54,
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
    this.opacity = 1.0,
    this.backgroundColor = Colors.white,
    this.iconColor,
  });

  final IconData icon;
  final String? assetName;
  final VoidCallback? onPressed;
  final double opacity;
  final Color backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: assetName != null
              ? Image.asset(assetName!, fit: BoxFit.contain)
              : Icon(icon,
                  color: iconColor ?? const Color(0xFF666666), size: 28),
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
          SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(
              painter: _ReferencePreviewPainter(level: level),
              size: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferencePreviewPainter extends CustomPainter {
  final LevelModel level;

  _ReferencePreviewPainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    // We assume levels are designed for 100x100.
    // Scale it down to fit the 48x48 box with some padding.
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    // Slight padding inside the 100x100 space
    canvas.translate(10, 10);
    canvas.scale(0.8, 0.8);

    for (final region in level.regions) {
      final path = region.toPath(const Size(100, 100));

      Color regionColor = level.getTargetColorForRegion(region.id);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = regionColor
        ..isAntiAlias = true;

      canvas.drawPath(path, paint);

      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withValues(alpha: 0.3)
        ..strokeWidth = 2
        ..isAntiAlias = true;

      canvas.drawPath(path, strokePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ReferencePreviewPainter oldDelegate) =>
      oldDelegate.level != level;
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: palette.map((colorOption) {
          final isSelected = selectedColorId == colorOption.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => onSelect(colorOption),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 86 : 76,
                height: isSelected ? 86 : 76,
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
      ),
    );
  }
}
