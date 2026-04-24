import 'package:asmr_coloring_app/app/config/app_config.dart';
import 'package:asmr_coloring_app/app/routes/app_routes.dart';
import 'package:asmr_coloring_app/app/theme/app_theme.dart';
import 'package:asmr_coloring_app/core/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AsmrDrawingApp extends StatelessWidget {
  const AsmrDrawingApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// EDGE TO EDGE SYSTEM UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

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
