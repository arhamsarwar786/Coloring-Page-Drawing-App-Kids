import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../settings/viewmodel/settings_viewmodel.dart';
import '../../sound/services/sound_service.dart';
import '../viewmodel/splash_viewmodel.dart';
import '_animated_loading_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startFlow();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startFlow() async {
    final soundService = context.read<SoundService>();
    // 🎵 Start background music loop immediately!
    soundService.startBackgroundMusic();

    final settingsViewModel = context.read<SettingsViewModel>();
    await settingsViewModel.ensureLoaded();
    
    if (!mounted) return;

    await Future<void>.delayed(
        const Duration(seconds: 3)); // ⏳ Stay on splash for 3 sec

    if (!mounted) return;

    await context.read<SplashViewModel>().start(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/splashs.png',
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 68,
            child: _SplashLoadingAnimation(animation: _animationController),
          ),
        ],
      ),
    );
  }
}

class _SplashLoadingAnimation extends StatelessWidget {
  const _SplashLoadingAnimation({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final progress = animation.value;
                  final barWidth = constraints.maxWidth;
                  final currentWidth = barWidth * progress;

                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.centerLeft,
                    children: <Widget>[
                      // Track background
                      Container(
                        height: 14,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Progress Fill
                      Container(
                        height: 14,
                        width: currentWidth,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFDFFF00), // Parrot
                              Color(0xFF90EE90), // Light Green
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDFFF00).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      // Moving Marker on top
                      Positioned(
                        left: currentWidth - 32,
                        top: -42,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Image.asset(
                            'assets/images/markerp.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.brush_rounded,
                                    color: Colors.white, size: 34),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            const AnimatedLoadingText(),
          ],
        );
      },
    );
  }
}
