
import 'package:asmr_coloring_app/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Apne actual project paths ke mutabik in imports ko adjust kar lena:
import '../viewmodel/home_viewmodel.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ViewModel ko read aur listen kar rahe hain
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: const Color(
          0xffFAF8F5), // Light warm cream background matching UI image
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
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage('assets/images/bg.png'),
                      fit: BoxFit.cover,
                      // colorFilter: ColorFilter.mode(
                      //   Colors.white.withOpacity(0.6), // Light overlay for better contrast
                      //   BlendMode.dstATop,
                      // ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // 1. Top Header Area (Title & Status Panel)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, left: 16.0, right: 16.0),
                          child: Center(
                            child: Text(
                              viewModel.content?.appTitle ?? 'MAGIC KIDS COLOR',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3B3F58),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. Dynamic Categories Grid Display
                        Expanded(
                          child: viewModel.categories
                                  .isEmpty // Assuming your viewModel has a categories list
                              ? const Center(
                                  child: Text("No categories available"),
                                )
                              : GridView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        2, // 2 items per row matching your target design
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        0.85, // Adjust vertical stretch of card
                                  ),
                                  itemCount: viewModel.categories.length,
                                  itemBuilder: (context, index) {
                                    final category =
                                        viewModel.categories[index];

                                    // Yeh colors aap dynamic background UI ke liye use kar sakte hain
                                    final List<Color> cardColors = [
                                      const Color(0xffC2E3FF), // Light Blue
                                      const Color(0xffFFF2AF), // Light Yellow
                                      const Color(0xffFFD1B3), // Light Orange
                                      const Color(0xffBFF3D4), // Light Green
                                    ];
                                    Color currentCardColor =
                                        cardColors[index % cardColors.length];

                                    return GestureDetector(
                                      onTap: () {
                                        // 🌟 CATEGORY CLICK: Yahan se aap screen pop karke home screen par ja sakte hain
                                        // Ya fir desired category data pass karke navigate kar sakte hain.

                                        // viewModel.selectCategory(category); // Agar category store karni ho
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const HomeScreen()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: currentCardColor,
                                          borderRadius:
                                              BorderRadius.circular(28),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Category Name / Title
                                            Text(
                                              category.title.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff3B3F58),
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Category Icon Placeholder / Image
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(12),
                                                // child: category.imageUrl != null
                                                //     ? Image.network(
                                                //         category.imageUrl!,
                                                //         fit: BoxFit.contain)
                                                //     : const Icon(Icons.palette,
                                                //         size: 50,
                                                //         color: Colors.white),
                                             
                                             
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),

                        // 3. Bottom Free Draw Button (Optional: Design complete karne ke liye)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 30.0),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: const Color(0xffFFE6C7), width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]),
                            child: const Center(
                              child: Text(
                                "START FREE DRAW",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff3B3F58),
                                ),
                              ),
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
