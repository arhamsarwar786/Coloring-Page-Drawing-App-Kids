import 'package:flutter/material.dart';

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

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
    );
  }
}
