import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/components/glass_panel.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loader.dart';
import '../../levels/model/level_model.dart';
import '../viewmodel/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading && viewModel.content == null) {
                return const Loader();
              }
              if (viewModel.errorMessage != null &&
                  viewModel.content == null) {
                return _HomeError(
                  message: viewModel.errorMessage!,
                  onRetry: viewModel.load,
                );
              }
              final content = viewModel.content;
              if (content == null) return const SizedBox.shrink();

              return RefreshIndicator(
                onRefresh: viewModel.load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    _HeaderPanel(
                      title: content.appTitle,
                      subtitle: content.headline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StatsStrip(
                      completedLevels: viewModel.completedLevelsCount,
                      totalLevels: viewModel.totalLevelsCount,
                      coins: viewModel.earnedCoins,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (viewModel.dailyLevel != null) ...<Widget>[
                      SectionHeader(
                        title: AppStrings.dailyTitle,
                        subtitle: content.dailyGoalText,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FeaturePanel(
                        title: viewModel.dailyLevel!.title,
                        subtitle: viewModel.dailyLevel!.subtitle,
                        icon: Icons.wb_sunny_rounded,
                        accent: viewModel.dailyLevel!.accentColor,
                        buttonLabel: AppStrings.openLevel,
                        onPressed: () => _openLevel(
                            context, viewModel, viewModel.dailyLevel!),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    if (viewModel.continueLevel != null) ...<Widget>[
                      const SectionHeader(
                        title: AppStrings.continueTitle,
                        subtitle: AppStrings.continueSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _FeaturePanel(
                        title: viewModel.continueLevel!.title,
                        subtitle: viewModel.continueLevel!.subtitle,
                        icon: Icons.play_circle_fill_rounded,
                        accent: viewModel.continueLevel!.accentColor,
                        buttonLabel: viewModel.continueLevel!.isCompleted
                            ? AppStrings.replayLevel
                            : AppStrings.openLevel,
                        onPressed: () => _openLevel(
                            context, viewModel, viewModel.continueLevel!),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    const SectionHeader(
                      title: AppStrings.categoriesTitle,
                      subtitle: AppStrings.categoriesSubtitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: viewModel.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: AppSpacing.sm),
                            child: ChoiceChip(
                              label: Text(category.title),
                              selected: viewModel.selectedCategory?.id ==
                                  category.id,
                              onSelected: (_) =>
                                  viewModel.selectCategory(category.id),
                              selectedColor:
                                  category.accentColor.withOpacity(0.25),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(
                      title: AppStrings.levelsTitle,
                      subtitle: viewModel.selectedCategory?.subtitle ??
                          content.headline,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          viewModel.levelsForSelectedCategory.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.md,
                        crossAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.76,
                      ),
                      itemBuilder: (context, index) {
                        final level =
                            viewModel.levelsForSelectedCategory[index];
                        final isLocked = viewModel.isLevelLocked(level);
                        return _LevelCard(
                          level: level,
                          isLocked: isLocked,
                          onTap: () =>
                              _openLevel(context, viewModel, level),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openLevel(
    BuildContext context,
    HomeViewModel viewModel,
    LevelModel level,
  ) async {
    final isReady = await viewModel.prepareLevel(level.id);
    if (!context.mounted) return;

    if (!isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(AppStrings.lockedLevelMessage)),
      );
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.drawing,
      arguments: DrawingRouteArgs(levelId: level.id),
    );

    if (!context.mounted) return;
    await context.read<HomeViewModel>().load();
  }
}

class _HeaderPanel extends StatelessWidget {
  const _HeaderPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.ink,
            AppColors.ink.withOpacity(0.82),
            AppColors.rose.withOpacity(0.72),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              AppStrings.homeTitle,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title,
              style:
                  textTheme.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle,
              style: textTheme.bodyLarge
                  ?.copyWith(color: Colors.white.withOpacity(0.88))),
        ],
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.completedLevels,
    required this.totalLevels,
    required this.coins,
  });

  final int completedLevels;
  final int totalLevels;
  final int coins;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _StatCard(
            label: AppStrings.progressLabel,
            value: '$completedLevels/$totalLevels',
            icon: Icons.auto_graph_rounded,
            color: AppColors.sky,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            label: AppStrings.coinsLabel,
            value: '$coins',
            icon: Icons.toll_rounded,
            color: AppColors.coral,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.ink),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(value,
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePanel extends StatelessWidget {
  const _FeaturePanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: accent.withOpacity(0.16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                CustomButton(
                  label: buttonLabel,
                  onPressed: onPressed,
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError(
      {required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.cloud_off_rounded, size: 54),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            CustomButton(label: AppStrings.retry, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.isLocked,
    required this.onTap,
  });

  final LevelModel level;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      level.accentColor.withOpacity(0.9),
                      level.accentColor.withOpacity(0.45),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    isLocked
                        ? Icons.lock_rounded
                        : level.isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.brush_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(level.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: AppSpacing.xs),
              Text(level.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: <Widget>[
                  Icon(Icons.workspace_premium_rounded,
                      size: 18, color: level.accentColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${level.stars}'),
                  const Spacer(),
                  Icon(Icons.toll_rounded,
                      size: 18, color: level.accentColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text('${level.rewardCoins}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
