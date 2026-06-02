// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/tracing/constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  STAR RATING WIDGET — 3 gorgeous animated stars!
// ═══════════════════════════════════════════════════════════
class StarRating extends StatefulWidget {
  final int stars;
  final double size;
  const StarRating({super.key, required this.stars, this.size = 54});

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> with TickerProviderStateMixin {
  late AnimationController _appearCtrl;
  late List<Animation<double>> _scaleAnims;
  late List<Animation<double>> _rotateAnims;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    // Entry animation
    _appearCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnims = List.generate(3, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _appearCtrl,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.elasticOut),
        ),
      );
    });

    _rotateAnims = List.generate(3, (i) {
      return Tween<double>(begin: -0.5, end: 0).animate(
        CurvedAnimation(
          parent: _appearCtrl,
          curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeOutCubic),
        ),
      );
    });

    // Continuous Pulse/Glow animation
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _appearCtrl.forward().then((_) {
      if (mounted) _pulseCtrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _appearCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isLit = i < widget.stars;

        return AnimatedBuilder(
          animation: Listenable.merge([_appearCtrl, _pulseCtrl]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnims[i].value * (isLit ? _pulseAnim.value : 1.0),
              child: Transform.rotate(
                angle: _rotateAnims[i].value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: isLit
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(
                                  0.6 * _pulseAnim.value,
                                ),
                                blurRadius: 15 * _pulseAnim.value,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isLit
                            ? [
                                AppColors.starLitGold,
                                AppColors.starLitOrange,
                              ] // Gold to Dark Orange
                            : [
                                AppColors.lavender,
                                AppColors.lavender.withOpacity(0.5),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Icon(
                        isLit
                            ? Icons.star_rounded
                            : Icons
                                .star_rounded, // Always solid, just gray if unlit
                        size: widget.size,
                        color:
                            Colors.white, // The ShaderMask applies the gradient
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SUCCESS OVERLAY
//  Shown when child finishes the letter. "Next Letter" button
//  is HERE — so child can only advance after completing.
// ═══════════════════════════════════════════════════════════
class SuccessOverlay extends StatelessWidget {
  final int stars;
  final String letter;
  final VoidCallback onNext;
  final VoidCallback onRetry;

  const SuccessOverlay({
    super.key,
    required this.stars,
    required this.letter,
    required this.onNext,
    required this.onRetry,
  });

  String get _message {
    switch (stars) {
      case 3:
        return 'Perfect! You\'re a star! 🎉';
      case 2:
        return 'Great work! So close! 😊';
      default:
        return 'You did it! Keep going! 👍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.successText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          StarRating(stars: stars),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Retry same letter
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.smartBlue,
                  side: const BorderSide(color: AppColors.smartBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Advance to next letter — this is the ONLY way to go next
              ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Next Letter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successButton,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  FAILURE OVERLAY
//  KEY FIX: This only shows when the child actively draws
//  off-path (wrong ratio too high). NOT when they lift finger.
// ═══════════════════════════════════════════════════════════
class FailureOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final double coverageRatio;

  const FailureOverlay({
    super.key,
    required this.onRetry,
    required this.coverageRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.12),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sentiment_dissatisfied_rounded,
            size: 48,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 10),
          const Text(
            'Oops! You went off the path!',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.errorText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Try to follow the dotted blue guide.\nThe red marks show where you went wrong.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          // Show how much they covered before failing
          Row(
            children: [
              Text(
                'Covered:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: coverageRatio,
                    minHeight: 10,
                    backgroundColor: AppColors.black.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      coverageRatio > 0.5
                          ? AppColors.smartOrange
                          : AppColors.smartRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(coverageRatio * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PAUSED HINT BANNER
//  NEW! Shown when child lifts finger mid-trace.
//  Tells them they can continue drawing — no pressure.
// ═══════════════════════════════════════════════════════════
class PausedHintBanner extends StatelessWidget {
  final double coverageRatio;
  const PausedHintBanner({super.key, required this.coverageRatio});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.smartBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.smartBlue.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.touch_app_rounded,
            color: AppColors.smartBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Keep going! ${(coverageRatio * 100).toInt()}% done — need 82%',
            style: const TextStyle(
              color: AppColors.smartBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  PROGRESS BAR
// ═══════════════════════════════════════════════════════════
class TracingProgressBar extends StatelessWidget {
  final double progress;
  const TracingProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    Color barColor;
    if (progress < 0.5) {
      barColor = AppColors.smartBlue;
    } else if (progress < 0.82) {
      barColor = AppColors.smartBlue;
    } else {
      barColor = AppColors.smartGreen;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.black.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 11,
            backgroundColor: AppColors.black.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Lift your finger and continue — it\'s okay!',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ANIMATED HAND GUIDE
//  Moves along the given path to show the child where to trace.
// ═══════════════════════════════════════════════════════════
class AnimatedHand extends StatefulWidget {
  final List<Offset> points;
  final bool isVisible;

  const AnimatedHand({
    super.key,
    required this.points,
    required this.isVisible,
  });

  @override
  State<AnimatedHand> createState() => _AnimatedHandState();
}

class _AnimatedHandState extends State<AnimatedHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _anim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isVisible && widget.points.isNotEmpty) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedHand oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && widget.points.isNotEmpty) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible || widget.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final index = (_anim.value * (widget.points.length - 1)).round();
        final pos = widget.points[index];

        return Positioned(
          left: pos.dx - 10,
          top: pos.dy - 10,
          child: Transform.rotate(
            angle: -0.2, // Slight tilt
            child: const Text('👆', style: TextStyle(fontSize: 50)),
          ),
        );
      },
    );
  }
}
