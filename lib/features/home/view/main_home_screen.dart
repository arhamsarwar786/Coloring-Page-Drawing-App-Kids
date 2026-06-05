// import 'package:flutter/material.dart';
// import 'package:play_craft_kids/app/routes/app_routes.dart';
// import 'package:play_craft_kids/core/constants/app_strings.dart';
// import 'package:play_craft_kids/core/utils/app_bottom_bar.dart';
// import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
// import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
// import 'package:play_craft_kids/features/home/components/category_card.dart';

// import 'package:play_craft_kids/features/home/view/home_screen.dart';
// import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
// import 'package:play_craft_kids/shared/utils/interaction_feedback.dart';
// import 'package:provider/provider.dart';
// import 'dart:math';

// // Apne actual project paths ke mutabik in imports ko adjust kar lena:
// import '../viewmodel/home_viewmodel.dart';

// class MainHomeScreen extends StatefulWidget {
//   @override
//   State<MainHomeScreen> createState() => _MainHomeScreenState();
// }

// class _MainHomeScreenState extends State<MainHomeScreen> {
//   // const MainHomeScreen({Key? key}) : super(key: key);
//   int selectedIndex = 0;
//   @override
//   Widget build(BuildContext context) {
//     // ViewModel ko read aur listen kar rahe hain
//     final viewModel = context.watch<HomeViewModel>();

//     // Show all categories and use unique images for each
//     final allCategories = viewModel.categories;
//     return Scaffold(
//       bottomNavigationBar: Container(
//           margin: const EdgeInsets.only(
//             left: 18,
//             right: 18,
//             bottom: 14,
//           ),
//           padding: const EdgeInsets.symmetric(
//             horizontal: 22,
//             vertical: 10,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(40),
//             // border: Border.all(
//             //   color: const Color(0xFFD9C2A3),
//             //   width: 2,
//             // ),
//             // boxShadow: [
//             //   BoxShadow(
//             //     color: Colors.black.withOpacity(0.15),
//             //     blurRadius: 10,
//             //     offset: const Offset(0, 5),
//             //   ),
//             // ],
//           ),
//           child:

//               // State class ke andar variable:

// // Build method ke andar jahan aap buttons show kar rahi hain:
//               Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               // Pehla Button (Index 0)
//               AppBottomBar(
//                 icon: Icons.home,
//                 topColor: Colors.orangeAccent,
//                 bottomColor: Colors.orange,
//                 isSelected: selectedIndex == 0, // Agar index 0 hai to true hoga
//                 onTap: () {
//                   handleTapAction(context, () {});
//                   setState(() {
//                     selectedIndex = 0; // Click hone par state update hogi
//                   });
//                 },
//               ),

//               AppBottomBar(
//                 isSelected: selectedIndex == 1,
//                 icon: Icons.person_rounded,
//                 topColor: const Color(0xFFFFA48A),
//                 bottomColor: const Color(0xFFD9534F),
//                 onTap: () {
//                   handleTapAction(context, () {});
//                   // persistHistorySnapshot(
//                   // captureThumbnail: true);
//                   if (context.mounted) {
//                     Navigator.pushNamed(context, AppRoutes.levels);
//                   }
//                   // Fauran next screen par bhej dein
//                   // if (context.mounted) {
//                   //   Navigator.pushNamed(context, AppRoutes.skins);
//                   // }
//                   setState(() {
//                     selectedIndex = 1;
//                   });
//                 },
//               ),

//               // Doosra Button (Index 1)
//               AppBottomBar(
//                 icon: Icons.settings,
//                 topColor: Colors.blueAccent,
//                 bottomColor: Colors.blue,
//                 isSelected: selectedIndex == 2, // Agar index 1 hai to true hoga
//                 onTap: () {
//                   setState(() {
//                     handleTapAction(context, () {});
//                     showDialog(
//                       context: context,
//                       barrierColor: Colors.black.withOpacity(
//                           0.45), // Piche ka area dark karne ke liye
//                       builder: (BuildContext context) {
//                         return const Center(
//                           child:
//                               KidsSettingsDialog(), // Humara naya settings dialog widget
//                         );
//                       },
//                     );
//                     // showGeneralDialog(
//                     //   context: context,
//                     //   barrierDismissible: true,
//                     //   barrierLabel: "Settings",
//                     //   barrierColor: Colors.black26,
//                     //   transitionDuration: const Duration(milliseconds: 250),
//                     //   pageBuilder: (_, __, ___) => const SettingsDialog(),
//                     // );

