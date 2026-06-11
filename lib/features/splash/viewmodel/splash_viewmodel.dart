import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/auth/view/sign_up_screen.dart';
import 'package:play_craft_kids/features/home/view/main_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/config/app_config.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_viewmodel.dart';
import '../../home/repository/home_repository.dart';

class SplashViewModel extends BaseViewModel {
  SplashViewModel({
    required HomeRepository repository,
  }) : _repository = repository;

  final HomeRepository _repository;
  bool _started = false;

  Future<void> start(BuildContext context) async {
    if (_started) return;
    _started = true;
    await Future<void>.delayed(
        const Duration(milliseconds: AppConfig.splashDelayMs));
    await _repository.loadHomeContent();
    if (!context.mounted) return;
    final session = Supabase.instance.client.auth.currentSession;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              // session != null ?
              MainHomeScreen()
          // : const LoginScreen(),
          ),
    );

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const SignupScreen(),
    //   ),
    // );
    // ReplacementNamed(
    // //   context,

    // //   // AppRoutes.mainHome,
    // );
  }
}
