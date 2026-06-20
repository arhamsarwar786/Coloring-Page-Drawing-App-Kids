import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/rewards/viewmodel/reward_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  final dynamic reward; // Aapke reward ka model
  const TrackingScreen({super.key, required this.reward});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

// reward_tracking_history.dart
// TrackingScreen ka naya logic (Popup ki jagah direct screen update)

class _TrackingScreenState extends State<TrackingScreen> {
  final TextEditingController _addressController = TextEditingController();
  String? _errorMessage; // Ye variable error show karne ke liye

  @override
  Widget build(BuildContext context) {
    return Container(
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
        backgroundColor: Colors.transparent, // Main background color
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                                                  "Tracking Screen",
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
                                                  "Tracking Screen",
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
                                                "Tracking Screen",
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

              const Text("ENTER DELIVERY ADDRESS",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3b9499))),
              const SizedBox(height: 20),

              // TextField
              Container(
                // padding: EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2B24A),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextFormField(
                  controller: _addressController,
                  // obscureText: obscure,
                  // validator: validator,
                  decoration: InputDecoration(
                    hintText: "Enter address",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontFamily: "Regular",
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    // suffixIcon: onToggleVisibility != null
                    //     ? IconButton(
                    //         icon: Icon(
                    //           obscure ? Icons.visibility_off : Icons.visibility,
                    //           color: Color(0xFF1EA7C7),
                    //         ),
                    // onPressed: onToggleVisibility,
                    // )
                    // : null,
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child:
              //    TextField(
              //     controller: _addressController,
              //     decoration: const InputDecoration(
              //         filled: true,
              //         fillColor: Colors.white,
              //         hintText: "Enter address"),
              //   ),
              // ),

              // Error Message (Agar city Lahore nahi hui)
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_errorMessage!,
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff3b9499),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    child: const Text("Confirm"),
                    onPressed: () async {
                      // 1. Lahore Validation
                      String address =
                          _addressController.text.trim().toLowerCase();
                      if (!address.contains("lahore")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Sorry, currently we only deliver in Lahore.")),
                        );
                        return;
                      }

                      // 2. Confirmation Dialog
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Confirm Purchase"),
                          content: const Text(
                              "Are you sure you want to spend these coins to purchase this product? After seven days, you will receive this reward."),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel")),
                            ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Confirm")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          // 3. Database Insert
                          await Supabase.instance.client
                              .from('reward_claims')
                              .insert({
                            'user_id':
                                Supabase.instance.client.auth.currentUser!.id,
                            'reward_id': widget.reward.id.toString(),
                            'reward_title': widget.reward.title.toString(),
                            'coins_spent': widget.reward.requiredCoins,
                            'address': _addressController.text,
                            'status': 'pending',
                            'parent_name': 'N/A',
                            'child_name': 'N/A',
                            'phone': '0000000000',
                            'email': 'user@email.com',
                            'city': 'Lahore',
                            'created_at': DateTime.now().toIso8601String(),
                          });

                          // 4. Coins Deduct
                          await context
                              .read<RewardViewModel>()
                              .collectReward(widget.reward);

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Reward Claimed Successfully!")),
                          );
                        } catch (e) {
                          print("Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