//                     selectedIndex = 2;
//                   });
//                 },
//               ),
//             ],
//           )),
//       backgroundColor: const Color(0xffFAF8F5),
//       body: viewModel.isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xffFFB03A)),
//               ),
//             )
//           : viewModel.error != null
//               ? Center(
//                   child: Text(
//                     viewModel.error!,
//                     style: const TextStyle(color: Colors.red, fontSize: 16),
//                   ),
//                 )
//               : Container(
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/images/bgg.png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: SafeArea(
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           "assets/images/logo.png",
//                           height: 250,
//                         ),
//                         const SizedBox(height: 20),
//                         Expanded(
//                           child: allCategories.isEmpty
//                               ? const Center(
//                                   child: Text(
//                                     "No categories available",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xff3B3F58),
//                                     ),
//                                   ),
//                                 )
//                               : GridView.builder(
//                                   physics: const BouncingScrollPhysics(),
//                                   padding: const EdgeInsets.all(16.0),
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 2,
//                                     crossAxisSpacing: 16,
//                                     mainAxisSpacing: 16,
//                                     childAspectRatio:
//                                         0.85, // Jisse card exact square/rectangle balanced lage
//                                   ),
//                                   itemCount: allCategories
//                                       .length, // Aapki categories ki total length
//                                   itemBuilder: (context, index) {
//                                     final category = allCategories[index];
//                                     final categoryTitle =
//                                         category.title.toLowerCase();

//                                     // --- 1. Dynamic Image Logic ---
//                                     String myCustomImage = 'assets/images/logo.png';
//                                     if (categoryTitle == 'fruits') {
//                                       myCustomImage = 'assets/images/apples.png';
//                                     } else if (categoryTitle == 'animals') {
//                                       myCustomImage = 'assets/images/animalss.png';
//                                     } else if (categoryTitle == 'vegetables') {
//                                       myCustomImage = 'assets/images/orange.webp';
//                                     } else if (categoryTitle == 'wild animals' || categoryTitle == 'wild_animals') {
//                                       myCustomImage = 'assets/images/un_colored_dolphin.webp';
//                                     } else if (categoryTitle == 'colors') {
//                                       myCustomImage = 'assets/images/logo.png';
//                                     } else if (categoryTitle == 'alphabets') {
//                                       myCustomImage = 'assets/images/logo.png';
//                                     } else if (categoryTitle == 'drawing') {
//                                       myCustomImage = 'assets/images/pen.png';
//                                     }

//                                     // --- 2. Dynamic Colors Logic ---
//                                     final List<Color> cardMainColors = [
//                                       const Color(0xFF4DB6AC), // Teal
//                                       const Color(0xFFFFB74D), // Orange
//                                       const Color(0xFFF06292), // Pink
//                                       const Color(0xFF81C784), // Green
//                                       const Color(0xFFBA68C8), // Purple
//                                       const Color(0xFF4FC3F7), // Light Blue
//                                     ];

//                                     final List<Color> cardBorderColors = [
//                                       const Color(0xFF378981), // Darker Teal
//                                       const Color(0xFFD88916), // Darker Orange
//                                       const Color(0xFFB83763), // Darker Pink
//                                       const Color(0xFF539456), // Darker Green
//                                       const Color(0xFF7B1FA2), // Darker Purple
//                                       const Color(0xFF0288D1), // Darker Light Blue
//                                     ];

//                                     // Har category index ke mutabiq apna color khud choose kar legi
//                                     Color currentMainColor = cardMainColors[
//                                         index % cardMainColors.length];
//                                     Color currentBorderColor = cardBorderColors[
//                                         index % cardBorderColors.length];

//                                     // --- 3. Return First Code Wala Stylish Container ---
//                                     return CategoryCard(
//                                       title: category
//                                           .title, // Dynamic title loop se
//                                       imagePath:
//                                           myCustomImage, // Dynamic image path condition se
//                                       baseColor:
//                                           currentMainColor, // Dynamic color
//                                       borderColor:
//                                           currentBorderColor, // Dynamic border
//                                       onTap: () {
//                                         // Set selected category first
//                                         viewModel.selectCategory(category.id);
//                                         tapActionCallback(context, () {});
//                                         handleTapAction(context, () {});
//                                         Navigator.pushNamed(
//                                             context, AppRoutes.home);
//                                       },
//                                     );
//                                   },
//                                 ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//     );
//   }
// }

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
  Widget build(BuildContext context) {
    // ViewModel ko read aur listen kar rahe hain
    final viewModel = context.watch<HomeViewModel>();

    // Show all categories and use unique images for each
    final allCategories = viewModel.categories;

    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: 18,
          right: 18,
          bottom: 14,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
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
            AppBottomBar(
              isSelected: selectedIndex == 1,
              icon: Icons.person_rounded,
              topColor: const Color(0xFFFFA48A),
              bottomColor: const Color(0xFFD9534F),
              onTap: () {
                handleTapAction(context, () {});
                if (context.mounted) {
                  Navigator.pushNamed(context, AppRoutes.levels);
                }
                setState(() {
                  selectedIndex = 1;
                });
              },
            ),

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
