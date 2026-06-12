import 'package:flutter/material.dart';
import 'package:play_craft_kids/app/routes/app_routes.dart';
import 'package:play_craft_kids/core/constants/app_strings.dart';
import 'package:play_craft_kids/core/utils/app_bottom_bar.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/features/home/components/category_card.dart';
import 'package:play_craft_kids/features/home/components/custom_bar.dart';
import 'package:play_craft_kids/features/home/view/home_screen.dart';
import 'package:play_craft_kids/features/settings/view/settings_screen.dart';
import 'package:play_craft_kids/shared/utils/interaction_feedback.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

// Apne actual project paths ke mutabik in imports ko adjust kar lena:
import '../viewmodel/home_viewmodel.dart';

class MainHomeScreen extends StatefulWidget {
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;
//       final viewModel = context.read<HomeViewModel>();
//       final pointsAwarded = await viewModel.addDailyBonusPoints();
//       if (pointsAwarded > 0 && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('🎉 Daily Bonus! You received $pointsAwarded coins!'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ViewModel ko read aur listen kar rahe hain
//     final viewModel = context.watch<HomeViewModel>();

//     // Show all categories and use unique images for each
//     final allCategories = viewModel.categories;

//     return Scaffold(
//       bottomNavigationBar: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment
//               .spaceEvenly, // Buttons ko barabar distribute karne ke liye
//           children: [
//             // Home Button
//             AppBottomBar(
//               // icon: Icons.home,
//               child: Image.asset("assets/images/home.webp"),
//               topColor: Colors.orangeAccent,
//               bottomColor: Colors.orange,
//               isSelected: selectedIndex == 0,
//               onTap: () {
//                 handleTapAction(context, () {});
//                 setState(() {
//                   selectedIndex = 0;
//                 });
//               },
//             ),

//             // Gallery Button (Naya item jo humne discuss kiya tha)
//             AppBottomBar(
//               child: Image.asset("assets/images/photo.png"),
//               // icon: Icons.photo_library, // Icon change kar sakte hain
//               topColor: Colors.purpleAccent,
//               bottomColor: Colors.purple,
//               isSelected: selectedIndex == 1,
//               onTap: () {
//                 setState(() {
//                   selectedIndex = 1;
//                 });
//                 // Yahan gallery ka action add karein
//               },
//             ),

//             // Settings Button
//             AppBottomBar(
//               child: Image.asset("assets/images/setting.png"),
//               // icon: Icons.settings,
//               topColor: Colors.blueAccent,
//               bottomColor: Colors.blue,
//               isSelected: selectedIndex == 2,
//               onTap: () {
//                 handleTapAction(context, () {});
//                 setState(() {
//                   selectedIndex = 2;
//                 });
//                 showDialog(
//                   context: context,
//                   barrierColor: Colors.black.withOpacity(0.45),
//                   builder: (BuildContext context) {
//                     return const Center(child: KidsSettingsDialog());
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),

//       // bottomNavigationBar: SafeArea(
//       //   child: Container(
//       //     margin: const EdgeInsets.only(
//       //       left: 18,
//       //       right: 18,
//       //       // bottom: 4,
//       //     ),
//       //     padding: const EdgeInsets.symmetric(
//       //       horizontal: 2,
//       //       vertical: 5,
//       //     ),
//       //     decoration: BoxDecoration(
//       //       borderRadius: BorderRadius.circular(40),
//       //     ),
//       //     child: Row(
//       //       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       //       children: [
//       //         // Pehla Button (Index 0) - Home
//       //         AppBottomBar(
//       //           icon: Icons.home,
//       //           topColor: Colors.orangeAccent,
//       //           bottomColor: Colors.orange,
//       //           isSelected: selectedIndex == 0,
//       //           onTap: () {
//       //             handleTapAction(context, () {});
//       //             setState(() {
//       //               selectedIndex = 0;
//       //             });
//       //           },
//       //         ),

