import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/di/providers.dart';
import 'config/app_config.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class AsmrDrawingApp extends StatelessWidget {
  const AsmrDrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appTitle,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
