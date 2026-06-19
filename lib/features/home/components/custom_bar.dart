import 'package:flutter/material.dart';
import 'package:play_craft_kids/app/routes/app_routes.dart';
import 'package:play_craft_kids/core/utils/app_bottom_bar.dart';
import 'package:play_craft_kids/features/drawing/viewmodel/drawing_viewmodel.dart';
import 'package:play_craft_kids/features/history/viewmodel/history_viewmodel.dart';
import 'package:play_craft_kids/features/home/components/Kids_game_home_screen.dart';
import 'package:play_craft_kids/features/home/components/coins_history_screen.dart';
import 'package:play_craft_kids/features/home/viewmodel/home_viewmodel.dart';
import 'package:play_craft_kids/features/rewards/view/reward_screen.dart';
import 'package:play_craft_kids/features/rewards/view/reward_store_screen.dart';
import 'package:play_craft_kids/shared/utils/interaction_feedback.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomBar extends StatefulWidget {
  const CustomBar({super.key});

  @override
  State<CustomBar> createState() => _CustomBarState();
}

class _CustomBarState extends State<CustomBar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          // color: Colors.white,
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 64, 249, 255),
              // Colors.white,
              const Color.fromARGB(255, 161, 205, 216)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Aapke buttons wahi hain, bas ab ye Container ke andar hain
            AppBottomBar(
              child: Image.asset("assets/images/home.webp"),
              topColor: Colors.orangeAccent,
              bottomColor: Colors.orange,
              isSelected: selectedIndex == 0,
              onTap: () {
                handleTapAction(context, () {});
                setState(() => selectedIndex = 0);
              },
            ),
            AppBottomBar(
                child: Image.asset("assets/images/photo.png"),
                topColor: Colors.purpleAccent,
                bottomColor: Colors.purple,
                isSelected: selectedIndex == 1,
                onTap: () async {
                  setState(() => selectedIndex = 1);
                  final viewModel = context.read<HistoryViewModel>();

                  // 2. Apne function ko check karein
                  // Agar function ka naam 'persistHistorySnapshot' hai, toh wahi use karein
                  // Agar 'snapshot' argument required nahi hai, toh use hata dein
                  try {
                    viewModel.persistHistorySnapshot(captureThumbnail: true);
                  } catch (e) {
                    print("Function call mein masla hai: $e");
                  }
                  // context
                  //     .read<HistoryViewModel>()
                  //     .persistHistorySnapshot(captureThumbnail: true);
                  if (context.mounted) {
                    Navigator.pushNamed(context, AppRoutes.levels);
                  }
                }),

            AppBottomBar(
              child: Text('🪙', style: TextStyle(fontSize: 30)),
              // const SizedBox(width: 4),
              topColor: const Color.fromARGB(255, 72, 228, 67),
              bottomColor: const Color.fromARGB(255, 130, 219, 79),
              isSelected: selectedIndex == 2,
              onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CoinHistoryScreen()));
                // await context.read<HomeViewModel>().load();
                // final viewModel = context.read<HomeViewModel>();
                // final session = Supabase.instance.client.auth.currentSession;
                // final userId = session?.user?.id ?? '';
                // if (userId.isNotEmpty) {
                //   await viewModel.fetchCoinHistory(userId);
                // }

                handleTapAction(context, () {});
                setState(() => selectedIndex = 2);
                // showDialog(
                //   context: context,
                //   builder: (_) => const Center(child: KidsSettingsDialog()),
                // );
              },
            ),

            AppBottomBar(
              child: Image.asset("assets/images/setting.png"),
              topColor: Colors.blueAccent,
              bottomColor: Colors.blue,
              isSelected: selectedIndex == 3,
              onTap: () {
                handleTapAction(context, () {});
                setState(() => selectedIndex = 3);
                showDialog(
                  context: context,
                  builder: (_) => const Center(child: KidsSettingsDialog()),
                );
              },
            ),

            AppBottomBar(
              child: Image.asset("assets/images/reward.png"),
              topColor: const Color.fromARGB(255, 205, 211, 221),
              bottomColor: Colors.blue,
              isSelected: selectedIndex == 4,
              onTap: () {
                handleTapAction(context, () {});
                setState(() => selectedIndex = 4);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RewardStoreScreen()));
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (_) => ));
                // // showDialog(
                //   context: context,
                //   builder: (_) => const Center(child: KidsSettingsDialog()),
                // );
              },
            ),
          ],
        ),
      ),
    );
  }
}
