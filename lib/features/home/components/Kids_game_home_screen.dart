import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/coloring/widgets/delete_dialog.dart';
import 'package:play_craft_kids/features/planner/view/planner_feature_dialog.dart';
import 'package:play_craft_kids/features/planner/viewmodel/planner_reward_viewmodel.dart';
import 'package:play_craft_kids/features/settings/viewmodel/settings_viewmodel.dart';
import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/interaction_feedback.dart';

class KidsGameHomeScreen extends StatelessWidget {
  const KidsGameHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // -------------------------------------------------------------
          // BACKGROUND LAYER: Light beige background with smooth fruit pattern simulation
          // -------------------------------------------------------------
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF6EAD2),
              child: Opacity(
                opacity: 0.12,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 40,
                    crossAxisSpacing: 40,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final icons = [
                      Icons.apple_rounded,
                      Icons.bakery_dining_rounded,
                      Icons.icecream_rounded
                    ];
                    return Icon(
                      icons[index % icons.length],
                      size: 60,
                      color: const Color(0xFF8B5A2B),
                    );
                  },
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------
          // MAIN CONTENT: App bar and grid setup
          // -------------------------------------------------------------
          SafeArea(
            top: false,
            child: Column(
              children: [
                // Custom Curved App Bar Layer
                const CustomGameAppBar(title: "FRUITS"),

                // Active Game Levels Layout
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        // Level Data Simulation
                        final titles = ["APPLE", "BANANA", "GRAPES", "ORANGE"];
                        final colors = [
                          const Color(0xFFFFA6C8), // Pink
                          const Color(0xFFFFD34D), // Yellow
                          const Color(0xFFBC86FF), // Purple
                          const Color(0xFFFFB156), // Orange
                        ];
                        final edgeColors = [
                          const Color(0xFFD55282),
                          const Color(0xFFD39B16),
                          const Color(0xFF7542C9),
                          const Color(0xFFD36A18),
                        ];

                        return GameLevelCard(
                          title: titles[index],
                          baseColor: colors[index],
                          edgeColor: edgeColors[index],
                          isLocked: index > 0, // Lock status example
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------------
          // OVERLAY DIALOG LAYER: Settings Modal View Trigger (Centered Overlay)
          // -------------------------------------------------------------
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
              child: const Center(
                child: KidsSettingsDialog(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// GAME APP BAR: Matches Image perfectly with Smooth Convex Curve
// =============================================================================
class CustomGameAppBar extends StatelessWidget {
  final String title;
  const CustomGameAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        ClipPath(
          clipper: AppBarCurveClipper(),
          child: Container(
            height: statusBarHeight + 115,
            decoration: const BoxDecoration(
              color: Color(0xFF32939B), // Exact matching solid teal color
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF23696F),
                  width: 5.0,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: statusBarHeight + 20,
          left: 16,
          child: const GameBackButton(),
        ),
        Positioned(
          top: statusBarHeight + 15,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text Outer Border/Shadow effect
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 44,
                    fontFamily: "Regular",
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 7
                      ..color = const Color(0xFF1E5459),
                  ),
                ),
                // Core Display Text
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 44,
                    fontFamily: "Regular",
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: const Color(0xFFFFFEE4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AppBarCurveClipper extends CustomClipper<Path> {
  @override
  Path getCurve(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 35);
    Offset controlPoint = Offset(size.width / 2, size.height + 15);
    Offset endPoint = Offset(size.width, size.height - 35);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  Path getClip(Size size) => getCurve(size);

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// =============================================================================
// BACK BUTTON COMPONENT: Exact matching styling
// =============================================================================
class GameBackButton extends StatelessWidget {
  const GameBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFBC5339), // Darker edge shade
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE76F51), // Bright main peach orange base
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// PLAYABLE LEVEL CONTAINER COMPONENT: Colors are retained even under locked states
// =============================================================================
class GameLevelCard extends StatelessWidget {
  final String title;
  final Color baseColor;
  final Color edgeColor;
  final bool isLocked;

  const GameLevelCard({
    super.key,
    required this.title,
    required this.baseColor,
    required this.edgeColor,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(bottom: 8.0, left: 4.0, right: 4.0, top: 4.0),
      decoration: BoxDecoration(
        color: edgeColor,
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Stack(
          children: [
            // Top Accent Highlight Strip
            Positioned(
              top: 8,
              left: 12,
              child: Container(
                width: 32,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Card Content Core Layout
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: const Center(
                        child: Icon(Icons.palette_rounded,
                            size: 50, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Regular",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Persistent Semi-Transparent Dynamic Lock Layer Overlay
            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.0),
                    color: Colors.black
                        .withOpacity(0.26), // Retains background card color
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SETTINGS DIALOG VIEW COMPONENT (Logic + First Code Image Assets Fixed!)
// =============================================================================
class KidsSettingsDialog extends StatelessWidget {
  const KidsSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pop(context), // Background tap karne par dialog close hoga
      child: Material(
        borderRadius: BorderRadius.circular(36),
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {}, // Dialog ke andar tap karne par dialog band nahi hoga
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Clay Styled Box Structure Container
              Container(
                width: 320,
                height: 430,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xff6EC6D0), // Outer darker clay base plate
                  borderRadius: BorderRadius.circular(36.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFF1E4CE), // Inner main smooth clay body surface
                    borderRadius: BorderRadius.circular(26.0),
                  ),
                  child: Consumer<SettingsViewModel>(
                    builder: (_, viewModel, __) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 5),
                            // Heading Banner Header
                            DialogHeaderBanner(
                                text: AppStrings.settingsTitle.toUpperCase()),
                            const SizedBox(height: 10),

                            // Core Utility Options Configuration Row (Logic + Image Assets Added!)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Music Icon Tile Button
                                CustomVolumeDialIcon(
                                  assetName: viewModel.musicEnabled
                                      ? 'assets/images/music.png'
                                      : 'assets/images/music-off.png',
                                  onTap: viewModel.toggleMusic,
                                ),

                                // Sound Effects Icon Tile Button
                                CustomVolumeDialIcon(
                                  assetName: viewModel.soundEnabled
                                      ? 'assets/images/sound.png'
                                      : 'assets/images/sound-off.png',
                                  onTap: viewModel.toggleSound,
                                ),
                                // CustomVolumeDialIcon(
                                //   assetName: "assets/images/deletes.png",
                                //   onTap: () {
                                // showDialog(
                                //   context: context,
                                //   barrierDismissible: false,
                                //   builder: (_) => DeleteAccountDialog(
                                //     screenContext: context,
                                //     onDelete: () async {
                                //       final user = Supabase
                                //           .instance.client.auth.currentUser;

                                //       if (user != null) {
                                //         await Supabase
                                //             .instance.client.functions
                                //             .invoke(
                                //           'delete_user',
                                //           body: {'user_id': user.id},
                                //         );

                                //         await Supabase.instance.client.auth
                                //             .signOut();

                                //         Navigator.pushAndRemoveUntil(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (_) =>
                                //                   const LoginScreen()),
                                //           (route) => false,
                                //         );
                                //       }
                                //     },
                                //   ),
                                // );
                                //   },
                                // )
                              ],
                            ),
                            // const Spacer(),
                            const SizedBox(height: 10),

                            Consumer<PlannerRewardViewModel>(
                              builder: (context, planner, _) {
                                final unlocked = planner.isUnlocked;
                                return GestureDetector(
                                  onTap: () {
                                    PlannerFeatureDialog.show(
                                      context,
                                      mode: unlocked
                                          ? PlannerDialogMode.download
                                          : PlannerDialogMode.locked,
                                    );
                                  },
                                  child: GameMenuActionButton(
                                    label: unlocked
                                        ? 'DOWNLOAD PLANNER'
                                        : 'PLANNER ${planner.completedLevels}/${planner.unlockThreshold}',
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Embedded Action Button Action Layer (Privacy Policy Logic Triggered)
                            GestureDetector(
                              onTap: tapActionCallback(context, () {
                                return Navigator.pushNamed(
                                  context,
                                  AppRoutes.privacy,
                                );
                              }),
                              child: const GameMenuActionButton(
                                  label: "PRIVACY POLICY"),
                            ),

                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => LogoutDialog(
                                    screenContext: context,
                                    onLogout: () async {
                                      try {
                                        await Supabase.instance.client.auth
                                            .signOut();

                                        if (!context.mounted) return;

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const LoginScreen(),
                                          ),
                                          (route) => false,
                                        );
                                      } catch (e) {
                                        print(e);
                                      }
                                    },
                                  ),
                                );
                              },
                              child:
                                  const GameMenuActionButton(label: "Log Out"),
                            ),

                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => DeleteAccountDialog(
                                    screenContext: context,
                                    onDelete: () async {
                                      final user = Supabase
                                          .instance.client.auth.currentUser;

                                      if (user != null) {
                                        await Supabase.instance.client.functions
                                            .invoke(
                                          'delete_user',
                                          body: {'user_id': user.id},
                                        );

                                        await Supabase.instance.client.auth
                                            .signOut();

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen()),
                                          (route) => false,
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                              child: const GameMenuActionButton(
                                  label: "Account Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Circular External Close Frame Controller (Top Right Cross Button Logic)
              Positioned(
                top: -10,
                right: -10,
                child: StickerIconButton(
                  icon: Icons.arrow_back_rounded,
                  assetName: 'assets/images/close.png',
                  size: 48,
                  backgroundColor: Colors.white,
                  iconColor: const Color(0xFF17A7F2),
                  onPressed: () => Navigator.pop(context),
                ),
                // GestureDetector(
                //   onTap: () => Navigator.pop(
                //       context), // Click karne par pop out/close hoga
                //   child: const DialogDismissButton(),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 3D Text Banner Element Container
class DialogHeaderBanner extends StatelessWidget {
  final String text;
  const DialogHeaderBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xff6EC6D0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff3b9499), width: 4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontFamily: "Regular",
          fontWeight: FontWeight.w900,
          color: Colors.white,
          // color: const Color(0xFF8B6747),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// =============================================================================
// FIXED: CUSTOM VOLUME DIAL WITH FIRST CODE ASSET IMAGES
// =============================================================================
class CustomVolumeDialIcon extends StatelessWidget {
  final String assetName;
  final VoidCallback onTap;

  const CustomVolumeDialIcon({
    super.key,
    required this.assetName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 75,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xff3b9499), // Outer base layer
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(12), // Dynamic image padding
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFFEAEAEA), Color(0xFF9E9E9E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Image.asset(
            assetName,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// Privacy Policy CTA Button Component Widget
class GameMenuActionButton extends StatelessWidget {
  final String label;
  const GameMenuActionButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 190,
      decoration: BoxDecoration(
        color: const Color(0xff3b9499), // Outer deep base rim ring
        borderRadius: BorderRadius.circular(26),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5.0),
        decoration: BoxDecoration(
          color: const Color(
              0xff3b9499), // High vibrant primary active surface green
          borderRadius: BorderRadius.circular(26),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "Regular",
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// Top Right Cross/Dismiss Floating Wrapper Button Widget
class DialogDismissButton extends StatelessWidget {
  const DialogDismissButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF982525), // shadow bottom base border ring
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFD63D3D), // red tone surface paint
        ),
        child: const Center(
          child: Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 26,
            weight: 3.0,
          ),
        ),
      ),
    );
  }
}
