import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
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
                                                  "Tracking History",
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
                                                  "Tracking History",
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
                                                "Tracking History",
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
                    // User ka apna data check karein
                    bool isUserMatch = item['user_id'] == userId;

                    // Agar status 'all' hai, toh sirf user ka data return karein
                    if (status == 'all') return isUserMatch;

                    // Agar 'all' nahi hai, toh user aur specific status dono match hone chahiye
                    return isUserMatch && item['status'] == status;
                  }).toList()),
      builder: (context, snapshot) {
        print(
            "Current Status: ${snapshot.connectionState}, Has Data: ${snapshot.hasData}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];
        if (data.isEmpty)
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              "assets/images/tracking.png",
              // height: 200,
            ),
          ));

        return Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xff6EC6D0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xff3b9499), width: 3),
                ),
                child: ListTile(
                  title: Text(
                    "Reward: ${item['reward_title'] ?? 'N/A'}",
                    style: const TextStyle(
                        fontFamily: "Regular",
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Address: ${item['address']}\nStatus: ${item['status']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Regular",
                    ),
                  ),
                  trailing: const Icon(Icons.history, color: Colors.white),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
