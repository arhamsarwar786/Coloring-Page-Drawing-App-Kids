import 'dart:math';
import 'dart:ui' as ui;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/features/coloring/view/coloring_screen.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/drawing/repository/drawing_repository.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/levels/model/level_model.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/activity_item.dart';
import 'package:provider/provider.dart';

class ColoringCompletionScreen extends StatefulWidget {
  /// The exact pixel image the child painted — pass from PixelColoringCanvas.
  final ui.Image? coloredImage;
  const ColoringCompletionScreen({super.key, this.coloredImage});

  @override
  State<ColoringCompletionScreen> createState() =>
      _ColoringCompletionScreenState();
}

class _ColoringCompletionScreenState extends State<ColoringCompletionScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _cardController;
  late AnimationController _starsController;
  late AnimationController _coinsController;
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<double> _coinsSlide;

  // Stars that are lit up one by one
  int _visibleStars = 0;
  int _earnedCoins = 0;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );

    // Card pop-in animation
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardScale = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );
    _cardOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );

    // Stars animation
    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Coins slide-in
    _coinsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _coinsSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _coinsController, curve: Curves.easeOutBack),
    );

    // Kick off the sequence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startSequence();
    });
  }

  void _startSequence() async {
    final provider = context.read<ColoringProvider>();
    _earnedCoins = provider.currentLevel?.rewardCoins ?? 20;

    // Instantly mark the level as completed if they passed (so backing out still saves progress)
    final passed = provider.overallCoveragePercent >= 70;
    if (passed) {
      final currentLevel = provider.currentLevel;
      if (currentLevel != null) {
        final drawingRepo = context.read<DrawingRepository>();
        await drawingRepo.markLevelCompleted(
          levelId: currentLevel.id,
          stars: 3,
          rewardCoins: currentLevel.rewardCoins,
        );
        // Refresh home viewmodel so it's unlocked when returning
        if (mounted) {
          final homeVM = context.read<HomeViewModel>();
          homeVM.refreshProgress();
          homeVM.load();
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    if (passed) {
      _confettiController.play();
    }
    _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (passed) {
      // Light up stars one by one
      for (int i = 1; i <= 3; i++) {
        await Future.delayed(const Duration(milliseconds: 280));
        if (!mounted) return;
        setState(() => _visibleStars = i);
      }

      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      _coinsController.forward();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardController.dispose();
    _starsController.dispose();
    _coinsController.dispose();
    super.dispose();
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ColoringProvider>(
        builder: (context, provider, _) {
          final item = provider.currentItem;
          final word = item?.label ?? 'Picture';
          final coins = provider.currentLevel?.rewardCoins ?? _earnedCoins;
          
          final coverage = provider.overallCoveragePercent;
          final passed = coverage >= 70;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ui.Color.fromARGB(255, 196, 189, 236),
                  ui.Color.fromARGB(255, 54, 164, 207),
                  ui.Color.fromARGB(255, 203, 189, 228)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // ── Glowing background bubbles ─────────────────────────────
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -80,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withValues(alpha: 0.06),
                    ),
                  ),
                ),

                // ── Confetti ────────────────────────────────────────────────
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      emissionFrequency: 0.06,
                      numberOfParticles: 60,
                      maxBlastForce: 120,
                      minBlastForce: 60,
                      colors: const [
                        Color(0xFFFFD700),
                        Color(0xFFFF6B9D),
                        Color(0xFF00E5FF),
                        Color(0xFF69F0AE),
                        Color(0xFFFFAB40),
                        Color(0xFFEA80FC),
                      ],
                      createParticlePath: _drawStar,
                    ),
                  ),
                ),

                // ── Main content ────────────────────────────────────────────
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // ── "Woohoo!" header ───────────────────────────────────
                      Text(
                        passed ? '🎉 WooHoo! 🎉' : 'Keep Trying!',
                        style: GoogleFonts.fredoka(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: passed ? const Color(0xFFFFD700) : const Color(0xFFFF5722),
                          shadows: [
                            const Shadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        passed ? 'Beautiful $word!' : 'You can do better!',
                        style: GoogleFonts.fredoka(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Artwork card ─────────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ScaleTransition(
                            scale: _cardScale,
                            child: FadeTransition(
                              opacity: _cardOpacity,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6B35CF)
                                          .withValues(alpha: 0.5),
                                      blurRadius: 40,
                                      spreadRadius: 4,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Stack(
                                    children: [
                                      // Artwork
                                      Positioned.fill(
                                        child: widget.coloredImage != null
                                            ? RawImage(
                                                image: widget.coloredImage,
                                                fit: BoxFit.contain,
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.palette_rounded,
                                                  size: 80,
                                                  color: Color(0xFF6B35CF),
                                                ),
                                              ),
                                      ),
                                      // Top ribbon
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFFD700),
                                                Color(0xFFFF9100),
                                              ],
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
                      ),

                      const SizedBox(height: 20),

                      // ── Stars row ─────────────────────────────────────────
                      if (passed)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final lit = i < _visibleStars;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.elasticOut,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedScale(
                                scale: lit ? 1.0 : 0.6,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.elasticOut,
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 52,
                                  color: lit
                                      ? const Color(0xFFFFD700)
                                      : Colors.white.withValues(alpha: 0.2),
                                  shadows: lit
                                      ? [
                                          const Shadow(
                                            color: Color(0xFFFFD700),
                                            blurRadius: 16,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),

                      if (passed) const SizedBox(height: 16),

                      // ── Coins banner ──────────────────────────────────────
                      if (passed)
                        AnimatedBuilder(
                          animation: _coinsController,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, _coinsSlide.value),
                            child: Opacity(
                              opacity: _coinsController.value,
                              child: child,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🪙', style: TextStyle(fontSize: 26)),
                                const SizedBox(width: 8),
                                Text(
                                  '+$coins Coins Earned!',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ── Action buttons ────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            // Home button
                            _ActionButton(
                              icon: Icons.home_rounded,
                              label: 'Home',
                              color: Colors.white.withValues(alpha: 0.18),
                              textColor: Colors.white,
                              onTap: () async {
                                if (mounted) {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                }
                              },
                            ),
                            const SizedBox(width: 12),
                            // Next level or Restart button
                            Expanded(
                              child: passed
                                  ? _ActionButton(
                                      icon: Icons.arrow_forward_rounded,
                                      label: 'Next Level',
                                      color: const Color(0xFF00E676),
                                      textColor: Colors.white,
                                      onTap: () async {
                                        final currentLevel = provider.currentLevel;
                                        if (currentLevel != null) {
                                          final drawingRepo =
                                              context.read<DrawingRepository>();

                                          // 3. Find next level
                                          final nextLevelId = await drawingRepo
                                              .getNextLevelId(currentLevel.id);
                                          LevelModel? nextLevel;
                                          if (nextLevelId != null) {
                                            nextLevel = await drawingRepo
                                                .getLevelById(nextLevelId);
                                          }

                                          if (nextLevel != null && mounted) {
                                            // 4. Setup provider for next level
                                            final coloringProvider =
                                                context.read<ColoringProvider>();
                                            final activity = ActivityItem(
                                              id: nextLevel.id,
                                              label: nextLevel.title,
                                              display: nextLevel.title,
                                              color: Colors.red,
                                              imagePath: nextLevel
                                                      .activityItem?.imagePath ??
                                                  nextLevel.imagePath ??
                                                  'assets/images/un_border_apple.webp',
                                            );
                                            coloringProvider.setItem(
                                                activity, provider.currentCategoryId,
                                                level: nextLevel);

                                            // 5. Navigate — keep Home as root
                                            Navigator.of(context).pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (_) => ColoringScreen(
                                                    imagePath: activity.imagePath),
                                              ),
                                              (route) => route.isFirst,
                                            );
                                          } else if (mounted) {
                                            Navigator.of(context)
                                                .popUntil((route) => route.isFirst);
                                          }
                                        } else {
                                          Navigator.of(context)
                                              .popUntil((route) => route.isFirst);
                                        }
                                      },
                                    )
                                  : _ActionButton(
                                      icon: Icons.replay_rounded,
                                      label: 'Try Again!',
                                      color: const Color(0xFFFF5722),
                                      textColor: Colors.white,
                                      onTap: () {
                                        provider.retry();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),

                // ── Back button ─────────────────────────────────────────────
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: SidebarIcon(
                      icon: Icons.arrow_back_rounded,
                      assetName: 'assets/images/pop-button.png',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Reusable action button ─────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.textColor, size: 26),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: widget.textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
