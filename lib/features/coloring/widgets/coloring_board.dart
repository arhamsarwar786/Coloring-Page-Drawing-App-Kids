import 'package:flutter/material.dart';
import 'package:play_craft_kids/core/constants/app_colors.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:play_craft_kids/features/coloring/widgets/canvas_widget.dart';
import 'package:play_craft_kids/features/coloring/widgets/delete_dialog.dart';

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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Canvas ──────────────────────────────────────────────────────────
          Expanded(
            flex: 10,
            child: Container(
              margin: const EdgeInsets.only(right: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
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

          // ── Controls Column (Undo, Clear, Palette) ──────────────────────────
          SizedBox(
            width: 80,
            child: Column(
              children: [
                // Undo Button
                // Tooltip(
                //   message: "Undo",
                //   triggerMode: TooltipTriggerMode.longPress,
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(16),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withValues(alpha: 0.05),
                //           blurRadius: 8,
                //           offset: const Offset(0, 3),
                //         ),
                //       ],
                //     ),
                //     child: InkWell(
                //       onTap: provider.canUndo
                //           ? () {
                //               showDialog(
                //                 context: context,
                //                 barrierDismissible: false,
                //                 builder: (context) => UndoDialog(
                //                   onConfirm: () {
                //                     provider.undo(); // Yahan undo trigger hoga
                //                   },
                //                 ),
                //               );
                //             }
                //           : null,
                //       child: Image.asset(
                //         "assets/images/undo.webp",
                //         width: 60,
                //         height: 60,
                //       ),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 12),

// Undo Button Fix
                Tooltip(
                  message: "Undo",
                  // Tooltip ka triggerMode default hi 'longPress' hota hai
                  child: InkWell(
                    onTap: provider.canUndo
                        ? () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => UndoDialog(
                                onConfirm: () {
                                  provider.undo();
                                },
                              ),
                            );
                          }
                        : null,
                    child: Container(
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
                      child: Image.asset(
                        "assets/images/undo.webp",
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
                // Clear Button
                Tooltip(
                  message: "Reset",
                  triggerMode: TooltipTriggerMode.longPress,
                  child: Container(
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
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => DeleteDialog(
                            onConfirm: () {},
                            ontap: () {
                              provider.retry();
                            },
                          ),
                        );
                      },
                      child: Image.asset(
                        "assets/images/delete.webp",
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Color palette (Vertical) ──────────────────────────────────
                Expanded(
                  child: SafeArea(
                    left: false,
                    top: false,
                    right: true,
                    bottom: true,
                    child: Container(
                      width: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: provider.palette.length,
                        itemBuilder: (context, index) {
                          final color = provider.palette[index];
                          final isSelected = provider.activeColor == color;
                          return Tooltip(
                            message: "Color ${index + 1}",
                            child: GestureDetector(
                              onTap: () => provider.changeColor(color),
                              child: Transform.scale(
                                scale: isSelected ? 1.15 : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutBack,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 2,
                                  ),
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      width: isSelected ? 3 : 1.5,
                                    ),
                                    boxShadow: [
                                      if (isSelected)
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      else
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
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
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // ── Canvas ──────────────────────────────────────────────────────────
        Expanded(
          flex: 10,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
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
                child: InkWell(
                    onTap: provider.canUndo
                        ? () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => UndoDialog(
                                onConfirm: () {
                                  provider.undo(); // Yahan undo trigger hoga
                                },
                              ),
                            );
                          }
                        : null, // Agar canUndo false hai, toh button disable rahega

                    // onTap: provider.canUndo ? () => provider.undo() : null,
                    child: Image.asset(
                      "assets/images/undo.webp",
                      width: 60,
                      height: 60,
                    )),
                //  IconButton(
                //   onPressed: provider.canUndo ? () => provider.undo() : null,
                //   icon: Icon(
                //     Icons.undo_rounded,
                //     // color: provider.canUndo
                //     //     ? AppColors.primaryPurple
                //     //     : Colors.grey,
                //   ),
                //   tooltip: 'Undo',
                // ),
              ),

              // InkWell(
              //     onTap: provider.canUndo ? () => provider.undo() : null,
              //     child: Image.asset(
              //       "assets/images/undo.webp",
              //       width: 60,
              //       height: 60,
              //     )),
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
                  child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => DeleteDialog(
                            onConfirm:
                                () {}, // Khali rakh dein agar zaroorat nahi
                            ontap: () {
                              provider
                                  .retry(); // Sirf tab chalega jab "YES" dabaenge
                            },
                          ),
                        );
                      },
                      // onTap: () {
                      // onTap: () {
                      //   provider.retry();
                      //   showDialog(
                      //     context: context,
                      //     // BarrierDismissible false karne se bahar click karne par dialog band nahi hoga
                      //     barrierDismissible: false,
                      //     builder: (context) => DeleteDialog(
                      //         onConfirm: () {
                      //           // --- YAHAN AAPKA ASLI DELETE KA LOGIC AAYEGA ---
                      //           // Jaise: viewModel.deleteHistory();
                      //           // Ya: provider.clearCanvas();
                      //           print("Delete action confirm ho gaya!");
                      //         },
                      //         ontap: provider.retry),
                      //   );
                      // },
                      // // },
                      child: Image.asset(
                        "assets/images/delete.webp",
                        width: 60,
                        height: 60,
                      ))
                  //  IconButton(
                  //   onPressed: () => provider.retry(),
                  //   icon: const Icon(
                  //     Icons.delete_sweep_rounded,
                  //     // color: AppColors.smartRed,
                  //   ),
                  //   tooltip: 'Clear All',
                  // ),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Color palette ────────────────────────────────────────────────────
        SafeArea(
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(vertical: 2),
            // decoration: BoxDecoration(
            //   color: Colors.white.withValues(alpha: 0.5),
            //   borderRadius: BorderRadius.circular(24),
            // ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: provider.palette.length,
              itemBuilder: (context, index) {
                final color = provider.palette[index];
                final isSelected = provider.activeColor == color;
                return GestureDetector(
                  onTap: () => provider.changeColor(color),
                  child: Transform.scale(
                    scale: isSelected ? 1.15 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white70,
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
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
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
