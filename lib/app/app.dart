import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:play_craft_kids/app/config/app_config.dart';
import 'package:play_craft_kids/app/routes/app_routes.dart';
import 'package:play_craft_kids/app/theme/app_theme.dart';
import 'package:play_craft_kids/core/di/providers.dart';
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
        // fontFamily: 'Poppins',
        debugShowCheckedModeBanner: false,
        title: AppConfig.appTitle,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
