import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/components/glass_panel.dart';
import '../../../shared/widgets/loader.dart';
import '../viewmodel/level_viewmodel.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Consumer<LevelViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) return const Loader();
              return Padding(
                padding: const EdgeInsets.all(20),
                child: GlassPanel(
                  child: ListView.separated(
                    itemCount: viewModel.levels.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final level = viewModel.levels[index];
                      return ListTile(
                        title: Text(level.title),
                        subtitle: Text(level.subtitle),
                        trailing: Text(level.difficulty),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}