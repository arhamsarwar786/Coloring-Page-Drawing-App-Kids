import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/routes/app_routes.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key, required this.args});

  final RewardRouteArgs args;

  void _openReplay(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.drawing,
      arguments: DrawingRouteArgs(levelId: args.levelId),
    );
  }

  void _openNext(BuildContext context) {
    final nextLevelId = args.nextLevelId;
    if (nextLevelId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(levelId: nextLevelId),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stars = args.stars.clamp(0, 3).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 20.0 : 32.0;
            final titleSize = constraints.maxWidth < 420 ? 26.0 : 32.0;

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'LEVEL ${args.levelNumber} COMPLETE!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          args.levelTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          children: List<Widget>.generate(
                            stars,
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB300),
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECB3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '+${args.coins} coins',
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _RewardButton(
                                label: 'Replay',
                                // icon: Icons.refresh_rounded,
                                color: const Color(0xFF42A5F5),
                                onTap: () => _openReplay(context),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RewardButton(
                                label:
                                    args.nextLevelId != null ? 'Next Level' : 'Home',
                                // icon: Icons.arrow_forward_rounded,
                                color: const Color(0xFF31B24C),
                                onTap: () => _openNext(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RewardButton extends StatelessWidget {
  const _RewardButton({
    required this.label,
    // required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  // final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
