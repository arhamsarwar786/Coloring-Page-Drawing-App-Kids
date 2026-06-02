import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:play_craft_kids/features/tracing/constants/app_colors.dart';
import 'package:play_craft_kids/features/tracing/constants/app_sounds.dart';
import 'package:play_craft_kids/features/tracing/view/tracing_summary_screen.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/tracing_viewmodel.dart';
import 'package:play_craft_kids/features/tracing/widgets/app_background.dart';
import 'package:play_craft_kids/features/tracing/widgets/color_info.dart';
import 'package:play_craft_kids/features/tracing/widgets/letter_info.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_painter.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_widgets.dart';
import 'package:provider/provider.dart';

class TracingCompletionScreen extends StatefulWidget {
  const TracingCompletionScreen({super.key});

  @override
  State<TracingCompletionScreen> createState() =>
      _TracingCompletionScreenState();
}

class _TracingCompletionScreenState extends State<TracingCompletionScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _confettiController.play();

    // Play completed letter sound voiceover and record progress (for all categories/modules)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<TracingProvider>(context, listen: false);
      final soundPath = _getSoundForActivityItem(provider);
      if (soundPath != null) {
        // MusicService.instance.stopLetterSound();
        // MusicService.instance.playLetterSound(soundPath);
      }

      // final progressProvider =
      // Provider.of<ProgressViewModel>(context, listen: false);
      // progressProvider.addEvent(provider.categoryId, 'tracing', provider.stars);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    // MusicService.instance.stopLetterSound();
    super.dispose();
  }

  String? _getSoundForActivityItem(TracingProvider provider) {
    final item = provider.currentItem;
    if (item != null) {
      final labelLower = item.label.toLowerCase();
      switch (labelLower) {
        // --- Category 1: Animals ---
        case 'alligator':
          return AppSounds.aisAlligator;
        case 'bear':
          return AppSounds.bisBear;
        case 'cat':
          return AppSounds.cisCat;
        case 'dog':
          return AppSounds.disDog;
        case 'elephant':
          return AppSounds.eisElephant;
        case 'lion':
          return AppSounds.lisLion;

        // --- Category 2: Colors ---
        case 'red':
          return AppSounds.risRed;
        case 'blue':
          return AppSounds.bisBlue;
        case 'green':
          return AppSounds.gisGreen;
        case 'yellow':
          return AppSounds.yisYellow;
        case 'purple':
          return AppSounds.pisPurple;
        case 'orange':
          return AppSounds.oisOrange;

        // --- Category 3: Fruits ---
        case 'apple':
          return AppSounds.aisApple;
        case 'banana':
          return AppSounds.bisBanana;
        case 'grapes':
          return AppSounds.gisGrapes;
        case 'strawberry':
          return AppSounds.sisStrawberry;
        case 'cherry':
          return AppSounds.cisCherry;
        case 'watermelon':
          return AppSounds.wisWatermelon;

        // --- Category 4: Vegetables ---
        case 'carrot':
          return AppSounds.cisCarrot;
        case 'broccoli':
          return AppSounds.bisBroccoli;
        case 'tomato':
          return AppSounds.tisTomato;
        case 'potato':
          return AppSounds.pisPotato;
        case 'corn':
          return AppSounds.cisCorn;
        case 'eggplant':
          return AppSounds.eisEggplant;

        // --- Category 5: Numbers ---
        case 'one':
          return AppSounds.oisOne;
        case 'two':
          return AppSounds.tisTwo;
        case 'three':
          return AppSounds.tisThree;
        case 'four':
          return AppSounds.fisFour;
        case 'five':
          return AppSounds.fisFive;
        case 'six':
          return AppSounds.sisSix;

        // --- Category 6: Alphabets ---
        case 'a':
          return AppSounds.aisApple;
        case 'b':
          return AppSounds.bisBanana;
        case 'c':
          return AppSounds.cisCat;
        case 'd':
          return AppSounds.disDog;
        case 'e':
          return AppSounds.eisElephant;
        case 'f':
          return AppSounds.fisFish;

        // --- Category 7: Shapes ---
        case 'circle':
          return AppSounds.cisCircle;
        case 'square':
          return AppSounds.sisSquare;
        case 'triangle':
          return AppSounds.tisTriangle;
        case 'star':
          return AppSounds.sisStar;
        case 'heart':
          return AppSounds.hisHeart;
        case 'diamond':
          return AppSounds.disDiamond;

        // --- Category 8: Vehicles ---
        case 'car':
          return AppSounds.cisCar;
        case 'bus':
          return AppSounds.bisBus;
        case 'train':
          return AppSounds.tisTrain;
        case 'plane':
          return AppSounds.pisPlane;
        case 'bicycle':
          return AppSounds.bisBicycle;
        case 'truck':
          return AppSounds.tisTruck;

        // --- Category 9: Birds ---
        case 'owl':
          return AppSounds.oisOwl;
        case 'duck':
          return AppSounds.disDuck;
        case 'penguin':
          return AppSounds.pisPenguin;
        case 'eagle':
          return AppSounds.eisEagle;
        case 'parrot':
          return AppSounds.pisParrot;
        case 'peacock':
          return AppSounds.pisPeacock;

        // --- Category 10: Sea Animals ---
        case 'fish':
          return AppSounds.fisFish;
        case 'dolphin':
          return AppSounds.disDolphin;
        case 'octopus':
          return AppSounds.oisOctopus;
        case 'whale':
          return AppSounds.wisWhale;
        case 'shark':
          return AppSounds.sisShark;
        case 'crab':
          return AppSounds.cisCrab;
      }
    }

    // Fallback: use legacy switch on letter
    return _getSoundForLetter(provider.currentLetter);
  }

  String? _getSoundForLetter(String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return AppSounds.aisAlligator;
      case 'B':
        return AppSounds.bisBear;
      case 'C':
        return AppSounds.cisCat;
      case 'D':
        return AppSounds.disDog;
      case 'E':
        return AppSounds.eisElephant;
      case 'F':
        return AppSounds.fisFish;
      case 'G':
        return AppSounds.gisGiraffe;
      case 'H':
        return AppSounds.hisHat;
      case 'I':
        return AppSounds.iisIcecream;
      case 'J':
        return AppSounds.jisJellyfish;
      case 'K':
        return AppSounds.kisKangaroo;
      case 'L':
        return AppSounds.lisLion;
      case 'M':
        return AppSounds.misMonkey;
      case 'N':
        return AppSounds.nisNarwhal;
      case 'O':
        return AppSounds.oisOctopus;
      case 'P':
        return AppSounds.pisPenguin;
      case 'Q':
        return AppSounds.qisQuail;
      case 'R':
        return AppSounds.risRabbit;
      case 'S':
        return AppSounds.sisSnake;
      case 'T':
        return AppSounds.tisTiger;
      case 'U':
        return AppSounds.uisUmbrella;
      case 'V':
        return AppSounds.visViolin;
      case 'W':
        return AppSounds.wisWhale;
      case 'X':
        return AppSounds.xisXylophone;
      case 'Y':
        return AppSounds.yisYak;
      case 'Z':
        return AppSounds.zisZebra;
      default:
        return null;
    }
  }

  /// A custom Path to paint stars for the confetti!
  Path drawStar(Size size) {
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
      body: Consumer<TracingProvider>(
        builder: (context, provider, _) {
          final String currentLetter = provider.currentLetter;
          final soundPath = _getSoundForActivityItem(provider);

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
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: info.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: info.color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            );
          }

          return AppBackground(
            child: Stack(
              children: [
                // 1. Confetti Explosion
                Positioned.fill(
                  child: IgnorePointer(
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      emissionFrequency: 0.05,
                      numberOfParticles: 50,
                      maxBlastForce: 100,
                      minBlastForce: 60,
                      colors: const [
                        AppColors.smartBlue,
                        AppColors.smartGreen,
                        AppColors.smartOrange,
                        AppColors.butterflyPink,
                        AppColors.smartYellow,
                      ],
                      createParticlePath: drawStar,
                    ),
                  ),
                ),

                // 2. Main Content Column (perfectly separated, never overlapping)
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Stars Rating at the top
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 8),
                          child: StarRating(stars: provider.stars),
                        ),

                        // Center Celebration Card
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Container(
                                  width: provider.canvasSize.width + 20,
                                  height: provider.canvasSize.height + 220,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.softPurple.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 8,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 70,
                                            left: 10,
                                            right: 10,
                                            bottom:
                                                150, // Leave room for letter info
                                          ),
                                          child: CustomPaint(
                                            size: provider.canvasSize,
                                            painter: TracingPainter(
                                              letter: provider.currentLetter,
                                              completedStrokes:
                                                  provider.completedStrokes,
                                              currentStroke: const [], // no active stroke
                                              wrongPoints: const [],
                                              activeStrokeIndex: provider
                                                  .completedStrokes.length,
                                              strokeColor: AppColors
                                                  .deepPurple, // draw everything as completed
                                              padding:
                                                  24.0, // <-- Apply beautiful canvas frame padding
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 20,
                                        left: 20,
                                        right: 20,
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
                                                TextSpan(
                                                  text: '$currentLetter for ',
                                                ),
                                                TextSpan(
                                                  text: word,
                                                  style: const TextStyle(
                                                    color: AppColors
                                                        .butterflyPink, // Playful pink
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -10,
                                        left: -30,
                                        child: leadWidget,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Bottom Navigation Buttons
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Sound Button
                              if (soundPath != null) ...[
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.smartYellow,
                                          AppColors.smartOrange,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              AppColors.smartOrange.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                              ],
                              // Next Button
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const TracingSummaryScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 70,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.smartGreen,
                                        Color(0xFF34D399), // premium mint green
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(35),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.smartGreen.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ],
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

                // 3. Floating Back Button at the top-left corner
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        shadowColor: AppColors.black.withValues(alpha: 0.15),
                        elevation: 4,
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.deepPurple,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: () {
                        // Stop any active letter sound voiceover
                        // MusicService.instance.stopLetterSound();

                        // Navigate back to the respective selecting screen
                        if (provider.currentItem != null) {
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => ItemSelectingScreen(
                          //       categoryId: provider.categoryId,
                          //     ),
                          //   ),
                          //   (route) => route.isFirst,
                          // );
                        } else if (provider.activityType ==
                            ActivityType.animals) {
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const AnimalSelectingScreen(),
                          //   ),
                          //   (route) => route.isFirst,
                          // );
                        } else {
                          // Navigator.pushAndRemoveUntil(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => const ColorSelectingScreen(),
                          //   ),
                          //   (route) => route.isFirst,
                          // );
                        }
                      },
                      child: const Icon(Icons.arrow_back_rounded, size: 28),
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
