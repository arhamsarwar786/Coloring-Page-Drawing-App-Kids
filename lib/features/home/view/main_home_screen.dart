import 'package:flutter/material.dart';
import 'package:play_craft_kids/app/routes/app_routes.dart';
import 'package:play_craft_kids/core/constants/app_strings.dart';
import 'package:play_craft_kids/core/utils/app_bottom_bar.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/features/home/components/category_card.dart';
import 'package:play_craft_kids/features/home/view/home_screen.dart';
import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
import 'package:play_craft_kids/shared/utils/interaction_feedback.dart';
import 'package:provider/provider.dart';
import 'dart:math';

// Apne actual project paths ke mutabik in imports ko adjust kar lena:
import '../viewmodel/home_viewmodel.dart';

class MainHomeScreen extends StatefulWidget {
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final viewModel = context.read<HomeViewModel>();
      final pointsAwarded = await viewModel.addDailyBonusPoints();
      if (pointsAwarded > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Daily Bonus! You received $pointsAwarded coins!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel ko read aur listen kar rahe hain
    final viewModel = context.watch<HomeViewModel>();

    // Show all categories and use unique images for each
    final allCategories = viewModel.categories;

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
            // bottom: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Pehla Button (Index 0) - Home
              AppBottomBar(
                icon: Icons.home,
                topColor: Colors.orangeAccent,
                bottomColor: Colors.orange,
                isSelected: selectedIndex == 0,
                onTap: () {
                  handleTapAction(context, () {});
                  setState(() {
                    selectedIndex = 0;
                  });
                },
              ),

              // Doosra Button (Index 1) - Levels
              // AppBottomBar(
              //   isSelected: selectedIndex == 1,
              //   icon: Icons.person_rounded,
              //   topColor: const Color(0xFFFFA48A),
              //   bottomColor: const Color(0xFFD9534F),
              //   onTap: () async{
              //      await persistHistorySnapshot(
              //                           captureThumbnail: true);
              //                       if (context.mounted) {
              //                         Navigator.pushNamed(
              //                             context, AppRoutes.levels);
              //                       }
              //     // handleTapAction(context, () {});
              //     // if (context.mounted) {
              //     //   Navigator.pushNamed(context, AppRoutes.levels);
              //     // }
              //     // setState(() {
              //     //   selectedIndex = 1;
              //     // });
              //   },
              // ),

              // Teesra Button (Index 2) - Settings
              AppBottomBar(
                icon: Icons.settings,
                topColor: Colors.blueAccent,
                bottomColor: Colors.blue,
                isSelected: selectedIndex == 2,
                onTap: () {
                  setState(() {
                    handleTapAction(context, () {});
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.45),
                      builder: (BuildContext context) {
                        return const Center(
                          child:
                              KidsSettingsDialog(), // Aapka custom settings dialog
                        );
                      },
                    );
                    selectedIndex = 2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xffFAF8F5),
      body: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFB03A)),
              ),
            )
          : viewModel.error != null
              ? Center(
                  child: Text(
                    viewModel.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bgg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: allCategories.isEmpty
                        ? const Center(
                            child: Text(
                              "No categories available",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B3F58),
                              ),
                            ),
                          )
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              // 1. Logo aur Top Spacing (Ab yeh bhi scroll hoga!)
                              SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      "assets/images/logo.png",
                                      height: 250,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),

                              // 2. Categories Grid (SliverGrid scroll view ke sath attach ho gaya)
                              SliverPadding(
                                padding: const EdgeInsets.all(16.0),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final category = allCategories[index];
                                      final categoryTitle =
                                          category.title.toLowerCase();

                                      // --- Dynamic Image Logic ---
                                      String myCustomImage =
                                          'assets/images/dog.webp';
                                      if (categoryTitle == 'fruits') {
                                        myCustomImage =
                                            'assets/images/apples.png';
                                      } else if (categoryTitle == 'animals') {
                                        myCustomImage =
                                            'assets/images/dog.webp';
                                      } else if (categoryTitle ==
                                          'vegetables') {
                                        myCustomImage =
                                            'assets/images/vegetable.png';
                                      } else if (categoryTitle ==
                                              'wild animals' ||
                                          categoryTitle == 'wild_animals') {
                                        myCustomImage =
                                            'assets/images/animalss.png';
                                      } else if (categoryTitle == 'colors') {
                                        myCustomImage =
                                            'assets/images/color_activity_icon.webp';
                                      } else if (categoryTitle == 'alphabets') {
                                        myCustomImage =
                                            'assets/images/alphabets.png';
                                      } else if (categoryTitle == 'drawing') {
                                        myCustomImage = 'assets/images/pen.png';
                                      }

                                      // --- Dynamic Colors Logic ---
                                      final List<Color> cardMainColors = [
                                        const Color(0xFF4DB6AC), // Teal
                                        const Color(0xFFFFB74D), // Orange
                                        const Color(0xFFF06292), // Pink
                                        const Color(0xFF81C784), // Green
                                        const Color(0xFFBA68C8), // Purple
                                        const Color(0xFF4FC3F7), // Light Blue
                                      ];

                                      final List<Color> cardBorderColors = [
                                        const Color(0xFF378981),
                                        const Color(0xFFD88916),
                                        const Color(0xFFB83763),
                                        const Color(0xFF539456),
                                        const Color(0xFF7B1FA2),
                                        const Color(0xFF0288D1),
                                      ];

                                      Color currentMainColor = cardMainColors[
                                          index % cardMainColors.length];
                                      Color currentBorderColor =
                                          cardBorderColors[
                                              index % cardBorderColors.length];

                                      return CategoryCard(
                                        title: category.title,
                                        imagePath: myCustomImage,
                                        baseColor: currentMainColor,
                                        borderColor: currentBorderColor,
                                        onTap: () {
                                          viewModel.selectCategory(category.id);
                                          tapActionCallback(context, () {});
                                          handleTapAction(context, () {});
                                          Navigator.pushNamed(
                                              context, AppRoutes.home);
                                        },
                                      );
                                    },
                                    childCount: allCategories.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
    );
  }
}
