import 'package:flutter/material.dart';

import '../../features/drawing/view/drawing_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/levels/view/level_screen.dart';
import '../../features/privacy/view/privacy_screen.dart';
import '../../features/rewards/view/reward_screen.dart';
import '../../features/skins/view/skins_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../../features/splash/view/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String drawing = '/drawing';
  static const String levels = '/levels';
  static const String skins = '/skins';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String reward = '/reward';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
        );
      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        );
      case drawing:
        final args = settings.arguments;
        if (args is DrawingRouteArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => DrawingScreen(levelId: args.levelId),
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        );
      case levels:
        return MaterialPageRoute<void>(
          builder: (_) => const LevelScreen(),
        );
      case AppRoutes.skins:
        return MaterialPageRoute<void>(
          builder: (_) => const SkinsScreen(),
        );
      case AppRoutes.settings:
        return MaterialPageRoute<void>(
          builder: (_) => const SettingsDialog(),
        );
      case AppRoutes.privacy:
        return MaterialPageRoute<void>(
          builder: (_) => const PrivacyScreen(),
        );
      case AppRoutes.reward:
        final args = settings.arguments;
        if (args is RewardRouteArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => RewardScreen(args: args),
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}

class DrawingRouteArgs {
  const DrawingRouteArgs({
    required this.levelId,
  });

  final String levelId;
}

class RewardRouteArgs {
  const RewardRouteArgs({
    required this.levelId,
    required this.levelTitle,
    required this.levelNumber,
    required this.coins,
    required this.stars,
    required this.nextLevelId,
  });

  final String levelId;
  final String levelTitle;
  final int levelNumber;
  final int coins;
  final int stars;
  final String? nextLevelId;
}