//       //         // Doosra Button (Index 1) - Levels
//       //         // AppBottomBar(
//       //         //   isSelected: selectedIndex == 1,
//       //         //   icon: Icons.person_rounded,
//       //         //   topColor: const Color(0xFFFFA48A),
//       //         //   bottomColor: const Color(0xFFD9534F),
//       //         //   onTap: () async{
//       //         //      await persistHistorySnapshot(
//       //         //                           captureThumbnail: true);
//       //         //                       if (context.mounted) {
//       //         //                         Navigator.pushNamed(
//       //         //                             context, AppRoutes.levels);
//       //         //                       }
//       //         //     // handleTapAction(context, () {});
//       //         //     // if (context.mounted) {
//       //         //     //   Navigator.pushNamed(context, AppRoutes.levels);
//       //         //     // }
//       //         //     // setState(() {
//       //         //     //   selectedIndex = 1;
//       //         //     // });
//       //         //   },
//       //         // ),

//       //         // Teesra Button (Index 2) - Settings
//       //         AppBottomBar(
//       //           icon: Icons.settings,
//       //           topColor: Colors.blueAccent,
//       //           bottomColor: Colors.blue,
//       //           isSelected: selectedIndex == 2,
//       //           onTap: () {
//       //             setState(() {
//       //               handleTapAction(context, () {});
//       //               showDialog(
//       //                 context: context,
//       //                 barrierColor: Colors.black.withOpacity(0.45),
//       //                 builder: (BuildContext context) {
//       //                   return const Center(
//       //                     child:
//       //                         KidsSettingsDialog(), // Aapka custom settings dialog
//       //                   );
//       //                 },
//       //               );
//       //               selectedIndex = 2;
//       //             });
//       //           },
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//       // ),
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
//                     style: const TextStyle(
//                         fontFamily: "Regular", color: Colors.red, fontSize: 16),
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
//                     child: allCategories.isEmpty
//                         ? const Center(
//                             child: Text(
//                               "No categories available",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontFamily: "Regular",
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xff3B3F58),
//                               ),
//                             ),
//                           )
//                         : CustomScrollView(
//                             physics: const BouncingScrollPhysics(),
//                             slivers: [
//                               // 1. Logo aur Top Spacing (Ab yeh bhi scroll hoga!)
//                               SliverToBoxAdapter(
//                                 child: Column(
//                                   children: [
//                                     Image.asset(
//                                       "assets/images/logo.png",
//                                       height: 250,
//                                     ),
//                                     // const SizedBox(height: 20),
//                                   ],
//                                 ),
//                               ),

//                               // 2. Categories Grid (SliverGrid scroll view ke sath attach ho gaya)
//                               SliverPadding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 sliver: SliverGrid(
//                                   gridDelegate:
//                                       const SliverGridDelegateWithFixedCrossAxisCount(
//                                     crossAxisCount: 2,
//                                     crossAxisSpacing: 16,
//                                     mainAxisSpacing: 16,
//                                     childAspectRatio: 0.85,
//                                   ),
//                                   delegate: SliverChildBuilderDelegate(
//                                     (context, index) {
//                                       final category = allCategories[index];
//                                       final categoryTitle =
//                                           category.title.toLowerCase();

//                                       // --- Dynamic Image Logic ---
//                                       String myCustomImage =
//                                           'assets/images/dog.webp';
//                                       if (categoryTitle == 'fruits') {
//                                         myCustomImage =
//                                             'assets/images/apples.png';
//                                       } else if (categoryTitle == 'animals') {
//                                         myCustomImage =
//                                             'assets/images/dog.webp';
//                                       } else if (categoryTitle ==
//                                           'vegetables') {
//                                         myCustomImage =
//                                             'assets/images/vegetable.png';
//                                       } else if (categoryTitle ==
//                                               'wild animals' ||
//                                           categoryTitle == 'wild_animals') {
//                                         myCustomImage =
//                                             'assets/images/animalss.png';
//                                       } else if (categoryTitle == 'colors') {
//                                         myCustomImage =
//                                             'assets/images/color_activity_icon.webp';
//                                       } else if (categoryTitle == 'alphabets') {
//                                         myCustomImage =
//                                             'assets/images/alphabets.png';
//                                       } else if (categoryTitle == 'drawing') {
//                                         myCustomImage = 'assets/images/pen.png';
//                                       }

//                                       // --- Dynamic Colors Logic ---
//                                       final List<Color> cardMainColors = [
//                                         const Color(0xFF4DB6AC), // Teal
//                                         const Color(0xFFFFB74D), // Orange
//                                         const Color(0xFFF06292), // Pink
//                                         const Color(0xFF81C784), // Green
//                                         const Color(0xFFBA68C8), // Purple
//                                         const Color(0xFF4FC3F7), // Light Blue
//                                       ];

