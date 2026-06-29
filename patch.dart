import 'dart:io';

void main() {
  final file = File('c:/Users/LENOVO/Documents/Coloring-Page-Drawing-App-Kids/lib/features/coloring/view/coloring_completion_screen.dart');
  final content = file.readAsStringSync().replaceAll('\r\n', '\n');
  
  // Find the actionButtons definition
  final actionStart = content.indexOf('                      final actionButtons = Padding(');
  final actionEnd = content.indexOf('                      if (isLandscape) {', actionStart);
  
  if (actionStart == -1 || actionEnd == -1) {
    print('Could not find actionButtons block');
    return;
  }
  
  final newActionButtons = '''                      final actionButtons = Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: isLandscape
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  passed
                                      ? _ActionButton(
                                          icon: Icons.arrow_forward_rounded,
                                          label: 'Next Level',
                                          color: const Color(0xFF00E676),
                                          textColor: Colors.white,
                                          onTap: () async {
                                            final currentLevel = provider.currentLevel;
                                            if (currentLevel != null) {
                                              final drawingRepo = context.read<DrawingRepository>();
                                              final nextLevelId = await drawingRepo.getNextLevelId(currentLevel.id);
                                              LevelModel? nextLevel;
                                              if (nextLevelId != null) {
                                                nextLevel = await drawingRepo.getLevelById(nextLevelId);
                                              }
                                              if (nextLevel != null && mounted) {
                                                final coloringProvider = context.read<ColoringProvider>();
                                                final activity = ActivityItem(
                                                  id: nextLevel.id,
                                                  label: nextLevel.title,
                                                  display: nextLevel.title,
                                                  color: Colors.red,
                                                  imagePath: nextLevel.activityItem?.imagePath ?? nextLevel.imagePath ?? 'assets/images/un_border_apple.webp',
                                                );
                                                coloringProvider.setItem(activity, provider.currentCategoryId, level: nextLevel);
                                                Navigator.of(context).pushAndRemoveUntil(
                                                  MaterialPageRoute(builder: (_) => ColoringScreen(imagePath: activity.imagePath)),
                                                  (route) => route.isFirst,
                                                );
                                              } else if (mounted) {
                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                              }
                                            } else {
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                            }
                                          },
                                        )
                                      : _ActionButton(
                                          icon: Icons.replay_rounded,
                                          label: 'Try Again!',
                                          color: const Color(0xFFFF5722),
                                          textColor: Colors.white,
                                          onTap: () {
                                            provider.retry();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                  const SizedBox(height: 12),
                                  _ActionButton(
                                    icon: Icons.home_rounded,
                                    label: 'Home',
                                    color: Colors.white.withValues(alpha: 0.18),
                                    textColor: Colors.white,
                                    onTap: () async {
                                      if (mounted) {
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      }
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  // Home button
                                  _ActionButton(
                                    icon: Icons.home_rounded,
                                    label: 'Home',
                                    color: Colors.white.withValues(alpha: 0.18),
                                    textColor: Colors.white,
                                    onTap: () async {
                                      if (mounted) {
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  // Next level or Restart button
                                  Expanded(
                                    child: passed
                                        ? _ActionButton(
                                            icon: Icons.arrow_forward_rounded,
                                            label: 'Next Level',
                                            color: const Color(0xFF00E676),
                                            textColor: Colors.white,
                                            onTap: () async {
                                              final currentLevel = provider.currentLevel;
                                              if (currentLevel != null) {
                                                final drawingRepo = context.read<DrawingRepository>();
                                                final nextLevelId = await drawingRepo.getNextLevelId(currentLevel.id);
                                                LevelModel? nextLevel;
                                                if (nextLevelId != null) {
                                                  nextLevel = await drawingRepo.getLevelById(nextLevelId);
                                                }
                                                if (nextLevel != null && mounted) {
                                                  final coloringProvider = context.read<ColoringProvider>();
                                                  final activity = ActivityItem(
                                                    id: nextLevel.id,
                                                    label: nextLevel.title,
                                                    display: nextLevel.title,
                                                    color: Colors.red,
                                                    imagePath: nextLevel.activityItem?.imagePath ?? nextLevel.imagePath ?? 'assets/images/un_border_apple.webp',
                                                  );
                                                  coloringProvider.setItem(activity, provider.currentCategoryId, level: nextLevel);
                                                  Navigator.of(context).pushAndRemoveUntil(
                                                    MaterialPageRoute(builder: (_) => ColoringScreen(imagePath: activity.imagePath)),
                                                    (route) => route.isFirst,
                                                  );
                                                } else if (mounted) {
                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                }
                                              } else {
                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                              }
                                            },
                                          )
                                        : _ActionButton(
                                            icon: Icons.replay_rounded,
                                            label: 'Try Again!',
                                            color: const Color(0xFFFF5722),
                                            textColor: Colors.white,
                                            onTap: () {
                                              provider.retry();
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                  ),
                                ],
                              ),
                      );

''';

  final beforeAction = content.substring(0, actionStart);
  final afterAction = content.substring(actionEnd);
  
  var newContent = beforeAction + newActionButtons + afterAction;

  // Now let's fix coinsBanner to use Flexible
  newContent = newContent.replaceAll(
    "const Text('🪙',\n                                            style: TextStyle(fontSize: 26)),\n                                        const SizedBox(width: 8),\n                                        Text(\n                                          '+\$coins Coins Earned!',",
    "const Text('🪙',\n                                            style: TextStyle(fontSize: 26)),\n                                        const SizedBox(width: 8),\n                                        Flexible(\n                                          child: Text(\n                                            '+\$coins Coins Earned!',"
  );
  
  newContent = newContent.replaceAll(
    "                                          ),\n                                        ),\n                                      ],\n                                    ),\n                                  ),\n                                )",
    "                                          ),\n                                        ),\n                                        ),\n                                      ],\n                                    ),\n                                  ),\n                                )"
  );

  file.writeAsStringSync(newContent.replaceAll('\n', '\r\n'));
  print('Success');
}
