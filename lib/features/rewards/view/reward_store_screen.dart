import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/rewards/view/reward_tracking_history.dart';
import 'package:play_craft_kids/features/rewards/view/tracking_screen.dart';
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
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 90,
                            // width: double.infinity,
                            child: Stack(
                              children: [
                                ClipPath(
                                  clipper: AppBarClipper(),
                                  child: Container(
                                    height: 120,
                                    margin: EdgeInsets.only(bottom: 10),
                                    color: const Color(0xff3b9499),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Tooltip(
                                            message: "Back",
                                            child: SidebarIcon(
                                              icon: Icons.arrow_back_rounded,
                                              assetName:
                                                  'assets/images/pop-button.png',
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ),
                                        ),

                                        // Title
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
                                                        fontSize: 30,
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
                                                        fontSize: 30,
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
                                                      fontSize: 30,
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
        height: double.infinity,
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
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
                          height: 90,
                          // width: double.infinity,
                          child: Stack(
                            children: [
                              ClipPath(
                                clipper: AppBarClipper(),
                                child: Container(
                                  height: 120,
                                  margin: EdgeInsets.only(bottom: 10),
                                  color: const Color(0xff3b9499),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Tooltip(
                                          message: "Back",
                                          child: SidebarIcon(
                                            icon: Icons.arrow_back_rounded,
                                            assetName:
                                                'assets/images/pop-button.png',
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),

                                      // Title
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
                                                      fontSize: 30,
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
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 30,
                                                      fontFamily: "Regular",
                                                      fontWeight:
                                                          FontWeight.w900,
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
                                                    fontSize: 30,
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

                Consumer<HomeViewModel>(
                  builder: (context, hm, _) => Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
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

                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return RewardTrackingHistory();
                      },
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff3b9499),
                          Color.fromARGB(255, 114, 208, 212)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('View Reward History',
                            style: TextStyle(
                                fontFamily: "Regular",
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white)),
                        Image.asset(
                          "assets/images/photo.png",
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),

                // SizedBox(height: 10),
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
                          child:
                              Text("Table khali hai ya is_active false hai"));
                    }

                    final rewards = snapshot.data as List;

                    // Yahan hum HomeViewModel se current coins le rahe hain
                    final userCoins = context.watch<HomeViewModel>().userCoins;

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true, // Zaroori hai
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.80, crossAxisCount: 2),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final reward = rewards[index];

                        // Logic: Kya user ke paas kaafi coins hain?
                        final bool canAfford =
                            userCoins >= reward.requiredCoins;

                        return Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            // Locked hone par color halka (grey) ho jayega
                            color:
                                // canAfford ?
                                Colors.white,
                            //  : Colors.grey.shade100,
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
                                        color: const Color(0xff3b9499)),
                                  ),
                                ),

                                SizedBox(
                                  height: 5,
                                ),
                                // Icon ki jagah ye block use karein
                                reward.imageUrl != null &&
                                        reward.imageUrl.isNotEmpty
                                    ? Container(
                                        height:
                                            80, // Apni marzi se size adjust karein
                                        width: 80,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2,
                                              color: Color(0xff3b9499)),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          image: DecorationImage(
                                            // Agar locked hai toh image ko thoda dim/greyish dikhane ke liye
                                            colorFilter: null,
                                            image:
                                                NetworkImage(reward.imageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Icon(Icons.palette,
                                        size: 60, color: Colors.orange),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${reward.requiredCoins} Coins",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xff3b9499),
                                  ),
                                ),

                                // "Collect!" Button

                                GestureDetector(
                                  onTap: () {
                                    final requiredCoins = reward.requiredCoins;
                                    final currentCoins = context
                                        .read<HomeViewModel>()
                                        .databaseCoins;
                                    if (canAfford) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            width: 280,
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF1E4CE),
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xff3b9499),
                                                  width: 5),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // 1. Reward Image (Yahan image show hogi)
                                                if (reward.imageUrl != null &&
                                                    reward.imageUrl.isNotEmpty)
                                                  Container(
                                                    height: 100,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                          reward.imageUrl,
                                                          // height: 100,
                                                          // width: 100,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all(
                                                          color:
                                                              Color(0xff3b9499),
                                                          width:
                                                              2), // Agar border chahiye
                                                    ),
                                                  ),

                                                const SizedBox(height: 15),

                                                // 2. Reward Title
                                                Text(
                                                  reward
                                                      .title, // Yahan reward ka naam show hoga
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily: "Regular",
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff3b9499)
                                                      //  Colors.white
                                                      ),
                                                ),
                                                const SizedBox(height: 5),

                                                // 3. Confirmation Message
                                                Text(
                                                  "Are you sure you want to spend ${reward.requiredCoins} coins to purchase this? After seven days, you will receive this reward.",
                                                  textAlign: TextAlign.justify,
                                                  style: const TextStyle(
                                                      fontFamily: "Regular",
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xff3b9499),
                                                      //  Colors.white,
                                                      fontSize: 15),
                                                ),
                                                const SizedBox(height: 10),

                                                // 4. Buttons
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child:
                                                          const Text("Cancel"),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Color(0xff3b9499),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        // Tracking screen ka push logic
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  TrackingScreen(
                                                                      reward:
                                                                          reward)),
                                                        );
                                                      },
                                                      child: const Text("Yes"),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
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
                                                  color: const Color(
                                                      0xff6EC6D0), // Red shade for warning
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xff3b9499),
                                                      width: 5),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      "COINS KAM HAIN!",
                                                      style: TextStyle(
                                                          fontFamily: "Regular",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 22,
                                                          color: Colors.white),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    // Icon for visual appeal
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
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
                                                          fit: BoxFit.contain),
                                                    ),

                                                    // const Icon(
                                                    //     Icons
                                                    //         .sentiment_dissatisfied,
                                                    //     size: 60,
                                                    //     color: Colors.white),
                                                    const SizedBox(height: 15),
                                                    Text(
                                                      "Aapke paas $currentCoins coins hain.\nIske liye $requiredCoins chahiye.",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontFamily: "Regular",
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Color(
                                                                      0xff3b9499),
                                                              foregroundColor:
                                                                  Color(
                                                                      0xff3b9499)),
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child: const Text(
                                                        "OK",
                                                        style: TextStyle(
                                                          fontFamily: "Regular",
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Close button (StickerIconButton)
                                              Positioned(
                                                top: -10,
                                                right: -10,
                                                child: StickerIconButton(
                                                  icon: Icons.close,
                                                  assetName:
                                                      'assets/images/close.png',
                                                  size: 48,
                                                  backgroundColor: Colors.white,
                                                  iconColor: Colors.red,
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  },
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
                                )
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
      ),
    );
  }
}
