import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../model/planner_progress_model.dart';
import '../viewmodel/planner_reward_viewmodel.dart';

enum PlannerDialogMode {
  /// First time introducing the parent planner reward.
  intro,

  /// Progress not yet unlocked — show progress bar.
  locked,

  /// Just unlocked — celebrate + download.
  unlocked,

  /// Already unlocked — download anytime.
  download,
}

/// Parent-facing planner reward dialog with progress and PDF downloads.
class PlannerFeatureDialog extends StatelessWidget {
  const PlannerFeatureDialog({
    super.key,
    required this.mode,
  });

  final PlannerDialogMode mode;

  static Future<void> show(
    BuildContext context, {
    required PlannerDialogMode mode,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => PlannerFeatureDialog(mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlannerRewardViewModel>(
      builder: (context, planner, _) {
        final unlocked = planner.isUnlocked;
        final effectiveMode = unlocked &&
                (mode == PlannerDialogMode.locked ||
                    mode == PlannerDialogMode.intro)
            ? PlannerDialogMode.download
            : mode;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.shell,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(mode: effectiveMode, onClose: () {
                      _onDismiss(context, planner, effectiveMode);
                    }),
                    const SizedBox(height: 12),
                    _NeedBanner(mode: effectiveMode),
                    const SizedBox(height: 14),
                    if (!unlocked) ...[
                      _ProgressSection(planner: planner),
                      const SizedBox(height: 14),
                    ] else ...[
                      _UnlockedBadge(
                        celebrate: effectiveMode == PlannerDialogMode.unlocked,
                      ),
                      const SizedBox(height: 14),
                      _DownloadSection(planner: planner),
                    ],
                    const SizedBox(height: 8),
                    _WhatsInside(),
                    const SizedBox(height: 16),
                    _PrimaryAction(
                      mode: effectiveMode,
                      unlocked: unlocked,
                      onPressed: () {
                        if (unlocked) {
                          Navigator.of(context).pop();
                        } else {
                          _onDismiss(context, planner, effectiveMode);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDismiss(
    BuildContext context,
    PlannerRewardViewModel planner,
    PlannerDialogMode effectiveMode,
  ) async {
    if (effectiveMode == PlannerDialogMode.intro) {
      await planner.markIntroSeen();
    }
    if (effectiveMode == PlannerDialogMode.unlocked) {
      await planner.markUnlockCelebrationSeen();
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.mode, required this.onClose});

  final PlannerDialogMode mode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isNew = mode == PlannerDialogMode.intro;
    final title = switch (mode) {
      PlannerDialogMode.intro => 'New for Parents',
      PlannerDialogMode.locked => 'Kids Planner Reward',
      PlannerDialogMode.unlocked => 'Planner Unlocked!',
      PlannerDialogMode.download => 'Download Planner',
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.yellow, AppColors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNew)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW FEATURE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'PlayCraft Kids Hyperlinked Planner',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.warmGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close_rounded, color: AppColors.warmGrey),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _NeedBanner extends StatelessWidget {
  const _NeedBanner({required this.mode});

  final PlannerDialogMode mode;

  @override
  Widget build(BuildContext context) {
    final text = switch (mode) {
      PlannerDialogMode.intro || PlannerDialogMode.locked =>
        'Every child needs a calm daily plan — morning routines, after-school focus, bedtime wind-down, and fun coloring quests. This 36-page planner helps parents build healthy habits while kids keep creating.',
      PlannerDialogMode.unlocked =>
        'Amazing! Your child earned the full PlayCraft Kids Planner. Print it, save it, and use it every day — it\'s a must-have for happy, focused kids.',
      PlannerDialogMode.download =>
        'Download anytime in A4 or US Letter. Share to Files, Drive, email, or print at home. Perfect for parents who want structure without screens.',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blue.withValues(alpha: 0.08),
            AppColors.pink.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.pink, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.planner});

  final PlannerRewardViewModel planner;

  @override
  Widget build(BuildContext context) {
    final done = planner.completedLevels.clamp(0, planner.unlockThreshold);
    final total = planner.unlockThreshold;
    final remaining = planner.remainingLevels;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E4F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Unlock progress',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '$done / $total levels',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: planner.progressFraction),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 14,
                  backgroundColor: const Color(0xFFEDEAF5),
                  valueColor: const AlwaysStoppedAnimation(AppColors.green),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            remaining == 0
                ? 'Ready to download!'
                : remaining == 1
                    ? 'Just 1 more coloring level to unlock the planner!'
                    : 'Complete $remaining more levels to unlock this parent gift.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.warmGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedBadge extends StatelessWidget {
  const _UnlockedBadge({required this.celebrate});

  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            celebrate ? Icons.celebration_rounded : Icons.lock_open_rounded,
            color: AppColors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              celebrate
                  ? '5 levels complete — the planner is yours forever!'
                  : 'Unlocked — download A4 or US Letter anytime.',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadSection extends StatelessWidget {
  const _DownloadSection({required this.planner});

  final PlannerRewardViewModel planner;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Choose format',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        _FormatCard(
          format: PlannerPdfFormat.a4,
          planner: planner,
          accent: AppColors.blue,
        ),
        const SizedBox(height: 8),
        _FormatCard(
          format: PlannerPdfFormat.usLetter,
          planner: planner,
          accent: AppColors.purple,
        ),
        if (planner.downloadError != null) ...[
          const SizedBox(height: 8),
          Text(
            planner.downloadError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.format,
    required this.planner,
    required this.accent,
  });

  final PlannerPdfFormat format;
  final PlannerRewardViewModel planner;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final busy = planner.isDownloading && planner.downloadingFormat == format;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.ink,
                  ),
                ),
                const Text(
                  'PDF · 36 hyperlinked pages',
                  style: TextStyle(fontSize: 11, color: AppColors.warmGrey),
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          else ...[
            IconButton(
              tooltip: 'Print / Preview',
              onPressed: planner.isDownloading
                  ? null
                  : () => planner.printFormat(format),
              icon: Icon(Icons.print_rounded, color: accent),
            ),
            FilledButton(
              onPressed: planner.isDownloading
                  ? null
                  : () async {
                      final ok = await planner.shareFormat(format);
                      if (!context.mounted || !ok) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${format.shortLabel} planner ready — save or share it!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Save'),
            ),
          ],
        ],
      ),
    );
  }
}

class _WhatsInside extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      'Daily & morning routines',
      'Coloring quests',
      'Mood & gratitude pages',
      'Tap-to-navigate PDF',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.mode,
    required this.unlocked,
    required this.onPressed,
  });

  final PlannerDialogMode mode;
  final bool unlocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = unlocked
        ? 'Done'
        : mode == PlannerDialogMode.intro
            ? 'Got it — let\'s color!'
            : 'Keep coloring';

    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: unlocked ? AppColors.blue : AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
