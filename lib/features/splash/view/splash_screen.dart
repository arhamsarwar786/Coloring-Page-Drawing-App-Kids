import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
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
    final settingsViewModel = context.read<SettingsViewModel>();
    await settingsViewModel.ensureLoaded();

    if (!mounted) return;

    final soundService = context.read<SoundService>();
    await soundService.startBackgroundMusic();

    await Future<void>.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    await context.read<SplashViewModel>().start(context);
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
        backgroundColor: const Color(0xFF0D1B6E), // deep navy matching logo outline
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Background artwork
            Image.asset(
              'assets/images/splash.png',
              fit: BoxFit.cover,
              color: const Color(0xFF0D1B6E).withValues(alpha: 0.18),
              colorBlendMode: BlendMode.srcOver,
            ),
            // Dark gradient overlay so logo & bar are legible
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0xCC0D1B6E),
                  ],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // Logo centred in the upper area
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 200,
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.7, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.elasticOut,
                  builder: (context, scale, _) => Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            // Loading bar at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 68,
              child: _SplashLoadingAnimation(animation: _animationController),
            ),
          ],
        ),
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
                      Container(
                        height: 14,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Container(
                        height: 14,
                        width: currentWidth,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[
                              AppColors.yellow,  // logo "Play" yellow
                              AppColors.pink,    // logo "Kids" pink
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.yellow.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
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
                                const Icon(
                              Icons.brush_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
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
