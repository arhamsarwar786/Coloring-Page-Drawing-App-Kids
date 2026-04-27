import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

              final allLevels = viewModel.categories
                  .expand((category) => category.levels)
                  .toList(growable: false);
              if (allLevels.isEmpty) {
                return const SizedBox.shrink();
              }

              return RefreshIndicator(
                onRefresh: _isOpeningLevel ? () async {} : viewModel.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          14,
                          AppSpacing.lg,
                          10,
                        ),
                        child: Text(
                          viewModel.content?.appTitle ?? AppStrings.appTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final columns =
                              _columnCountForWidth(constraints.crossAxisExtent);
                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final level = allLevels[index];
                                final levelNumber =
                                    viewModel.levelNumberFor(level.id) ??
                                        index + 1;
                                return _LevelCard(
                                  level: level,
                                  levelNumber: levelNumber,
                                  palette: _paletteFor(index),
                                  isBusy: _isOpeningLevel,
                                  onTap: () =>
                                      _openLevel(context, viewModel, level),
                                );
                              },
                              childCount: allLevels.length,
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

      await Navigator.pushNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(
          levelId: level.id,
          levelTitle: level.title,
          levelNumber: viewModel.levelNumberFor(level.id),
        ),
      );

      if (!context.mounted) return;
      await context.read<HomeViewModel>().load();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningLevel = false;
        });
      }
    }
  }

  _CardPalette _paletteFor(int index) {
    const palettes = <_CardPalette>[
      _CardPalette(
        outerTop: Color(0xFF66BAF9),
        outerBottom: Color(0xFF2F8BDB),
        innerTop: Color(0xFF95D8FF),
        innerBottom: Color(0xFF66BDF4),
        edge: Color(0xFF2674C3),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFD34D),
        outerBottom: Color(0xFFF0B52B),
        innerTop: Color(0xFFFFE27B),
        innerBottom: Color(0xFFFFCF49),
        edge: Color(0xFFD39B16),
      ),
      _CardPalette(
        outerTop: Color(0xFF63DDD7),
        outerBottom: Color(0xFF27B7B6),
        innerTop: Color(0xFF96F0E4),
        innerBottom: Color(0xFF59D3CF),
        edge: Color(0xFF219795),
      ),
      _CardPalette(
        outerTop: Color(0xFFB6ED64),
        outerBottom: Color(0xFF7DC83B),
        innerTop: Color(0xFFD4F68F),
        innerBottom: Color(0xFFB0E45D),
        edge: Color(0xFF69AB2A),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFB156),
        outerBottom: Color(0xFFF37A22),
        innerTop: Color(0xFFFFCB82),
        innerBottom: Color(0xFFFFA14A),
        edge: Color(0xFFD36A18),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFAE58),
        outerBottom: Color(0xFFF18832),
        innerTop: Color(0xFFFFD295),
        innerBottom: Color(0xFFFFA550),
        edge: Color(0xFFD26A21),
      ),
      _CardPalette(
        outerTop: Color(0xFFBC86FF),
        outerBottom: Color(0xFF8B52DF),
        innerTop: Color(0xFFD9B0FF),
        innerBottom: Color(0xFFB67BF8),
        edge: Color(0xFF7542C9),
      ),
      _CardPalette(
        outerTop: Color(0xFFA7DEFF),
        outerBottom: Color(0xFF65BEEB),
        innerTop: Color(0xFFCDEEFF),
        innerBottom: Color(0xFF99D6F8),
        edge: Color(0xFF529FC9),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFA6C8),
        outerBottom: Color(0xFFEC6796),
        innerTop: Color(0xFFFFCBDF),
        innerBottom: Color(0xFFFF96BE),
        edge: Color(0xFFD55282),
      ),
      _CardPalette(
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

class _LevelCard extends StatefulWidget {
  const _LevelCard({
    required this.level,
    required this.levelNumber,
    required this.palette,
    required this.isBusy,
    required this.onTap,
  });

  final LevelModel level;
  final int levelNumber;
  final _CardPalette palette;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _isPressed = false;

  void _updatePressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);
    final glowColor = Color.lerp(
      widget.palette.outerTop,
      Colors.white,
      0.16,
    )!;

    return IgnorePointer(
      ignoring: widget.isBusy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: widget.isBusy ? 0.72 : 1,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1,
          duration: Duration(milliseconds: _isPressed ? 110 : 320),
          curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _updatePressed(true),
            onTapUp: (_) => _updatePressed(false),
            onTapCancel: () => _updatePressed(false),
            onTap: tapActionCallback(context, widget.onTap),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: widget.palette.edge.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: borderRadius,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      widget.palette.outerTop,
                      widget.palette.outerBottom,
                    ],
                  ),
                  border: Border.all(
                    color: widget.palette.edge,
                    width: 3.4,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          widget.palette.innerTop,
                          widget.palette.innerBottom,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const <double>[0, 0.16, 0.42, 1],
                                colors: <Color>[
                                  Colors.white.withValues(alpha: 0.38),
                                  Colors.white.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.04),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 10,
                          height: 40,
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(alpha: 0.34),
                                    Colors.white.withValues(alpha: 0.06),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LevelCardFramePainter(
                              radius: 26,
                              edgeColor: widget.palette.edge,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 34,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'LEVEL ${widget.levelNumber}',
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.fredoka(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,

                                        // Neon text base color (important)
                                        color: const Color(0xFFE8FFE8),

                                        shadows: [
                                          // Inner glow (sharp readable core)
                                          Shadow(
                                            color: const Color(0xFF7CFF7C)
                                                .withValues(
                                                    alpha: _isPressed
                                                        ? 0.95
                                                        : 0.85),
                                            blurRadius: _isPressed ? 6 : 5,
                                          ),

                                          // Main neon glow
                                          Shadow(
                                            color: const Color(0xFF00FF88)
                                                .withValues(
                                                    alpha: _isPressed
                                                        ? 0.85
                                                        : 0.75),
                                            blurRadius: _isPressed ? 14 : 12,
                                          ),

                                          // Outer soft aura (premium look)
                                          Shadow(
                                            color: const Color(0xFF00C853)
                                                .withValues(
                                                    alpha: _isPressed
                                                        ? 0.55
                                                        : 0.45),
                                            blurRadius: _isPressed ? 26 : 22,
                                          ),

                                          // subtle depth shadow (keeps readability)
                                          Shadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.25),
                                            offset: const Offset(0, 2),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                   
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.26),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.58,
                                        ),
                                        width: 1.8,
                                      ),
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, -1),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCardFramePainter extends CustomPainter {
  const _LevelCardFramePainter({
    required this.radius,
    required this.edgeColor,
  });

  final double radius;
  final Color edgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final innerHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withValues(alpha: 0.72);

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = edgeColor.withValues(alpha: 0.16);

    canvas.drawRRect(rrect.deflate(1.2), innerHighlightPaint);
    canvas.drawRRect(rrect.deflate(3.0), innerShadowPaint);

    final bottomShadeRect = Rect.fromLTWH(
      6,
      size.height * 0.56,
      size.width - 12,
      size.height * 0.28,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(bottomShadeRect, Radius.circular(radius - 8)),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            edgeColor.withValues(alpha: 0.08),
          ],
        ).createShader(bottomShadeRect),
    );
  }

  @override
  bool shouldRepaint(covariant _LevelCardFramePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.edgeColor != edgeColor;
  }
}

class _LevelCardIconPainter extends CustomPainter {
  const _LevelCardIconPainter({
    required this.level,
    required this.fillColor,
  });

  final LevelModel level;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    const sourceSize = Size(100, 100);
    final scale = size.shortestSide / sourceSize.shortestSide;
    final previewWidth = sourceSize.width * scale;
    final previewHeight = sourceSize.height * scale;
    final dx = (size.width - previewWidth) / 2;
    final dy = (size.height - previewHeight) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor
      ..isAntiAlias = true;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF151515)
      ..isAntiAlias = true;

    for (final region in level.regions) {
      final path = region.toPath(sourceSize);

      canvas.save();
      canvas.translate(0, 2.4);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, outlinePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LevelCardIconPainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.fillColor != fillColor;
  }
}

class _CardPalette {
  const _CardPalette({
    required this.outerTop,
    required this.outerBottom,
    required this.innerTop,
    required this.innerBottom,
    required this.edge,
  });

  final Color outerTop;
  final Color outerBottom;
  final Color innerTop;
  final Color innerBottom;
  final Color edge;
}
