import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/viewmodel/home_viewmodel.dart';
import '../viewmodel/planner_reward_viewmodel.dart';
import 'planner_feature_dialog.dart';

/// Keeps planner progress in sync with home completions and shows popups.
class PlannerHomeBootstrap extends StatefulWidget {
  const PlannerHomeBootstrap({super.key, required this.child});

  final Widget child;

  @override
  State<PlannerHomeBootstrap> createState() => _PlannerHomeBootstrapState();
}

class _PlannerHomeBootstrapState extends State<PlannerHomeBootstrap> {
  bool _popupQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAndMaybeShow());
  }

  Future<void> _syncAndMaybeShow() async {
    if (!mounted) return;
    final home = context.read<HomeViewModel>();
    final planner = context.read<PlannerRewardViewModel>();

    await planner.ensureLoaded();
    await planner.syncCompletedLevels(home.completedLevelsCount);
    if (!mounted || _popupQueued) return;

    if (planner.shouldShowUnlockCelebration) {
      _popupQueued = true;
      await PlannerFeatureDialog.show(
        context,
        mode: PlannerDialogMode.unlocked,
      );
      await planner.markIntroSeen();
      await planner.markUnlockCelebrationSeen();
      return;
    }

    if (planner.shouldShowIntroPopup) {
      _popupQueued = true;
      await PlannerFeatureDialog.show(
        context,
        mode: PlannerDialogMode.intro,
      );
      await planner.markIntroSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Call after a level is marked complete (e.g. from completion screen).
Future<void> syncPlannerAfterLevelComplete(BuildContext context) async {
  final home = context.read<HomeViewModel>();
  final planner = context.read<PlannerRewardViewModel>();
  await home.refreshProgress();
  await planner.syncCompletedLevels(home.completedLevelsCount);

  if (!context.mounted) return;

  if (planner.shouldShowUnlockCelebration) {
    await PlannerFeatureDialog.show(
      context,
      mode: PlannerDialogMode.unlocked,
    );
    await planner.markIntroSeen();
    await planner.markUnlockCelebrationSeen();
  }
}
