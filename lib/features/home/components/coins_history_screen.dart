import 'package:flutter/material.dart';

import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/home/components/coins_history.dart';

import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';

import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class CoinHistoryScreen extends StatefulWidget {
  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Screen khulte hi data fetch karein
  //   Provider.of<HomeViewModel>(context, listen: false).fetchCoinHistory();
  //   // Provider.of<HomeViewModel>(context, listen: false).fetchCoinHistory();
  // }

  @override
  void initState() {
    super.initState();
    // Screen open hote hi fetch chalayein
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).fetchCoinHistory();
    });
  }

  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    final bool isLoggedIn = session != null;

    if (!isLoggedIn) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 140,
                        // width: double.infinity,
                        child: Stack(
                          children: [
                            ClipPath(
                              clipper: AppBarClipper(),
                              child: Container(
                                height: 140,
                                color: const Color(0xff3b9499),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SidebarIcon(
                                        icon: Icons.arrow_back_rounded,
                                        assetName:
                                            'assets/images/pop-button.png',
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),

                                    // Title
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Shadow Layer
                                              Transform.translate(
                                                offset: const Offset(6, 6),
                                                child: Text(
                                                  "Coins History",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 50,
                                                    fontFamily: "Regular",
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.black
                                                        .withOpacity(0.35),
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),

                                              // Pink 3D Layer
                                              Transform.translate(
                                                offset: const Offset(3, 3),
                                                child: Text(
                                                  "Coins History",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 50,
                                                    fontFamily: "Regular",
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFFFF4FA3),
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),

                                              // Main White Text
                                              Text(
                                                "Coins History",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 50,
                                                  fontFamily: "Regular",
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 60),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SidebarIcon(
                    //   icon: Icons.arrow_back_rounded,
                    //   assetName: 'assets/images/pop-button.png',
                    //   onPressed: () {
                    //     Navigator.pop(context);
                    //   },
                    // ),

                    // // _HistoryIconButton(
                    // //   icon: Icons.arrow_back_rounded,
                    // //   onTap: () => Navigator.pop(context),
                    // // ),
                    // const SizedBox(width: 14),
                    // Expanded(
                    //   child: Text(
                    //     'Drawing History',
                    //     style: TextStyle(
                    //       fontSize: 28,
                    //       fontWeight: FontWeight.w700,
                    //       color: const Color(0xFF1F2A44),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Login section ko replacement
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  const Text(
                    "Oops! Sign in to see your coins",
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Regular",
                        fontWeight: FontWeight.bold,
                        color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3b9499),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LoginScreen())),
                      child: const Text("Login Now",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Regular",
                              color: Colors.white)),
                    ),
                  ),
                ],
              )

              // Center(
              //   child: Text(
              //     "Login to view coins history",
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //         fontFamily: "Regular",
              //         fontWeight: FontWeight.w600,
              //         fontSize: 20),
              //   ),
              // ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () => Navigator.push(
              //       context, MaterialPageRoute(builder: (_) => LoginScreen())),
              //   child: Text(
              //     "Login",
              //     style: TextStyle(
              //         fontFamily: "Regular",
              //         fontWeight: FontWeight.w600,
              //         fontSize: 16),
              //   ),
              // ),
            ],
          ),
        ),
      );
    }

    // Agar logged in hai, toh ListView show karo

    return Scaffold(
      // appBar: AppBar(title: Text("Coins History")),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 140,
                      // width: double.infinity,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: AppBarClipper(),
                            child: Container(
                              height: 140,
                              color: const Color(0xff3b9499),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SidebarIcon(
                                      icon: Icons.arrow_back_rounded,
                                      assetName: 'assets/images/pop-button.png',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),

                                  // Title
                                  Expanded(
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Shadow Layer
                                            Transform.translate(
                                              offset: const Offset(6, 6),
                                              child: Text(
                                                "Coins History",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 50,
                                                  fontFamily: "Regular",
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black
                                                      .withOpacity(0.35),
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),

                                            // Pink 3D Layer
                                            Transform.translate(
                                              offset: const Offset(3, 3),
                                              child: Text(
                                                "Coins History",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 50,
                                                  fontFamily: "Regular",
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFFFF4FA3),
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),

                                            // Main White Text
                                            Text(
                                              "Coins History",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 50,
                                                fontFamily: "Regular",
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 60),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SidebarIcon(
                  //   icon: Icons.arrow_back_rounded,
                  //   assetName: 'assets/images/pop-button.png',
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),

                  // // _HistoryIconButton(
                  // //   icon: Icons.arrow_back_rounded,
                  // //   onTap: () => Navigator.pop(context),
                  // // ),
                  // const SizedBox(width: 14),
                  // Expanded(
                  //   child: Text(
                  //     'Drawing History',
                  //     style: TextStyle(
                  //       fontSize: 28,
                  //       fontWeight: FontWeight.w700,
                  //       color: const Color(0xFF1F2A44),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            Consumer<HomeViewModel>(
              builder: (context, homeVM, _) {
                final historyList = homeVM.coinHistoryList;

                if (historyList.isEmpty) {
                  return const Center(
                      child: Text(
                    "No History Available",
                    style: const TextStyle(
                        fontFamily: "Regular",
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ));
                }

                return Expanded(
                  child: Column(
                    children: [
                      // Total coins summary bar
                      Consumer<HomeViewModel>(
                        builder: (context, hm, _) => Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Coins',
                                  style: TextStyle(
                                      fontFamily: "Regular",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: Colors.white)),
                              Text('🪙 ${hm.databaseCoins}',
                                  style: const TextStyle(
                                      fontFamily: "Regular",
                                      fontWeight: FontWeight.w900,
                                      fontSize: 22,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final item = historyList[index];

                            // Transaction type ke hisab se icon/color
                            IconData icon;
                            Color iconColor;
                            Color bgColor;
                            if (item.description.contains('Welcome')) {
                              icon = Icons.celebration;
                              iconColor = Colors.orange;
                              bgColor = Colors.orange.withOpacity(0.15);
                            } else if (item.description.contains('Daily') ||
                                item.description.contains('Bonus')) {
                              icon = Icons.calendar_today_rounded;
                              iconColor = Colors.purple;
                              bgColor = Colors.purple.withOpacity(0.1);
                            } else if (item.description.contains('Level')) {
                              icon = Icons.star_rounded;
                              iconColor = Colors.green;
                              bgColor = Colors.green.withOpacity(0.1);
                            } else {
                              icon = Icons.monetization_on;
                              iconColor = Colors.amber;
                              bgColor = Colors.amber.withOpacity(0.1);
                            }

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                leading: CircleAvatar(
                                  backgroundColor: bgColor,
                                  child: Icon(icon, color: iconColor),
                                ),
                                title: Text(
                                  item.description,
                                  style: const TextStyle(
                                      fontFamily: "Regular",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "${item.date.day}/${item.date.month}/${item.date.year}",
                                  style: const TextStyle(
                                      fontFamily: "Regular",
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                                trailing: Text(
                                  "+${item.amount} 🪙",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Regular",
                                    fontSize: 18,
                                    color: iconColor,
                                  ),
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
            )

            // Consumer<HomeViewModel>(
            //   builder: (context, homeVM, _) {
            //     final historyList = homeVM.coinHistoryList;

            //     if (historyList.isEmpty) {
            //       return Center(child: Text("No History Available"));
            //     }

            //     return Expanded(
            //       // Yahan Expanded lagana zaroori hai
            //       child: ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: historyList.length,
            //         itemBuilder: (context, index) {
            //           final item =
            //               historyList[index]; // Ab ye 'CoinHistory' object hai

            //           return ListTile(
            //             leading: Icon(Icons.monetization_on,
            //                 color: Colors.amber, size: 30),
            //             title: Text(
            //               item.description,
            //               style: TextStyle(
            //                   fontFamily: "Regular",
            //                   fontWeight: FontWeight.w600,
            //                   fontSize: 16),
            //             ),
            //             trailing: Text(
            //               "+${item.amount}",
            //               style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontFamily: "Regular",
            //                   fontSize: 18),
            //             ),
            //           );
            //         },
            //       ),
            //     );
            //   },
            // )

            //   Consumer<HomeViewModel>(
            //     builder: (context, homeVM, _) {
            //       final historyList =
            //           homeVM.coinHistoryList; // Apne ViewModel se data lein

            //       return ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: historyList.length,
            //         itemBuilder: (context, index) {
            //           final item =
            //               historyList[index]; // Yeh ab 'CoinHistory' type ka hai

            //           return ListTile(
            //             leading: Icon(Icons.monetization_on,
            //                 color: Colors.amber, size: 30),
            //             title: Text(item.description,
            //                 style: TextStyle(
            //                     fontFamily: "Regular",
            //                     fontWeight: FontWeight.w600,
            //                     fontSize: 16)),
            //             trailing: Text("+${item.amount}",
            //                 style: TextStyle(
            //                     fontWeight: FontWeight.bold,
            //                     fontFamily: "Regular",
            //                     fontSize: 18)), // Ab yahan sahi value aayegi
            //           );
            //         },
            //       );
            //       // ListView.builder(
            //       //   shrinkWrap: true, // Overflow fix karne ke liye
            //       //   physics:
            //       //       BouncingScrollPhysics(), // Scroll smooth karne ke liye
            //       //   itemCount: historyList.length,
            //       //   itemBuilder: (context, index) {
            //       //     // Yahan type cast ki zaroorat nahi hai agar aap list mein objects store kar rahi hain
            //       //     final CoinHistory item = historyList[index];

            //       //     return ListTile(
            //       //       leading: Icon(Icons.monetization_on,
            //       //           color: Colors.amber, size: 30),
            //       //       title: Text(item.description,
            //       //           style: TextStyle(
            //       //               fontFamily: "Regular",
            //       //               fontWeight: FontWeight.w600,
            //       //               fontSize: 16)),
            //       //       trailing: Text("+${item.amount}",
            //       //           style: TextStyle(
            //       //               fontWeight: FontWeight.bold,
            //       //               fontFamily: "Regular",
            //       //               fontSize: 18)),
            //       //     );
            //       //   },
            //       // );
            //       // //  ListView.builder(
            //       //   shrinkWrap: true,
            //       //   itemCount: historyList.length,
            //       //   itemBuilder: (context, index) {
            //       //     // Ye line important hai: item ab ek Map hai
            //       //     final Map<String, dynamic> item =
            //       //         historyList[index] as Map<String, dynamic>;

            //       //     return ListTile(
            //       //       leading: Icon(Icons.monetization_on,
            //       //           color: Colors.amber, size: 30),
            //       //       title: Text(
            //       //         item['description'] ??
            //       //             "No Description", // Map se string uthayein
            //       //         style: TextStyle(
            //       //             fontFamily: "Regular",
            //       //             fontWeight: FontWeight.w600,
            //       //             fontSize: 16),
            //       //       ),
            //       //       trailing: Text(
            //       //         "+${item['amount'] ?? 0}", // Map se amount uthayein
            //       //         style: TextStyle(
            //       //             fontWeight: FontWeight.bold,
            //       //             fontFamily: "Regular",
            //       //             fontSize: 18),
            //       //       ),
            //       //     );
            //       //   },
            //       // );
            //       // ListView.builder(
            //       //   shrinkWrap: true,
            //       //   itemCount: historyList.length,
            //       //   itemBuilder: (context, index) {
            //       //     final item = historyList[index];

            //       //     return ListTile(
            //       //       leading: Icon(
            //       //         Icons.monetization_on,
            //       //         color: Colors.amber,
            //       //         size: 30,
            //       //       ),

            //       //       title: Text(
            //       //         item.description,
            //       //         style: TextStyle(
            //       //             fontFamily: "Regular",
            //       //             fontWeight: FontWeight.w600,
            //       //             fontSize: 16),
            //       //       ), // "Level 1", "Bonus"

            //       //       trailing: Text("+${item.amount}",
            //       //           style: TextStyle(
            //       //               fontWeight: FontWeight.bold,
            //       //               fontFamily: "Regular",
            //       //               fontSize: 18)),
            //       //     );
            //       //   },
            //       // );
            //     },
            //   ),
          ],
        ),
      ),
    );
  }
}
