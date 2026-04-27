import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/components/level_preview.dart';
import '../../../shared/utils/interaction_feedback.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loader.dart';
import '../../levels/model/level_model.dart';
import '../viewmodel/home_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOpeningLevel = false;

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
              if (viewModel.errorMessage != null && viewModel.content == null) {
                return _HomeError(
                  message: viewModel.errorMessage!,
                  onRetry: viewModel.load,
                );
              }

              final allLevels = viewModel.categories
                  .expand((category) => category.levels)
                  .toList(growable: false);
              if (allLevels.isEmpty) {
                return const SizedBox.shrink();
              }

              return RefreshIndicator(
                onRefresh: _isOpeningLevel ? () async {} : viewModel.load,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          14,
                          AppSpacing.lg,
                          10,
                        ),
                        child: Text(
                          viewModel.content?.appTitle ?? AppStrings.appTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final columns =
                              _columnCountForWidth(constraints.crossAxisExtent);
                          return SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final level = allLevels[index];
                                final levelNumber =
                                    viewModel.levelNumberFor(level.id) ??
                                        index + 1;
                                return _ReferenceLevelCard(
                                  level: level,
                                  levelNumber: levelNumber,
                                  palette: _paletteFor(index),
                                  isBusy: _isOpeningLevel,
                                  onTap: () =>
                                      _openLevel(context, viewModel, level),
                                );
                              },
                              childCount: allLevels.length,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: _aspectRatioForWidth(
                                constraints.crossAxisExtent,
                                columns,
                              ),
                            ),
                          );
                        },
                      ),
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

  int _columnCountForWidth(double width) {
    if (width >= 900) return 5;
    if (width >= 700) return 4;
    if (width >= 520) return 3;
    return 2;
  }

  double _aspectRatioForWidth(double width, int columns) {
    if (columns >= 5) return 0.76;
    if (columns == 4) return 0.75;
    if (columns == 3) return 0.74;
    return 0.73;
  }

  Future<void> _openLevel(
    BuildContext context,
    HomeViewModel viewModel,
    LevelModel level,
  ) async {
    if (_isOpeningLevel) return;

    setState(() {
      _isOpeningLevel = true;
    });

    try {
      final isReady = await viewModel.prepareLevel(level.id);
      if (!context.mounted) return;

      if (!isReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.lockedLevelMessage)),
        );
        return;
      }

      await Navigator.pushNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(
          levelId: level.id,
          levelTitle: level.title,
          levelNumber: viewModel.levelNumberFor(level.id),
        ),
      );

      if (!context.mounted) return;
      await context.read<HomeViewModel>().load();
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningLevel = false;
        });
      }
    }
  }

  _CardPalette _paletteFor(int index) {
    const palettes = <_CardPalette>[
      _CardPalette(
        outerTop: Color(0xFF66BAF9),
        outerBottom: Color(0xFF2F8BDB),
        innerTop: Color(0xFF95D8FF),
        innerBottom: Color(0xFF66BDF4),
        edge: Color(0xFF2674C3),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFD34D),
        outerBottom: Color(0xFFF0B52B),
        innerTop: Color(0xFFFFE27B),
        innerBottom: Color(0xFFFFCF49),
        edge: Color(0xFFD39B16),
      ),
      _CardPalette(
        outerTop: Color(0xFF63DDD7),
        outerBottom: Color(0xFF27B7B6),
        innerTop: Color(0xFF96F0E4),
        innerBottom: Color(0xFF59D3CF),
        edge: Color(0xFF219795),
      ),
      _CardPalette(
        outerTop: Color(0xFFB6ED64),
        outerBottom: Color(0xFF7DC83B),
        innerTop: Color(0xFFD4F68F),
        innerBottom: Color(0xFFB0E45D),
        edge: Color(0xFF69AB2A),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFB156),
        outerBottom: Color(0xFFF37A22),
        innerTop: Color(0xFFFFCB82),
        innerBottom: Color(0xFFFFA14A),
        edge: Color(0xFFD36A18),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFAE58),
        outerBottom: Color(0xFFF18832),
        innerTop: Color(0xFFFFD295),
        innerBottom: Color(0xFFFFA550),
        edge: Color(0xFFD26A21),
      ),
      _CardPalette(
        outerTop: Color(0xFFBC86FF),
        outerBottom: Color(0xFF8B52DF),
        innerTop: Color(0xFFD9B0FF),
        innerBottom: Color(0xFFB67BF8),
        edge: Color(0xFF7542C9),
      ),
      _CardPalette(
        outerTop: Color(0xFFA7DEFF),
        outerBottom: Color(0xFF65BEEB),
        innerTop: Color(0xFFCDEEFF),
        innerBottom: Color(0xFF99D6F8),
        edge: Color(0xFF529FC9),
      ),
      _CardPalette(
        outerTop: Color(0xFFFFA6C8),
        outerBottom: Color(0xFFEC6796),
        innerTop: Color(0xFFFFCBDF),
        innerBottom: Color(0xFFFF96BE),
        edge: Color(0xFFD55282),
      ),
      _CardPalette(
        outerTop: Color(0xFFFF7FD0),
        outerBottom: Color(0xFFD93FAE),
        innerTop: Color(0xFFFFA8E2),
        innerBottom: Color(0xFFFF74CF),
        edge: Color(0xFFBA2C91),
      ),
    ];

    return palettes[index % palettes.length];
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({
    required this.message,
    required this.onRetry,
  });

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomButton(
              label: AppStrings.retry,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceLevelCard extends StatelessWidget {
  const _ReferenceLevelCard({
    required this.level,
    required this.levelNumber,
    required this.palette,
    required this.isBusy,
    required this.onTap,
  });

  final LevelModel level;
  final int levelNumber;
  final _CardPalette palette;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: 0,
      shadows: const <Shadow>[
        Shadow(
          color: Color(0x66000000),
          offset: Offset(0, 2),
          blurRadius: 0,
        ),
      ],
    );

    return IgnorePointer(
      ignoring: isBusy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: isBusy ? 0.72 : 1,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: tapActionCallback(context, onTap),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    palette.outerTop,
                    palette.outerBottom,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: palette.edge, width: 2.4),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: palette.edge.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        palette.innerTop,
                        palette.innerBottom,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.92),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'LEVEL $levelNumber',
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: titleStyle,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          flex: 9,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x12000000),
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Center(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final previewSize =
                                      constraints.biggest.shortestSide;
                                  return LevelPreview(
                                    level: level,
                                    size: previewSize,
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    borderRadius: BorderRadius.zero,
                                    style: LevelPreviewStyle.colored,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPalette {
  const _CardPalette({
    required this.outerTop,
    required this.outerBottom,
    required this.innerTop,
    required this.innerBottom,
    required this.edge,
  });

  final Color outerTop;
  final Color outerBottom;
  final Color innerTop;
  final Color innerBottom;
  final Color edge;
}
