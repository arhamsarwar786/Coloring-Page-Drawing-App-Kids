import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/rewards/view/reward_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardTrackingHistory extends StatelessWidget {
  const RewardTrackingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    // return

// RewardTrackingHistory class mein length: 3 kar dein

    return DefaultTabController(
      length: 3, // 3 Tabs hain hamare paas
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/reward.webp"), // Replace with your image path
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5),
              BlendMode.lighten,
            ), // Adjust the fit to your liking
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // 1. Aapka Custom Header (AppBar)
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
                                                  "Tracking History",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 30,
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
                                                  "Tracking History",
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 30,
                                                    fontFamily: "Regular",
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFFFF4FA3),
                                                    letterSpacing: 1,
                                                  ),
                                                ),
                                              ),

                                              // Main White Text
                                              Text(
                                                "Tracking History",
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
              // 2. TabBar Yahan add karein (Header ke niche)
              const TabBar(
                labelColor: Colors.black,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "Regular",
                ),
                unselectedLabelColor: Color(0xff3b9499),
                tabs: [
                  Tab(text: "All"),
                  Tab(text: "Pending"),
                  Tab(text: "Completed"),
                ],
              ),

              // 3. TabBarView ko Expanded mein rakhein (Zaroori hai!)
              const Expanded(
                child: TabBarView(
                  children: [
                    RewardList(status: 'all'),
                    RewardList(status: 'pending'),
                    RewardList(status: 'delivered'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ye widget database se data fetch karega

class RewardList extends StatelessWidget {
  final String status;
  const RewardList({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('reward_claims')
          .stream(primaryKey: ['id']).map(
              (List<Map<String, dynamic>> event) => event.where((item) {
                    bool isUserMatch = item['user_id'] == userId;
                    if (status == 'all') return isUserMatch;
                    return isUserMatch && item['status'] == status;
                  }).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // final data = snapshot.data ?? [];

        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(snapshot.data ?? []);
        if (data.isEmpty) {
          return Center(child: Image.asset("assets/images/tracking.png"));
        }

        data.sort((a, b) {
          String statusA = a['status'] ?? 'pending';
          String statusB = b['status'] ?? 'pending';

          if (statusA == statusB) return 0;
          // Agar 'pending' ko upar chahiye toh -1 return karein
          if (statusA == 'pending') return -1;
          return 1;
        });

        return ListView.builder(
          padding: const EdgeInsets.only(top: 10),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];

            String getImageUrl(String rewardId) {
              if (rewardId == "e232839c-cb25-489c-b4c5-98314521eb3f")
                return "https://skywvbfwotpxlwiglxpl.supabase.co/storage/v1/object/public/rewards_images/certificate.png";
              if (rewardId == "f10aaf53-bdc0-43cd-a91b-cec5203d9d99")
                return "https://skywvbfwotpxlwiglxpl.supabase.co/storage/v1/object/public/rewards_images/sticker.png";
              if (rewardId == "4620fa4a-a9e1-48f1-a01d-97faecbe62c2")
                return "https://skywvbfwotpxlwiglxpl.supabase.co/storage/v1/object/public/rewards_images/crayon.png";
              if (rewardId == "8559ee27-5d03-46be-94bf-3ee2599d88df")
                return "https://skywvbfwotpxlwiglxpl.supabase.co/storage/v1/object/public/rewards_images/bottle.png";
              return "";
            }

            final imageUrl = getImageUrl(item['reward_id']);
            return InkWell(
              onTap: () {
                // Nayi screen par data bhej dein
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RewardDetailScreen(item: item),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 227, 244,
                      247), // Light blue background jaisa image mein hai
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff3b9499), width: 3),
                ),
                child: Row(
                  children: [
                    // Image Container
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xff3b9499), width: 3),
                        borderRadius: BorderRadius.circular(15),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.white, // Placeholder ka color
                      ),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.card_giftcard,
                              size: 40, color: Color(0xff3b9499))
                          : null,
                    ),
                    const SizedBox(width: 15),
                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reward: ${item['reward_title'] ?? 'N/A'}",
                              style: const TextStyle(
                                  fontFamily: "Regular",
                                  color: Colors.black, // Image jaisa dark text
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const Text("Shipping Details:",
                              style: TextStyle(
                                  fontFamily: "Regular",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text("Address: ${item['address'] ?? 'N/A'}",
                              style: const TextStyle(
                                  fontFamily: "Regular",
                                  color: Colors.black,
                                  fontSize: 12)),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text("Status: ${item['status'] ?? 'pending'}",
                                  style: const TextStyle(
                                      fontFamily: "Regular",
                                      color: Color(0xff3b9499),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              if (item['status'] == 'delivered')
                                const Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Icon(Icons.check_circle,
                                        color: Colors.green, size: 16)),
                              const Spacer(),
                              Text("${item['coins_spent'] ?? 0} Coins",
                                  style: const TextStyle(
                                      fontFamily: "Regular",
                                      color: Colors
                                          .orange, // Coins ko highlight karne ke liye
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
