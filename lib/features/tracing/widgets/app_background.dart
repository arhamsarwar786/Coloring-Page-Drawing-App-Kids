import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.appBar});
  final Widget child;
  // ignore: strict_top_level_inference, prefer_typing_uninitialized_variables
  final appBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     AppColors.backgroundTop,
          //     AppColors.backgroundMiddle,
          //     AppColors.backgroundBottom,
          //   ],
          // ),
          color: Color(0xfffdfbfc),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
