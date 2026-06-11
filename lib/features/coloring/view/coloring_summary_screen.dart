import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/coloring/viewmodel/coloring_viewmodel.dart';
import 'package:provider/provider.dart';

class ColoringSummaryScreen extends StatelessWidget {
  const ColoringSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ColoringProvider>(
        builder: (context, provider, _) {
          return Container(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    // color: AppColors.white.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        // color: AppColors.primaryPurple.withValues(alpha: 0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Back/Home Button
                          InkWell(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                // color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    // color: AppColors.black.withValues(
                                    //   alpha: 0.05,
                                    // ),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home_rounded,
                                // color: AppColors.primaryPurple,
                                size: 24,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'You did it!',
                                style: TextStyle(
                                  fontFamily: "Regular",
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  // color: AppColors.primaryPurple,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balance the back button
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Stars
                      // StarRating(stars: provider.stars),
                      const SizedBox(height: 40),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.timer_outlined,
                              iconColor: Colors.grey,
                              // iconColor: AppColors.statIconGray,
                              title: 'Time',
                              value: provider.formattedTime,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle_rounded,
                              iconColor: Colors.green,
                              // iconColor: AppColors.smartGreen,
                              title: 'Score',
                              value: '${provider.scorePercentage}%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Bottom Actions
                      Row(
                        children: [
                          // Home Button
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              style: ElevatedButton.styleFrom(
                                // backgroundColor: AppColors.smartBlue,
                                // foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Icon(Icons.home_rounded, size: 32),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Selection Grid Button
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () {
                                // Pop Summary Screen
                                Navigator.of(context).pop();
                                // Pop Coloring Screen to go back to selection
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                // backgroundColor: AppColors.smartYellow,
                                // foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Next Button
                          Expanded(
                            flex: 5,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                // backgroundColor: AppColors.smartGreen,
                                // foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: "Regular",
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.check_rounded,
                                    size: 24,
                                  ),
                                ],
                              ),
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
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        // color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(color: AppColors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: "Regular",
                      fontWeight: FontWeight.bold,
                      // color: AppColors.black.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: "Regular",
                      fontWeight: FontWeight.bold,
                      // color: AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
