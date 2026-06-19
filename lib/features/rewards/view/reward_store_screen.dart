import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/rewards/viewmodel/reward_viewmodel.dart';
import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repository/reward_store_repository.dart'; // Apna repository import karein

class RewardStoreScreen extends StatefulWidget {
  const RewardStoreScreen({super.key});

  @override
  State<RewardStoreScreen> createState() => _RewardStoreScreenState();
}

class _RewardStoreScreenState extends State<RewardStoreScreen> {
  final _supabase = Supabase.instance.client;
  // late ConfettiController _confettiController;
  // Class ke andar variable define karte waqt hi initialize kar dein
  // late final ConfettiController _confettiController;
  late ConfettiController _confettiController;
  // Login status check karne ke liye
  final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    // 3. Dispose karna na bhulein
    _confettiController.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   // Class ke andar variable define karte waqt hi initialize kar dein
  //   final ConfettiController _confettiController =
  //       ConfettiController(duration: const Duration(seconds: 2));
  // }

  // @override
  // void dispose() {
  //   _confettiController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/reward.webp"),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
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
                                                      "Reward Store",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 50,
                                                        fontFamily: "Regular",
                                                        fontWeight:
                                                            FontWeight.w900,
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
                                                      "Reward Store",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontSize: 50,
                                                        fontFamily: "Regular",
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            Color(0xFFFF4FA3),
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),

                                                  // Main White Text
                                                  Text(
                                                    "Reward Store",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 50,
                                                      fontFamily: "Regular",
                                                      fontWeight:
                                                          FontWeight.w900,
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
                      ],
                    ),
                  ),

                  // Login section ko replacement
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/rewards.webp',
                        scale: 0.8,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 20),
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

                      // ... existing code ...

                      // SizedBox(
                      //   width: 200,
                      //   height: 50,
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       // updated background color to match the original image
                      //       backgroundColor: const Color(
                      //           0xff3b9499), // exactly as in image_6.png
                      //       elevation:
                      //           5, // optional: adds a light shadow like the original
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(30)),
                      //     ),
                      //     onPressed: () => Navigator.push(context,
                      //         MaterialPageRoute(builder: (_) => LoginScreen())),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Text(
                      //           "Login Now!", // Text updated to include '!' like image_7.png
                      //           style: TextStyle(
                      //               fontSize: 18,
                      //               fontFamily:
                      //                   "Regular", // ensures "Regular" font is used
                      //               color: Colors.white),
                      //         ),
                      //         // adding the coins icon to complete the look
                      //         SizedBox(width: 8), // spacing between text and icon
                      //         // for icons, use an existing pack or a custom one
                      //         Icon(Icons.monetization_on,
                      //             color: Colors
                      //                 .amber[600]), // gold colored coin icon
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // ... rest of your code ...

                      // const SizedBox(height: 10),
                      // Image.asset(
                      //   height: 100,
                      //   'assets/images/coin.webp',
                      //   scale: 0.8,
                      //   fit: BoxFit.contain,
                      // ),

                      // const Text("Get 50 coins when you log in! ",
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 16,
                      //         fontFamily: "Regular",
                      //         color: Colors.black54)),
                      // Text('🪙🪙🪙🪙',
                      //     style: const TextStyle(
                      //         fontFamily: "Regular",
                      //         fontWeight: FontWeight.bold,
                      //         fontSize: 22,
                      //         color: Colors.white)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Agar login hai, toh GridView dikhao
    return Scaffold(
      backgroundColor: Colors.transparent,
      // appBar: AppBar(title: const Text("Reward Store")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/reward.webp"), // Replace with your image path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.3),
              BlendMode.lighten,
            ), // Adjust the fit to your liking
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
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
                                                  "Reward Store",
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
                                                  "Reward Store",
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
                                                "Reward Store",
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
                  ],
                ),
              ),
              FutureBuilder(
                future: RewardStoreRepository().getRewards(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return const Center(
                        child: Text("Table khali hai ya is_active false hai"));
                  }

                  final rewards = snapshot.data as List;

                  // Yahan hum HomeViewModel se current coins le rahe hain
                  final userCoins = context.watch<HomeViewModel>().userCoins;

                  return GridView.builder(
                    shrinkWrap: true, // Zaroori hai
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.66, crossAxisCount: 2),
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];

                      // Logic: Kya user ke paas kaafi coins hain?
                      final bool canAfford = userCoins >= reward.requiredCoins;

                      return Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          // Locked hone par color halka (grey) ho jayega
                          color:
                              canAfford ? Colors.white : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: canAfford
                                  ? const Color(0xff6EC6D0)
                                  : Color(0xff6EC6D0),
                              width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3, right: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  reward.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Regular",
                                    fontWeight: FontWeight.bold,
                                    // Locked hone par text ka color grey
                                    color: canAfford
                                        ? const Color(0xff3b9499)
                                        : Colors.grey,
                                  ),
                                ),
                              ),

