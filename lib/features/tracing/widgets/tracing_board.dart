// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/constants/app_colors.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/tracing_viewmodel.dart';
import 'package:play_craft_kids/features/tracing/widgets/color_info.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_info.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_path_data.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_painter.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_widgets.dart';

class TracingBoard extends StatelessWidget {
  final TracingProvider provider;

  const TracingBoard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final String currentLetter = provider.currentLetter;
    final isFailed = provider.status == TracingStatus.failed;

    // Decide what info to show
    String word = '';
    Widget leadWidget;

    final item = provider.currentItem;

    if (item != null) {
      word = item.label;
      leadWidget = item.imagePath != null
          ? Image.asset(
              item.imagePath!,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            )
          : Text(item.display, style: const TextStyle(fontSize: 80));
    } else if (provider.activityType == ActivityType.animals) {
      final info = LetterInfo.getInfo(currentLetter);
      word = info.word;
      leadWidget = info.imagePath != null
          ? Image.asset(
              info.imagePath!,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            )
          : Text(info.animal, style: const TextStyle(fontSize: 80));
    } else {
      final info = ColorInfo.getInfo(currentLetter);
      word = info.word;
      leadWidget = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: info.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: info.color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      // Removed fixed height to let Expanded parent dictate size
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isFailed
              ? AppColors.smartRed.withValues(alpha: 0.3)
              : AppColors.white,
          width: 3,
        ),
        boxShadow: [
          // Outer shadow
          BoxShadow(
            color: isFailed
                ? AppColors.smartRed.withValues(alpha: 0.2)
                : AppColors.softPurple.withValues(
                    alpha: 0.3,
                  ), // Soft purple shadow
            blurRadius: 30,
            spreadRadius: 8,
            offset: const Offset(0, 15),
          ),
          // Inner bright light effect for 3D feel
          BoxShadow(
            color: AppColors.white,
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // TRACE AREA
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 10,
                  right: 10,
                  bottom: 150, // Leave room for letter info
                ),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final canvasSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      provider.setCanvasSize(canvasSize);
                    });

                    // Determine stroke color
                    Color activeColor = AppColors.primaryPurple;

                    return GestureDetector(
                      onPanStart: (d) {
                        final box = ctx.findRenderObject() as RenderBox;
                        provider.onPanStart(
                          box.globalToLocal(d.globalPosition),
                        );
                      },
                      onPanUpdate: (d) {
                        final box = ctx.findRenderObject() as RenderBox;
                        provider.onPanUpdate(
                          box.globalToLocal(d.globalPosition),
                        );
                      },
                      onPanEnd: (_) => provider.onPanEnd(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomPaint(
                          size: canvasSize,
                          painter: TracingPainter(
                            letter: provider.currentLetter,
                            completedStrokes: provider.completedStrokes,
                            currentStroke: provider.currentStroke,
                            wrongPoints: provider.wrongPoints,
                            activeStrokeIndex: provider.activeStrokeIndex,
                            strokeColor: activeColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ANIMATED HAND
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                  bottom: 95,
                ),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final canvasSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    final strokes = LetterPathData.getStrokes(
                      provider.currentLetter,
                    );
                    List<Offset> activePoints = [];
                    if (provider.activeStrokeIndex < strokes.length) {
                      activePoints = LetterPathData.scale(
                        strokes[provider.activeStrokeIndex],
                        canvasSize,
                      );
                    }
                    final smoothPoints = activePoints.isEmpty
                        ? <Offset>[]
                        : LetterPathData.getSmoothPoints(activePoints);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedHand(
                          points: smoothPoints,
                          isVisible: provider.status == TracingStatus.idle &&
                              smoothPoints.isNotEmpty,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 27,
                      height: 1.2,
                      color: AppColors.titlePurple,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: '$currentLetter for '),
                      TextSpan(
                        text: word,
                        style: const TextStyle(
                          color: AppColors.butterflyPink, // Playful pink
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(bottom: -10, left: -30, child: leadWidget),

            // FAILURE OVERLAY
            if (provider.status == TracingStatus.failed)
              Padding(
                padding: const EdgeInsets.all(18),
                child: FailureOverlay(
                  coverageRatio: provider.coverageRatio,
                  onRetry: provider.retry,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