//                                       final List<Color> cardBorderColors = [
//                                         const Color(0xFF378981),
//                                         const Color(0xFFD88916),
//                                         const Color(0xFFB83763),
//                                         const Color(0xFF539456),
//                                         const Color(0xFF7B1FA2),
//                                         const Color(0xFF0288D1),
//                                       ];

//                                       Color currentMainColor = cardMainColors[
//                                           index % cardMainColors.length];
//                                       Color currentBorderColor =
//                                           cardBorderColors[
//                                               index % cardBorderColors.length];

//                                       return CategoryCard(
//                                         title: category.title,
//                                         imagePath: myCustomImage,
//                                         baseColor: currentMainColor,
//                                         borderColor: currentBorderColor,
//                                         onTap: () {
//                                           viewModel.selectCategory(category.id);
//                                           tapActionCallback(context, () {});
//                                           handleTapAction(context, () {});
//                                           Navigator.pushNamed(
//                                               context, AppRoutes.home);
//                                         },
//                                       );
//                                     },
//                                     childCount: allCategories.length,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final allCategories = viewModel.categories;

    return Scaffold(
      // backgroundColor: const Color(0xffFAF8F5),
      // Scaffold ka bottomNavigationBar ab empty rahega ya remove kar dein
      body: Stack(
        children: [
          // 1. Aapki Main Screen (Body)
          Positioned.fill(
            child: viewModel.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xffFFB03A))),
                  )
                : viewModel.error != null
                    ? Center(
                        child: Text(viewModel.error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16)))
                    : Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/bgg.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Yahan aapka baki ka code (SafeArea, CustomScrollView, etc.) waisa hi rahega
                        child: SafeArea(
                          child: allCategories.isEmpty
                              ? const Center(
                                  child: Text("No categories available"))
                              : CustomScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    // ── Coin counter badge ─────────────────────────────────────────
                                    SliverToBoxAdapter(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Consumer<HomeViewModel>(
                                          builder: (context, homeVM, _) {
                                            // Session check
                                            final session = Supabase.instance
                                                .client.auth.currentSession;
                                            final bool isLoggedIn =
                                                session != null;
                                            // final coins = homeVM.earnedCoins;
                                            final coins = homeVM.databaseCoins;

                                            return GestureDetector(
                                              onTap: () {
                                                if (!isLoggedIn) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              LoginScreen()));
                                                } else {
                                                  // Logged in hai, toh apna modal ya action yahan call karo
                                                  print(
                                                      "User logged in, coins: $coins");
                                                }
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 400),
                                                curve: Curves.easeOutBack,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 0),
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Color(0xFFFFD700),
                                                      Color(0xFFFF9100)
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                              0xFFFFD700)
                                                          .withOpacity(0.45),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),

                                                // duration: const Duration(
                                                //     milliseconds: 400),
                                                // Style waisa hi rakhein
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Logic: Agar logged in hai toh Coin icon, warna Person/Lock icon
                                                    Text(
                                                        isLoggedIn
                                                            ? '🪙'
                                                            : '👤',
                                                        style: const TextStyle(
                                                            fontSize: 20)),
                                                    const SizedBox(width: 4),

                                                    // Logic: Agar logged in hai toh coins count, warna 'Login' text
                                                    Text(
                                                      isLoggedIn
                                                          ? '$coins'
                                                          : 'Login',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: "Regular",
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Consumer<HomeViewModel>(
                                        //   builder: (context, homeVM, _) {
                                        //     final coins = homeVM.earnedCoins;

                                        //     // GestureDetector wrap kiya tap handle karne ke liye
                                        //     return GestureDetector(
                                        //       onTap: () {
                                        //         // Supabase check
                                        //         final session = Supabase
                                        //             .instance
                                        //             .client
                                        //             .auth
                                        //             .currentSession;

                                        //         if (session == null) {
                                        //           // Agar login nahi hai, login screen par bhejo
                                        //           Navigator.pushNamed(context,
                                        //               '/login'); // Apne route ka naam check kar lena
                                        //         } else {
                                        //           // Agar logged in hai, toh coins show karo (ya jo bhi action chahiye)
                                        //           print(
                                        //               "User logged in, coins: $coins");
                                        //           // Yahan apna showModal ya jo bhi logic hai wo call karo
                                        //         }
                                        //       },
                                        //       child: AnimatedContainer(
                                        //         // Tumhara baaki code waisa hi rahega...
                                        //         duration: const Duration(
                                        //             milliseconds: 400),
                                        //         // ... baki properties yahan ...
                                        //         child: Row(
                                        //           mainAxisSize:
                                        //               MainAxisSize.min,
                                        //           children: [
                                        //             const Text('🪙',
                                        //                 style: TextStyle(
                                        //                     fontSize: 16)),
                                        //             const SizedBox(width: 4),
                                        //             Text(
                                        //               '$coins',
                                        //               style: const TextStyle(
                                        //                   fontSize: 16,
                                        //                   color: Colors.white,
                                        //                   fontWeight:
                                        //                       FontWeight.w700),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     );
                                        //   },
                                        // ),

                                        // Consumer<HomeViewModel>(
                                        //   builder: (context, homeVM, _) {
                                        //     final coins = homeVM.earnedCoins;
                                        //     return AnimatedContainer(
                                        //       // width: 200,
                                        //       duration: const Duration(
                                        //           milliseconds: 400),
                                        //       curve: Curves.easeOutBack,
                                        //       padding:
                                        //           const EdgeInsets.symmetric(
                                        //               horizontal: 12,
                                        //               vertical: 6),
                                        //       margin:
                                        //           const EdgeInsets.symmetric(
                                        //               horizontal: 12,
                                        //               vertical: 0),
                                        //       decoration: BoxDecoration(
                                        //         gradient: const LinearGradient(
                                        //           colors: [
                                        //             Color(0xFFFFD700),
                                        //             Color(0xFFFF9100)
                                        //           ],
                                        //           begin: Alignment.topLeft,
                                        //           end: Alignment.bottomRight,
                                        //         ),
                                        //         borderRadius:
                                        //             BorderRadius.circular(25),
                                        //         boxShadow: [
                                        //           BoxShadow(
                                        //             color:
                                        //                 const Color(0xFFFFD700)
                                        //                     .withOpacity(0.45),
                                        //             blurRadius: 8,
                                        //             offset: const Offset(0, 3),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //       child: Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         children: [
                                        //           const Text('🪙',
                                        //               style: TextStyle(
                                        //                   fontSize: 16)),
                                        //           const SizedBox(width: 4),
                                        //           Text(
                                        //             '$coins',
                                        //             style: TextStyle(
                                        //               fontSize: 25,
                                        //               fontFamily: "Regular",
                                        //               fontWeight:
                                        //                   FontWeight.w700,
                                        //               color: Colors.white,
                                        //               shadows: const [
                                        //                 Shadow(
                                        //                     color:
                                        //                         Colors.black26,
                                        //                     blurRadius: 3,
                                        //                     offset:
                                        //                         Offset(0, 1)),
                                        //               ],
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     );
                                        //   },
                                        // ),
                                      ),
                                    ),

                                    SliverToBoxAdapter(
                                      child: Image.asset(
                                          "assets/images/logo.png",
                                          height: 250),
                                    ),

                                    // SliverPadding(
                                    //   padding: const EdgeInsets.only(
                                    //       left: 16,
                                    //       right: 16,
                                    //       bottom:
                                    //           100), // Bottom padding zaroori hai taake niche ka content chhupe na
                                    //   sliver: SliverGrid(
                                    //     // Aapka grid delegate aur builder waisa hi rahega...
                                    //     gridDelegate:
                                    //         const SliverGridDelegateWithFixedCrossAxisCount(
                                    //       crossAxisCount: 2,
                                    //       crossAxisSpacing: 16,
                                    //       mainAxisSpacing: 16,
                                    //       childAspectRatio: 0.85,
                                    //     ),
                                    //     delegate: SliverChildBuilderDelegate(
                                    //       (context, index) {
                                    //         /* Aapka logic yahan waisa hi rahega */
                                    //         return Container(); // placeholder
                                    //       },
                                    //       childCount: allCategories.length,
                                    //     ),
                                    //   ),
                                    // ),
                                    SliverPadding(
                                      padding: const EdgeInsets.all(10.0),
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
                                            final category =
                                                allCategories[index];
                                            final categoryTitle =
                                                category.title.toLowerCase();

                                            // --- Dynamic Image Logic ---
                                            String myCustomImage =
                                                'assets/images/dog.webp';
                                            if (categoryTitle == 'fruits') {
                                              myCustomImage =
                                                  'assets/images/apples.png';
                                            } else if (categoryTitle ==
                                                'animals') {
                                              myCustomImage =
                                                  'assets/images/dog.webp';
                                            } else if (categoryTitle ==
                                                'vegetables') {
                                              myCustomImage =
                                                  'assets/images/vegetable.png';
                                            } else if (categoryTitle ==
                                                    'wild animals' ||
                                                categoryTitle ==
                                                    'wild_animals') {
                                              myCustomImage =
                                                  'assets/images/animalss.png';
                                            } else if (categoryTitle ==
                                                'colors') {
                                              myCustomImage =
                                                  'assets/images/color_activity_icon.webp';
                                            } else if (categoryTitle ==
                                                'alphabets') {
                                              myCustomImage =
                                                  'assets/images/alphabets.png';
                                            } else if (categoryTitle ==
                                                'drawing') {
                                              myCustomImage =
                                                  'assets/images/pen.png';
                                            }

                                            // --- Dynamic Colors Logic ---
                                            final List<Color> cardMainColors = [
                                              const Color(0xFF4DB6AC), // Teal
                                              const Color(0xFFFFB74D), // Orange
                                              const Color(0xFFF06292), // Pink
                                              const Color(0xFF81C784), // Green
                                              const Color(0xFFBA68C8), // Purple
                                              const Color(
                                                  0xFF4FC3F7), // Light Blue
                                            ];

                                            final List<Color> cardBorderColors =
                                                [
                                              const Color(0xFF378981),
                                              const Color(0xFFD88916),
                                              const Color(0xFFB83763),
                                              const Color(0xFF539456),
                                              const Color(0xFF7B1FA2),
                                              const Color(0xFF0288D1),
                                            ];

                                            Color currentMainColor =
                                                cardMainColors[index %
                                                    cardMainColors.length];
                                            Color currentBorderColor =
                                                cardBorderColors[index %
                                                    cardBorderColors.length];

                                            return CategoryCard(
                                              title: category.title,
                                              imagePath: myCustomImage,
                                              baseColor: currentMainColor,
                                              borderColor: currentBorderColor,
                                              onTap: () {
                                                viewModel.selectCategory(
                                                    category.id);
                                                tapActionCallback(
                                                    context, () {});
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
          ),

          // 2. Floating Bottom Bar (Stack ke andar Positioned)
          Positioned(
              bottom: 20, // Screen ke bottom se thoda upar
              left: 10,
              right: 10,
              child: CustomBar()

              //  Container(
              //   height: 70,
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(40),
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.15),
              //         blurRadius: 15,
              //         offset: const Offset(0, 5),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       // Aapke buttons wahi hain, bas ab ye Container ke andar hain
              //       AppBottomBar(
              //         child: Image.asset("assets/images/home.webp"),
              //         topColor: Colors.orangeAccent,
              //         bottomColor: Colors.orange,
              //         isSelected: selectedIndex == 0,
              //         onTap: () {
              //           handleTapAction(context, () {});
              //           setState(() => selectedIndex = 0);
              //         },
              //       ),
              //       AppBottomBar(
              //         child: Image.asset("assets/images/photo.png"),
              //         topColor: Colors.purpleAccent,
              //         bottomColor: Colors.purple,
              //         isSelected: selectedIndex == 1,
              //         onTap: () => setState(() => selectedIndex = 1),
              //       ),
              //       AppBottomBar(
              //         child: Image.asset("assets/images/setting.png"),
              //         topColor: Colors.blueAccent,
              //         bottomColor: Colors.blue,
              //         isSelected: selectedIndex == 2,
              //         onTap: () {
              //           handleTapAction(context, () {});
              //           setState(() => selectedIndex = 2);
              //           showDialog(
              //             context: context,
              //             builder: (_) =>
              //                 const Center(child: KidsSettingsDialog()),
              //           );
              //         },
              //       ),
              //     ],
              //   ),
              // ),

              ),
        ],
      ),
    );
  }
}