// Icon ki jagah ye block use karein
                              reward.imageUrl != null &&
                                      reward.imageUrl.isNotEmpty
                                  ? Container(
                                      height:
                                          80, // Apni marzi se size adjust karein
                                      width: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          // Agar locked hai toh image ko thoda dim/greyish dikhane ke liye
                                          colorFilter: canAfford
                                              ? null
                                              : ColorFilter.mode(Colors.grey,
                                                  BlendMode.saturation),
                                          image: NetworkImage(reward.imageUrl),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.palette,
                                      size: 60,
                                      color: canAfford
                                          ? Colors.orange
                                          : Colors.grey.shade400,
                                    ),
                              Text(
                                "${reward.requiredCoins} Coins",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: canAfford
                                      ? const Color(0xff3b9499)
                                      : Colors.redAccent,
                                ),
                              ),

                              // "Collect!" Button

                              GestureDetector(
                                onTap: canAfford
                                    ? () {
                                        // 1. Confetti start karein
                                        // _confettiController.play();
                                        _confettiController.play();

                                        // 2. Dialog open karein
                                        showDialog(
                                          context: context,
                                          barrierDismissible:
                                              false, // User bahar click karke band na kar sake
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                // Pop-up Card
                                                Container(
                                                  width: 280,
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xff6EC6D0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xff3b9499),
                                                        width: 5),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Text("SUCCESS!",
                                                          style: TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .white)),
                                                      const SizedBox(
                                                          height: 15),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                        child: Image.network(
                                                            reward.imageUrl,
                                                            height: 120,
                                                            width: 120,
                                                            fit:
                                                                BoxFit.contain),
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      Text(
                                                          "Aapne ${reward.title} claim kar liya hai!",
                                                          textAlign: TextAlign
                                                              .center,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      16)),
                                                      const SizedBox(
                                                          height: 15),
                                                      // OK Button
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          TextButton(
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              foregroundColor:
                                                                  Colors.black,
                                                            ),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    ctx),
                                                            child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              // Coins tab deduct honge jab OK dabayenge
                                                              await context
                                                                  .read<
                                                                      RewardViewModel>()
                                                                  .collectReward(
                                                                      reward);
                                                              if (ctx.mounted)
                                                                Navigator.pop(
                                                                    ctx);
                                                            },
                                                            child: const Text(
                                                                "OK"),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Confetti Widget (Stack mein sabse upar)
                                                ConfettiWidget(
                                                  confettiController:
                                                      _confettiController,
                                                  blastDirectionality:
                                                      BlastDirectionality
                                                          .explosive,
                                                  shouldLoop: false,
                                                  colors: const [
                                                    Colors.green,
                                                    Colors.blue,
                                                    Colors.pink,
                                                    Colors.orange,
                                                    Colors.purple
                                                  ],
                                                ),

                                                // Close button
                                                Positioned(
                                                  top: -10,
                                                  right: -10,
                                                  child: StickerIconButton(
                                                    icon: Icons.close,
                                                    assetName:
                                                        'assets/images/close.png',
                                                    size: 48,
                                                    backgroundColor:
                                                        Colors.white,
                                                    iconColor: Colors.red,
                                                    onPressed: () {
                                                      // Yahan hum check kar rahe hain ke kya dialog abhi bhi open (mounted) hai
                                                      if (ctx.mounted) {
                                                        Navigator.of(ctx)
                                                            .pop(); // Navigator.of(ctx).pop() zyada safer hai
                                                      }
                                                    },
                                                  ),
                                                  // StickerIconButton(
                                                  //   icon: Icons.close,
                                                  //   assetName:
                                                  //       'assets/images/close.png',
                                                  //   size: 48,
                                                  //   backgroundColor:
                                                  //       Colors.white,
                                                  //   iconColor: Colors.red,
                                                  //   onPressed: () =>
                                                  //       Navigator.pop(ctx),
                                                  // ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Container(
                                  height: 40,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: canAfford
                                        ? const Color(0xff3b9499)
                                        : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      canAfford ? "Collect!" : "Locked",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
//                               GestureDetector(
//                                 onTap: canAfford
//                                     ? () async {
//                                         // ViewModel ka function call karein
//                                         await context
//                                             .read<RewardViewModel>()
//                                             .collectReward(reward);

//                                         // Optional: User ko message dikhayein

// // 1. Controller banayein (iske liye StatefulWidget zaroori hai)
//                                         final _confettiController =
//                                             ConfettiController(
//                                                 duration:
//                                                     const Duration(seconds: 2));

// // 2. Dialog ke andar ye logic use karein
//                                         showDialog(
//                                           context: context,
//                                           builder: (ctx) {
//                                             _confettiController
//                                                 .play(); // Dialog khulte hi boom!
//                                             return Dialog(
//                                               backgroundColor:
//                                                   Colors.transparent,
//                                               child: Stack(
//                                                 alignment: Alignment.center,
//                                                 children: [
//                                                   // Yahan aapka pehle wala design wala Container...

//                                                   // Confetti Animation Layer (Sabse upar)
//                                                   ConfettiWidget(
//                                                     confettiController:
//                                                         _confettiController,
//                                                     blastDirectionality:
//                                                         BlastDirectionality
//                                                             .explosive, // Chaaro taraf phatega
//                                                     shouldLoop: false,
//                                                     colors: const [
//                                                       Colors.green,
//                                                       Colors.blue,
//                                                       Colors.pink,
//                                                       Colors.orange,
//                                                       Colors.purple
//                                                     ],
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ).then((_) {
//                                           _confettiController
//                                               .dispose(); // Memory bachane ke liye
//                                         });
//                                         // if (context.mounted) {
//                                         //   showDialog(
//                                         //     context: context,
//                                         //     builder: (ctx) => Dialog(
//                                         //       backgroundColor:
//                                         //           Colors.transparent,
//                                         //       child: Stack(
//                                         //         alignment: Alignment.center,
//                                         //         children: [
//                                         //           Container(
//                                         //             width: 280,
//                                         //             padding:
//                                         //                 const EdgeInsets.all(
//                                         //                     20),
//                                         //             decoration: BoxDecoration(
//                                         //               color: const Color(
//                                         //                   0xff6EC6D0),
//                                         //               borderRadius:
//                                         //                   BorderRadius.circular(
//                                         //                       32),
//                                         //               border: Border.all(
//                                         //                   color: const Color(
//                                         //                       0xff3b9499),
//                                         //                   width: 5),
//                                         //             ),
//                                         //             child: Column(
//                                         //               mainAxisSize:
//                                         //                   MainAxisSize.min,
//                                         //               children: [
//                                         //                 const Text(
//                                         //                   "SUCCESS!",
//                                         //                   style: TextStyle(
//                                         //                     fontSize: 24,
//                                         //                     fontWeight:
//                                         //                         FontWeight.w900,
//                                         //                     color: Colors.white,
//                                         //                   ),
//                                         //                 ),
//                                         //                 const SizedBox(
//                                         //                     height: 15),
//                                         //                 // Yahan reward ki image show hogi
//                                         //                 Container(
//                                         //                   padding:
//                                         //                       const EdgeInsets
//                                         //                           .all(8),
//                                         //                   decoration:
//                                         //                       BoxDecoration(
//                                         //                     color: Colors.white,
//                                         //                     borderRadius:
//                                         //                         BorderRadius
//                                         //                             .circular(
//                                         //                                 20),
//                                         //                   ),
//                                         //                   child: Image.network(
//                                         //                     reward
//                                         //                         .imageUrl, // Database wali image
//                                         //                     height: 120,
//                                         //                     width: 120,
//                                         //                     fit: BoxFit.contain,
//                                         //                   ),
//                                         //                 ),
//                                         //                 const SizedBox(
//                                         //                     height: 15),
//                                         //                 Text(
//                                         //                   "Aapne ${reward.title} claim kar liya hai!",
//                                         //                   textAlign:
//                                         //                       TextAlign.center,
//                                         //                   style:
//                                         //                       const TextStyle(
//                                         //                           color: Colors
//                                         //                               .white,
//                                         //                           fontSize: 16),
//                                         //                 ),
//                                         //                 const SizedBox(
//                                         //                     height: 15),
//                                         //                 ElevatedButton(
//                                         //                   onPressed: () =>
//                                         //                       Navigator.pop(
//                                         //                           ctx),
//                                         //                   child:
//                                         //                       const Text("OK"),
//                                         //                 ),
//                                         //               ],
//                                         //             ),
//                                         //           ),
//                                         //           // Close button
//                                         //           Positioned(
//                                         //             top: 5,
//                                         //             right: 5,
//                                         //             child: IconButton(
//                                         //               icon: const Icon(
//                                         //                   Icons.close,
//                                         //                   color: Colors.white),
//                                         //               onPressed: () =>
//                                         //                   Navigator.pop(ctx),
//                                         //             ),
//                                         //           ),
//                                         //         ],
//                                         //       ),
//                                         //     ),
//                                         //   );
//                                         // }

//                                         // if (context.mounted) {
//                                         //   showDialog(
//                                         //     context: context,
//                                         //     builder: (ctx) => AlertDialog(
//                                         //       title: const Text("Success! 🎉"),
//                                         //       content: Text(
//                                         //           "Aapne ${reward.title} claim kar liya hai."),
//                                         //       actions: [
//                                         //         TextButton(
//                                         //           onPressed: () =>
//                                         //               Navigator.pop(ctx),
//                                         //           child: const Text("OK"),
//                                         //         ),
//                                         //       ],
//                                         //     ),
//                                         //   );
//                                         // }

//                                         // ScaffoldMessenger.of(context)
//                                         //     .showSnackBar(
//                                         //   const SnackBar(
//                                         //       content: Text(
//                                         //           "Reward Collected Successfully!")),
//                                         // );
//                                       }
//                                     : null,
//                                 //  canAfford
//                                 //     ? () {
//                                 //         // Yahan apna logic likhein
//                                 //       }
//                                 //     : null, // Locked hone par button kaam nahi karega
//                                 child: Container(
//                                   height: 40,
//                                   width: 120,
//                                   decoration: BoxDecoration(
//                                     color: canAfford
//                                         ? const Color(0xff3b9499)
//                                         : Colors.grey.shade400,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       canAfford ? "Collect!" : "Locked",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}







       // FutureBuilder(
            //   future: RewardStoreRepository().getRewards(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //     // Agar error ho toh screen par dikh jaye
            //     if (snapshot.hasError) {
            //       return Center(child: Text("Error: ${snapshot.error}"));
            //     }
            //     // Agar data na ho
            //     if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            //       return const Center(
            //           child: Text("Table khali hai ya is_active false hai"));
            //     }

            //     final rewards = snapshot.data as List;
            //     return Expanded(
            //       child: GridView.builder(
            //         // padding: const EdgeInsets.all(10),
            //         gridDelegate:
            //             const SliverGridDelegateWithFixedCrossAxisCount(
            //                 childAspectRatio: 0.66, crossAxisCount: 2),
            //         itemCount: rewards.length,
            //         itemBuilder: (context, index) {
            //           final reward = rewards[index];
            //           // return

            //           // Widget buildRewardCard(dynamic reward) {
            //           return Container(
            //             margin: const EdgeInsets.all(5),
            //             decoration: BoxDecoration(
            //               color: Colors.white,
            //               // Color(0xffDEF8F9),
            //               borderRadius: BorderRadius.circular(25),
            //               border:
            //                   Border.all(color: Color(0xff6EC6D0), width: 6),
            //               boxShadow: [
            //                 BoxShadow(
            //                   color: Colors.blue.withOpacity(0.1),
            //                   blurRadius: 10,
            //                   offset: const Offset(0, 5),
            //                 ),
            //               ],
            //             ),
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 3, right: 3),
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   // Reward Title
            //                   // const SizedBox(height: 10),
            //                   Flexible(
            //                     child: Text(
            //                       reward.title,
            //                       textAlign: TextAlign.center,
            //                       style: const TextStyle(
            //                         fontSize: 16,
            //                         fontFamily: "Regular",
            //                         fontWeight: FontWeight.bold,
            //                         color: Color(0xff3b9499),

            //                         // color: Color(0xff313555),
            //                       ),
            //                     ),
            //                   ),

            //                   // Yahan aap reward ki image load karein (e.g., Image.network)
            //                   const Icon(Icons.palette,
            //                       size: 60, color: Colors.orange),

            //                   // const SizedBox(height: 10),

            //                   // Coins Text
            //                   Text(
            //                     "${reward.requiredCoins} Coins",
            //                     style: const TextStyle(
            //                       fontSize: 18,
            //                       fontWeight: FontWeight.w900,
            //                       color: Color(0xff3b9499),
            //                     ),
            //                   ),
            //                   // const SizedBox(height: 10),

            //                   // "Collect!" Button
            //                   Container(
            //                     height: 40,
            //                     width: 120,
            //                     decoration: BoxDecoration(
            //                       color:
            //                           const Color(0xff3b9499), // Button Color
            //                       borderRadius: BorderRadius.circular(20),
            //                       boxShadow: [
            //                         BoxShadow(
            //                           color: Colors.teal.withOpacity(0.3),
            //                           blurRadius: 5,
            //                           offset: const Offset(0, 3),
            //                         ),
            //                       ],
            //                     ),
            //                     child: const Center(
            //                       child: Text(
            //                         "Collect!",
            //                         style: TextStyle(
            //                           color: Colors.white,
            //                           fontSize: 16,
            //                           fontWeight: FontWeight.bold,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           );
            //         },
            //       ),
            //     );
            //   },
            // ),
     