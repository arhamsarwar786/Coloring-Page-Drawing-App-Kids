import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../viewmodel/planner_reward_viewmodel.dart';
import 'planner_feature_dialog.dart';

/// Compact home card showing planner unlock progress / download CTA.
class PlannerProgressCard extends StatelessWidget {
  const PlannerProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerRewardViewModel>(
      builder: (context, planner, _) {
        if (!planner.isLoaded) return const SizedBox.shrink();

        final unlocked = planner.isUnlocked;
        final done =
            planner.completedLevels.clamp(0, planner.unlockThreshold);
        final total = planner.unlockThreshold;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                PlannerFeatureDialog.show(
                  context,
                  mode: unlocked
                      ? PlannerDialogMode.download
                      : PlannerDialogMode.locked,
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: unlocked
                        ? const [Color(0xFF2E7D32), Color(0xFF66BB6A)]
                        : const [Color(0xFF1565C0), Color(0xFF7B2FC9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: (unlocked ? AppColors.green : AppColors.blue)
                          .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              unlocked ? 'UNLOCKED' : 'FOR PARENTS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            unlocked
                                ? Icons.download_rounded
                                : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        unlocked
                            ? 'Kids Planner ready — tap to download'
                            : 'Earn the Kids Planner parents love',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unlocked
                            ? 'A4 & US Letter PDF · save anytime'
                            : 'Every child needs daily routines — unlock after $total levels',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!unlocked) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: planner.progressFraction,
                            minHeight: 10,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.yellow,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$done / $total levels complete',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
