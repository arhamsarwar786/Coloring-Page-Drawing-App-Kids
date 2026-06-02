import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/coloring/widgets/canvas_widget.dart';

class ColoringBoard extends StatefulWidget {
  final ColoringProvider provider;
  const ColoringBoard({super.key, required this.provider});

  @override
  State<ColoringBoard> createState() => _ColoringBoardState();
}

class _ColoringBoardState extends State<ColoringBoard> {
  @override
  void initState() {
    super.initState();
    widget.provider.canvasKey = GlobalKey();
  }

  String get _itemEmoji {
    return widget.provider.activePartLabel ?? '🎨';
  }

  String get _instructionText {
    final provider = widget.provider;
    if (!provider.isLoaded) return 'Loading your picture...';
    if (provider.isPartByPartComplete) {
      return 'All parts are colored! Touch Done! $_itemEmoji';
    }
    return 'Part ${provider.completedParts + 1}/${provider.totalParts}: Color the ${provider.activePartLabel}! $_itemEmoji';
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;

    return Column(
      children: [
        // ── Dynamic Child-Friendly Instruction Card ─────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            // color: AppColors.smartGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              // color: AppColors.smartGreen.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                // color: AppColors.smartGreen.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                // color: AppColors.smartGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "instructionText",
                  // _instructionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    // color: AppColors.smartGreen,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        // if (provider.isLoaded && provider.totalParts > 0) ...[
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 10),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(999),
        //       child: LinearProgressIndicator(
        //         value: provider.isPartByPartComplete
        //             ? 1
        //             : (provider.completedParts + provider.activePartProgress) /
        //                 provider.totalParts,
        //         minHeight: 8,
        //         // backgroundColor: AppColors.smartGreen.withValues(alpha: 0.12),
        //         // valueColor: const AlwaysStoppedAnimation<Color>(
        //         //   // AppColors.smartGreen,
        //         // ),
        //       ),
        //     ),
        //   ),
        // ],

        // ── Canvas ──────────────────────────────────────────────────────────
        Expanded(
          flex: 12,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                // color: AppColors.primaryPurple.withValues(alpha: 0.3),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  // color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: CanvasWidget(),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // ── Controls Row (Undo, Brush Size, Clear) ──────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Undo Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: provider.canUndo ? () => provider.undo() : null,
                  icon: Icon(
                    Icons.undo_rounded,
                    // color: provider.canUndo
                    //     ? AppColors.primaryPurple
                    //     : Colors.grey,
                  ),
                  tooltip: 'Undo',
                ),
              ),
              const SizedBox(width: 12),

              // Brush Size Slider
              // Expanded(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 2,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(20),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withValues(alpha: 0.05),
              //           blurRadius: 8,
              //           offset: const Offset(0, 3),
              //         ),
              //       ],
              //     ),
              //     child: Row(
              //       children: [
              //         const Icon(
              //           Icons.brush_rounded,
              //           // color: AppColors.primaryPurple,
              //           size: 20,
              //         ),
              //         Expanded(
              //           child: SliderTheme(
              //             data: SliderTheme.of(context).copyWith(
              //               trackHeight: 6,
              //               thumbShape: const RoundSliderThumbShape(
              //                 enabledThumbRadius: 10,
              //               ),
              //               overlayShape: const RoundSliderOverlayShape(
              //                 overlayRadius: 20,
              //               ),
              //             ),
              //             child: Slider(
              //               value: provider.brushScale,
              //               min: 0.45,
              //               max: 2.0,
              //               divisions: 8,
              //               // activeColor: AppColors.primaryPurple,
              //               // inactiveColor: AppColors.primaryPurple.withValues(
              //               //   alpha: 0.15,
              //               // ),
              //               onChanged: provider.changeBrushScale,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(width: 12),

              // Clear Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => provider.retry(),
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    // color: AppColors.smartRed,
                  ),
                  tooltip: 'Clear All',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Color palette ────────────────────────────────────────────────────
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: provider.palette.length,
            itemBuilder: (context, index) {
              final color = provider.palette[index];
              final isSelected = provider.activeColor == color;
              return GestureDetector(
                onTap: () => provider.changeColor(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  width: isSelected ? 56 : 46, // Bigger selected color
                  height: isSelected ? 56 : 46,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white70,
                      width: isSelected ? 4 : 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
