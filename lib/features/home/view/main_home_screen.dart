import 'package:flutter/material.dart';
import 'package:play_craft_kids/core/constants/app_strings.dart';
import 'package:play_craft_kids/features/home/view/home_screen.dart';
import 'package:provider/provider.dart';

// Apne actual project paths ke mutabik in imports ko adjust kar lena:
import '../viewmodel/home_viewmodel.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ViewModel ko read aur listen kar rahe hain
    final viewModel = context.watch<HomeViewModel>();

    // Show all categories and use unique images for each
    final allCategories = viewModel.categories;
    return Scaffold(
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
                      image: AssetImage('assets/images/bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, right: 16.0),
                          child: Container(
                            padding: EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.pink.shade300,
                            ),
                            child: Center(
                              child: Text(
                                viewModel.content?.appTitle ??
                                    AppStrings.appTitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                        color: const Color.fromARGB(
                                            255, 222, 226, 233),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Expanded(
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
                              : GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(16.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        0.70, // Level card ratio follow kiya ha
                                  ),
                                  itemCount: allCategories.length,
                                  itemBuilder: (context, index) {
                                    final category = allCategories[index];
                                    final categoryTitle =
                                        category.title.toLowerCase();

                                    // --- 1. Image Paths (Uncomment and check names) ---
                                    String myCustomImage =
                                        'assets/images/default.png';

                                    if (categoryTitle == 'fruits') {
                                      myCustomImage =
                                          'assets/images/fruits.png'; // 🍎 level apple asset name
                                    } else if (categoryTitle == 'animals') {
                                      myCustomImage =
                                          'assets/images/animal.png'; // 🍌 level banana asset name
                                    } else if (categoryTitle == 'sports') {
                                      myCustomImage =
                                          'assets/images/sport.png'; // 🍊 level orange asset name
                                    } else if (categoryTitle == 'vehicles') {
                                      myCustomImage =
                                          'assets/images/vehicles.png'; // 🐱 level cat vector asset name
                                    }

                                    // --- 2. Vibrant Glossy Colors Logic (Level screen combinations) ---
                                    final List<Color> cardMainColors = [
                                      const Color(0xff3DA9FD), // fruits blue
                                      const Color(0xffFEBC12), // animals yellow
                                      const Color(
                                          0xffFEBD11), // sports yellow (orange image blend)
                                      const Color(0xff91EE59), // vehicles green
                                    ];

                                    final List<Color> cardBorderColors = [
                                      const Color(0xff1A78D0), // Darker Blue
                                      const Color(0xffCF8F02), // Darker Yellow
                                      const Color(
                                          0xffCFA201), // Darker Yellow (orange blend)
                                      const Color(0xff6ABE2A), // Darker Green
                                    ];

                                    final List<Color> cardShadowColors = [
                                      const Color(0xff0F477D), // blue shadow
                                      const Color(0xffA87401), // yellow shadow
                                      const Color(0xffA88401), // orange shadow
                                      const Color(0xff4F8F1A), // green shadow
                                    ];

                                    // Inner square color for image - matches image backdrop in example
                                    final List<Color> innerBoxColors = [
                                      const Color(0xffBDE1FF), // inner blue
                                      const Color(0xffFFF2AF), // inner yellow
                                      const Color(0xffFFEBBC), // inner peach
                                      const Color(0xffCBFAB8), // inner green
                                    ];

                                    Color currentMainColor = cardMainColors[
                                        index % cardMainColors.length];
                                    Color currentBorderColor = cardBorderColors[
                                        index % cardBorderColors.length];
                                    Color currentShadowColor = cardShadowColors[
                                        index % cardShadowColors.length];
                                    Color currentInnerColor = innerBoxColors[
                                        index % innerBoxColors.length];

                                    return LevelCard(
                                      title: category.title,
                                      imageAsset: myCustomImage,
                                      mainColor: currentMainColor,
                                      borderColor: currentBorderColor,
                                      innerColor: currentInnerColor,
                                      onTap: () {
                                        viewModel.selectCategory(category.id);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen(),
                                          ),
                                        );
                                      },
                                    );
                                    // _MainHomeLevelCard(
                                    //   title: category.title,
                                    //   imageAsset: myCustomImage,
                                    //   mainColor: currentMainColor,
                                    //   borderColor: currentBorderColor,
                                    //   innerColor: currentInnerColor,
                                    //   onTap: () {
                                    //     viewModel.selectCategory(category.id);
                                    //     Navigator.push(
                                    //       context,
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const HomeScreen(),
                                    //       ),
                                    //     );
                                    // });
                                  },
                                ),
                        )
                        // Expanded(
                        //     child: allCategories.isEmpty
                        //         ? const Center(
                        //             child: Text("No categories available"))
                        //         : GridView.builder(
                        //             physics: const BouncingScrollPhysics(),
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 16.0, vertical: 8.0),
                        //             gridDelegate:
                        //                 const SliverGridDelegateWithFixedCrossAxisCount(
                        //               crossAxisCount: 2,
                        //               crossAxisSpacing: 16,
                        //               mainAxisSpacing: 16,
                        //               childAspectRatio: 0.85,
                        //             ),
                        //             itemCount: allCategories.length,
                        //             itemBuilder: (context, index) {
                        //               final category = allCategories[index];

                        //               // 🌟 1. Yahan ham category ka title check kar ke apni marzi ki image set kar rahe hain:
                        //               final categoryTitle =
                        //                   category.title.toLowerCase();
                        //               String myCustomImage =
                        //                   'assets/images/default.png'; // Fallback image path

                        //               if (categoryTitle == 'fruits') {
                        //                 myCustomImage =
                        //                     'assets/images/fruits.png'; // Fruits ke liye apple path
                        //               } else if (categoryTitle == 'animals') {
                        //                 myCustomImage =
                        //                     'assets/images/animal.png'; // Animals ke liye cat path
                        //               } else if (categoryTitle == 'sports') {
                        //                 myCustomImage =
                        //                     'assets/images/sport.png'; // Sports ke liye football path
                        //               } else if (categoryTitle == 'vehicles') {
                        //                 myCustomImage =
                        //                     'assets/images/vehicles.png'; // Vehicles ke liye car path
                        //               }

                        //               // Card colors logic saaf rakha hai
                        //               final List<Color> cardColors = [
                        //                 const Color(0xffC2E3FF),
                        //                 const Color(0xffFFF2AF),
                        //                 const Color(0xffFFD1B3),
                        //                 const Color(0xffBFF3D4),
                        //               ];
                        //               Color currentCardColor =
                        //                   cardColors[index % cardColors.length];

                        //               return GestureDetector(
                        //                 onTap: () {
                        //                   viewModel.selectCategory(category.id);
                        //                   Navigator.push(
                        //                     context,
                        //                     MaterialPageRoute(
                        //                       builder: (context) =>
                        //                           const HomeScreen(),
                        //                     ),
                        //                   );
                        //                 },
                        //                 child: Container(
                        //                   decoration: BoxDecoration(
                        //                     color: currentCardColor,
                        //                     borderRadius:
                        //                         BorderRadius.circular(28),
                        //                     boxShadow: [
                        //                       BoxShadow(
                        //                         color: Colors.black
                        //                             .withOpacity(0.04),
                        //                         blurRadius: 12,
                        //                         offset: const Offset(0, 6),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                   padding: const EdgeInsets.all(16),
                        //                   child: Column(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.center,
                        //                     children: [
                        //                       // Category Title Text Component
                        //                       Text(
                        //                         category.title.toUpperCase(),
                        //                         style: const TextStyle(
                        //                           fontSize: 18,
                        //                           fontWeight: FontWeight.bold,
                        //                           color: Color(0xff3B3F58),
                        //                         ),
                        //                       ),
                        //                       const SizedBox(height: 12),

                        //                       // Image Box Setup
                        //                       Expanded(
                        //                         child: Container(
                        //                           decoration: BoxDecoration(
                        //                             image: DecorationImage(
                        //                               image: AssetImage(
                        //                                   myCustomImage),
                        //                               fit: BoxFit.cover,
                        //                               onError:
                        //                                   (error, stackTrace) {
                        //                                 // Agar image load nahi hoti, toh default palette icon dikhega
                        //                                 // return const Icon(
                        //                                 //     Icons.palette,
                        //                                 //     size: 50,
                        //                                 //     color: Colors.white);
                        //                               },
                        //                             ),
                        //                             color: Colors.white
                        //                                 .withOpacity(0.5),
                        //                             shape: BoxShape.circle,
                        //                           ),
                        //                           padding:
                        //                               const EdgeInsets.all(12),
                        //                           // 🌟 2. Yahan par hamari manually banyi hui 'myCustomImage' assign ho gayi hai:
                        //                           // child: Image.asset(
                        //                           //   myCustomImage,
                        //                           //   fit: BoxFit.contain,
                        //                           //   errorBuilder: (context,
                        //                           //       error, stackTrace) {
                        //                           //     // Agar di gayi spelling ya path galti se assets folder mein na ho, toh default palette icon dikhega
                        //                           //     return const Icon(
                        //                           //         Icons.palette,
                        //                           //         size: 50,
                        //                           //         color: Colors.white);
                        //                           //   },
                        //                           // ),
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               );
                        //             },
                        //           )
                        //     //  GridView.builder(
                        //     //     physics: const BouncingScrollPhysics(),
                        //     //     padding: const EdgeInsets.symmetric(
                        //     //         horizontal: 16.0, vertical: 8.0),
                        //     //     gridDelegate:
                        //     //         const SliverGridDelegateWithFixedCrossAxisCount(
                        //     //       crossAxisCount: 2,
                        //     //       crossAxisSpacing: 16,
                        //     //       mainAxisSpacing: 16,
                        //     //       childAspectRatio: 0.85,
                        //     //     ),
                        //     //     itemCount: allCategories.length,
                        //     //     itemBuilder: (context, index) {
                        //     //       final category = allCategories[index];
                        //     //       // Show unique image for each category
                        //     //       String? representativeImageAsset;
                        //     //       if (category.title.toLowerCase() ==
                        //     //           'fruits') {
                        //     //         final apple = category.levels.firstWhere(
                        //     //           (lvl) =>
                        //     //               lvl.title.toLowerCase() == 'apple',
                        //     //           orElse: () => category.levels.first,
                        //     //         );
                        //     //         representativeImageAsset =
                        //     //             apple.guideAsset;
                        //     //       } else if (category.title.toLowerCase() ==
                        //     //           'animals') {
                        //     //         final cat = category.levels.firstWhere(
                        //     //           (lvl) =>
                        //     //               lvl.title.toLowerCase() == 'cat',
                        //     //           orElse: () => category.levels.first,
                        //     //         );
                        //     //         representativeImageAsset = cat.guideAsset;
                        //     //       } else if (category.title.toLowerCase() ==
                        //     //           'sports') {
                        //     //         final football =
                        //     //             category.levels.firstWhere(
                        //     //           (lvl) =>
                        //     //               lvl.title.toLowerCase() ==
                        //     //               'football',
                        //     //           orElse: () => category.levels.first,
                        //     //         );
                        //     //         representativeImageAsset =
                        //     //             football.guideAsset;
                        //     //       } else if (category.title.toLowerCase() ==
                        //     //           'vehicles') {
                        //     //         final car = category.levels.firstWhere(
                        //     //           (lvl) =>
                        //     //               lvl.title.toLowerCase() == 'car',
                        //     //           orElse: () => category.levels.first,
                        //     //         );
                        //     //         representativeImageAsset = car.guideAsset;
                        //     //       }
                        //     //       final List<Color> cardColors = [
                        //     //         const Color(0xffC2E3FF),
                        //     //         const Color(0xffFFF2AF),
                        //     //         const Color(0xffFFD1B3),
                        //     //         const Color(0xffBFF3D4),
                        //     //       ];
                        //     //       Color currentCardColor =
                        //     //           cardColors[index % cardColors.length];
                        //     //       return GestureDetector(
                        //     //         onTap: () {
                        //     //           viewModel.selectCategory(category.id);
                        //     //           Navigator.push(
                        //     //             context,
                        //     //             MaterialPageRoute(
                        //     //               builder: (context) =>
                        //     //                   const HomeScreen(),
                        //     //             ),
                        //     //           );
                        //     //         },
                        //     //         child: Container(
                        //     //           decoration: BoxDecoration(
                        //     //             color: currentCardColor,
                        //     //             borderRadius:
                        //     //                 BorderRadius.circular(28),
                        //     //             boxShadow: [
                        //     //               BoxShadow(
                        //     //                 color: Colors.black
                        //     //                     .withOpacity(0.04),
                        //     //                 blurRadius: 12,
                        //     //                 offset: const Offset(0, 6),
                        //     //               ),
                        //     //             ],
                        //     //           ),
                        //     //           padding: const EdgeInsets.all(16),
                        //     //           child: Column(
                        //     //             mainAxisAlignment:
                        //     //                 MainAxisAlignment.center,
                        //     //             children: [
                        //     //               Text(
                        //     //                 category.title.toUpperCase(),
                        //     //                 style: const TextStyle(
                        //     //                   fontSize: 18,
                        //     //                   fontWeight: FontWeight.bold,
                        //     //                   color: Color(0xff3B3F58),
                        //     //                 ),
                        //     //               ),
                        //     //               const SizedBox(height: 12),
                        //     //               Expanded(
                        //     //                 child: Container(
                        //     //                   decoration: BoxDecoration(
                        //     //                     color: Colors.white.withOpacity(0.5),
                        //     //                     shape: BoxShape.circle,
                        //     //                   ),
                        //     //                   padding: const EdgeInsets.all(12),
                        //     //                   child: (representativeImageAsset != null && representativeImageAsset.isNotEmpty)
                        //     //                       ? Image.asset(
                        //     //                           representativeImageAsset,
                        //     //                           fit: BoxFit.contain,
                        //     //                           errorBuilder: (context, error, stackTrace) {
                        //     //                             return const Icon(Icons.palette, size: 50, color: Colors.white);
                        //     //                           },
                        //     //                         )
                        //     //                       : const Icon(Icons.palette, size: 50, color: Colors.white),
                        //     //                 ),
                        //     //               ),
                        //     //             ],
                        //     //           ),
                        //     //         ),
                        //     //       );
                        //     //     },
                        //     //   ),

                        //     ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 20.0, horizontal: 30.0),
                        //   child: Container(
                        //     width: double.infinity,
                        //     height: 56,
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(30),
                        //         border: Border.all(
                        //             color: const Color(0xffFFE6C7), width: 3),
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.orange.withOpacity(0.06),
                        //             blurRadius: 10,
                        //             offset: const Offset(0, 4),
                        //           )
                        //         ]),
                        //     child: const Center(
                        //       child: Text(
                        //         "START FREE DRAW",
                        //         style: TextStyle(
                        //           fontSize: 18,
                        //           fontWeight: FontWeight.bold,
                        //           color: Color(0xff3B3F58),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _MainHomeLevelCard extends StatelessWidget {
  const _MainHomeLevelCard({
    required this.title,
    required this.imageAsset,
    required this.mainColor,
    required this.borderColor,
    required this.innerColor,
    required this.onTap,
  });

  final String title;
  final String imageAsset;
  final Color mainColor;
  final Color borderColor;
  final Color innerColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: borderColor,
            width: 4.5,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: borderColor.withOpacity(0.2),
              width: 2.5,
            ),
          ),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: innerColor,
                        image: DecorationImage(
                          image: AssetImage(imageAsset),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: borderColor,
                          width: 3.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LevelCard extends StatefulWidget {
  const LevelCard({
    required this.title,
    required this.imageAsset,
    required this.mainColor,
    required this.borderColor,
    required this.innerColor,
    required this.onTap,
  });

  final String title;
  final String imageAsset;
  final Color mainColor;
  final Color borderColor;
  final Color innerColor;
  final VoidCallback onTap;

  @override
  State<LevelCard> createState() => LevelCardState();
}

class LevelCardState extends State<LevelCard> {
  bool _isPressed = false;

  void _updatePressed(bool value) {
    if (_isPressed == value) return;

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(30);

    final glowColor = Color.lerp(
      widget.mainColor,
      Colors.white,
      0.18,
    )!;

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1,
      duration: Duration(milliseconds: _isPressed ? 100 : 320),
      curve: _isPressed ? Curves.easeOut : Curves.elasticOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _updatePressed(true),
        onTapUp: (_) => _updatePressed(false),
        onTapCancel: () => _updatePressed(false),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: widget.borderColor.withOpacity(0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.mainColor.withOpacity(0.95),
                  widget.borderColor,
                ],
              ),
              border: Border.all(
                color: widget.borderColor,
                width: 3.4,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.mainColor,
                      widget.mainColor.withOpacity(0.88),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 0.16, 0.42, 1],
                            colors: [
                              Colors.white.withOpacity(0.38),
                              Colors.white.withOpacity(0.16),
                              Colors.white.withOpacity(0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   left: 12,
                    //   right: 12,
                    //   top: 10,
                    //   height: 40,
                    //   child: IgnorePointer(
                    //     child: DecoratedBox(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(22),
                    //         gradient: LinearGradient(
                    //           begin: Alignment.topCenter,
                    //           end: Alignment.bottomCenter,
                    //           colors: [
                    //             Colors.white.withOpacity(0.34),
                    //             Colors.white.withOpacity(0.06),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MainHomeCardFramePainter(
                          radius: 26,
                          edgeColor: widget.borderColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 34,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  widget.title.toUpperCase(),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    color: Colors.black,
                                  ).copyWith(
                                    shadows: [
                                      Shadow(
                                        color: glowColor.withOpacity(
                                          _isPressed ? 0.95 : 0.82,
                                        ),
                                        blurRadius: _isPressed ? 12 : 9,
                                      ),
                                      Shadow(
                                        color: Colors.black.withOpacity(0.22),
                                        offset: const Offset(0, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.26),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.58),
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.18),
                                      blurRadius: 8,
                                      offset: const Offset(0, -1),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: widget.innerColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: widget.borderColor,
                                      width: 3,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(widget.imageAsset),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainHomeCardFramePainter extends CustomPainter {
  const _MainHomeCardFramePainter({
    required this.radius,
    required this.edgeColor,
  });

  final double radius;
  final Color edgeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius),
    );

    final innerHighlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withOpacity(0.72);

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = edgeColor.withOpacity(0.16);

    canvas.drawRRect(
      rrect.deflate(1.2),
      innerHighlightPaint,
    );

    canvas.drawRRect(
      rrect.deflate(3.0),
      innerShadowPaint,
    );

    final bottomShadeRect = Rect.fromLTWH(
      6,
      size.height * 0.56,
      size.width - 12,
      size.height * 0.28,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bottomShadeRect,
        Radius.circular(radius - 8),
      ),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            edgeColor.withOpacity(0.08),
          ],
        ).createShader(bottomShadeRect),
    );
  }

  @override
  bool shouldRepaint(covariant _MainHomeCardFramePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.edgeColor != edgeColor;
  }
}
