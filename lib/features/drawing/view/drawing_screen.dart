import 'package:flutter/material.dart';
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
      context.read<DrawingViewModel>().loadLevel(widget.levelId);
    });
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
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color(0xFFF0F4F8),
        body: Consumer<DrawingViewModel>(
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

            if (viewModel.isCompleted &&
                _handledCompletionLevelId != level.id) {
              _handledCompletionLevelId = level.id;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleLevelComplete(viewModel);
              });
            }

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
                        const SizedBox(height: 16),
                        _LevelBadge(
                          title: level.title,
                          levelNumber: viewModel.levelNumber ?? 1,
                          level: level,
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
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

                    // Left Column Icons
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Column(
                        children: [
                          _SidebarIcon(
                            icon: Icons.settings_rounded,
                            assetName: 'assets/images/setting.png',
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.settings),
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
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.levels),
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
                            onPressed:
                                viewModel.canUndo ? viewModel.undo : null,
                            opacity: viewModel.canUndo ? 1.0 : 0.5,
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
                                      levelId: viewModel.nextLevelId!),
                                );
                              }
                            },
                            opacity: viewModel.nextLevelId != null ? 1.0 : 0.5,
                          ),
                          const SizedBox(height: 16),
                          _SidebarIcon(
                            icon: viewModel.level?.isFavorite ?? false
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            iconColor: const Color(0xFFD673FF),
                            backgroundColor: const Color(0xFFF3E5FF),
                            onPressed: () => viewModel.toggleFavorite(),
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
    );
  }

  Future<void> _handleLevelComplete(DrawingViewModel viewModel) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final nextLevelId = viewModel.nextLevelId;
    if (nextLevelId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(levelId: nextLevelId),
      );
    } else {
      // If there's no next level, go back to the home/levels screen
      Navigator.pop(context);
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
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAF5FF), width: 3),
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
          const SizedBox(width: 18),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(width: 18),
          // Small preview of the completed level
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12, width: 1),
            ),
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
      
      Color regionColor = Colors.grey.shade300;
      final regionName = region.id.toLowerCase();
      
      // Heuristic color mapping for the preview based on region/level names
      for (final p in level.palette) {
        final pId = p.id.toLowerCase();
        if (regionName.contains(pId) || 
           (pId == 'red' && regionName.contains('body') && level.id == 'apple') ||
           (pId == 'green' && regionName.contains('leaf')) ||
           (pId == 'brown' && regionName.contains('stem')) ||
           (pId == 'yellow' && regionName.contains('body') && level.id == 'banana') ||
           (pId == 'orange' && regionName.contains('face') && level.id == 'cat') ||
           (pId == 'white' && regionName.contains('ear') && level.id == 'cat') ||
           (pId == 'blue' && level.id == 'fish') ||
           (pId == 'yellow' && level.id == 'sunflower') ||
           (pId == 'red' && level.id == 'car') ||
           (pId == 'white' && level.id == 'football') ||
           (pId == 'blue' && level.id == 'tennis')) {
          regionColor = p.color;
          break;
        }
      }

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
                boxShadow: [
                  BoxShadow(
                    color: colorOption.color.withValues(alpha: isSelected ? 0.7 : 0.35),
                    blurRadius: isSelected ? 18 : 8,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 5),
                  ),
                  if (isSelected)
                    const BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
