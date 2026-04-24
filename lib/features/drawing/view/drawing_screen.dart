import 'package:asmr_coloring_app/features/settings/view/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/widgets/loader.dart';
import '../../drawing/model/color_model.dart';
import '../../levels/model/level_model.dart';
import '../view/widgets/canvas_widget.dart';
import '../viewmodel/drawing_viewmodel.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key, required this.levelId});

  final String levelId;

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  String? _handledCompletionLevelId;

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
        _handledCompletionLevelId != level.id) {
      _handledCompletionLevelId = level.id;
      _handleLevelComplete(viewModel);
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
                              fontSize: 34,
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
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _ColorPaletteRow(
                            palette: level.palette,
                            selectedColorId: viewModel.selectedColor?.id,
                            onSelect: viewModel.selectColor,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                      // Manual "Next Level" Button Overlay when completed
                      if (viewModel.isCompleted)
                        Positioned(
                          bottom: 140,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                if (viewModel.nextLevelId != null) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.drawing,
                                    arguments: DrawingRouteArgs(
                                      levelId: viewModel.nextLevelId!,
                                    ),
                                  );
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.home,
                                    (_) => false,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'NEXT LEVEL',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF222222),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 32,
                                      color: Color(0xFF222222),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
                            _SidebarIcon(
                              icon: Icons.undo_rounded,
                              assetName: 'assets/images/retry.png',
                              onPressed: viewModel.undo,
                            ),
                            const SizedBox(height: 16),
                            _SidebarIcon(
                              icon: Icons.ads_click,
                              assetName: 'assets/images/ads.png',
                              onPressed: () {},
                              opacity:
                                  viewModel.nextLevelId != null ? 1.0 : 0.5,
                            ),
                            const SizedBox(height: 16),
                            _SidebarIcon(
                              icon: Icons.fast_forward_rounded,
                              assetName: 'assets/images/forward.png',
                              onPressed: () {
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
                              opacity:
                                  viewModel.nextLevelId != null ? 1.0 : 0.5,
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

  Future<void> _handleLevelComplete(DrawingViewModel viewModel) async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final nextLevelId = viewModel.nextLevelId;
    if (nextLevelId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(levelId: nextLevelId),
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
    }
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
          width: 56,
          height: 56,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: assetName != null
                ? Image.asset(assetName!, fit: BoxFit.contain)
                : Icon(icon,
                    color: iconColor ?? const Color(0xFF666666), size: 28),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        children: [
          CircleAvatar(
            radius: 24,
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
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
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
    return Row(
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
    );
  }
}
