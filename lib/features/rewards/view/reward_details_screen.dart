import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/certificates/models/playcraft_certificate_data.dart';
import 'package:play_craft_kids/features/certificates/view/playcraft_certificate_preview_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const RewardDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Current user ki email safe tarike se fetch ki
    final userEmail =
        Supabase.instance.client.auth.currentUser?.email ?? "Not Available";

    // Date ko safe tarike se handle kiya
    String dateValue = "N/A";
    if (item['created_at'] != null) {
      dateValue = item['created_at'].toString().split('T')[0];
    }

    final details = [
      {"label": "Reward Title", "value": item['reward_title']},
      {"label": "Status", "value": item['status']},
      {"label": "Coins Spent", "value": "${item['coins_spent']}"},
      {"label": "Parent Name", "value": item['parent_name']},
      {"label": "Child Name", "value": item['child_name']},
      {"label": "Phone", "value": item['phone']},
      {"label": "Email", "value": item['email']},
      {"label": "City", "value": item['city']},
      {"label": "Address", "value": item['address']},
      {"label": "User Note", "value": item['user_note'] ?? "No notes"},
      {"label": "Tracking #", "value": item['tracking_number'] ?? "Pending"},
      {
        "label": "Created At",
        "value": item['created_at'].toString().split('T')[0]
      },
    ];
    // final details = [
    //   {
    //     "label": "Reward Title",
    //     "value": item['reward_title']?.toString() ?? "N/A"
    //   },
    //   {"label": "Status", "value": item['status']?.toString() ?? "N/A"},
    //   {"label": "Coins Spent", "value": item['coins_spent']?.toString() ?? "0"},
    //   {
    //     "label": "Parent Name",
    //     "value": item['parent_name']?.toString() ?? "N/A"
    //   },
    //   {"label": "Child Name", "value": item['child_name']?.toString() ?? "N/A"},
    //   {"label": "Phone", "value": item['phone']?.toString() ?? "N/A"},
    //   {"label": "Email", "value": userEmail},
    //   {"label": "City", "value": item['city']?.toString() ?? "N/A"},
    //   {"label": "Address", "value": item['address']?.toString() ?? "N/A"},
    //   {
    //     "label": "User Note",
    //     "value": item['user_note']?.toString() ?? "No notes"
    //   },
    //   // {
    //   //   "label": "Tracking #",
    //   //   "value": item['tracking_number']?.toString() ?? "Pending"
    //   // },
    //   {"label": "Created At", "value": dateValue},
    // ];

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Background color jaisa image mein hai
      body: Container(
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
        height: double.infinity,
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
                                                  "Reward Details",
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
                                                  "Reward Details",
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
                                                "Reward Details",
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

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  itemCount: details.length,
                  itemBuilder: (context, index) {
                    final detail = details[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(30), // Rounded corners
                        border: Border.all(
                            color: const Color(0xff3b9499), width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(detail['label']!,
                              style: const TextStyle(
                                  fontFamily: "Regular",
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff3b9499))),
                          Text(detail['value']!,
                              style: const TextStyle(
                                  fontFamily: "Regular",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Niche Collect Button

              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  // Hum sirf tabhi button dikhayenge agar title "Certificate" se match kare
                  child: item['reward_title'].toString().contains("Certificate")
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1A2B48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            final String childName =
                                item['child_name'] ?? "Child";
                            final certificateData = PlayCraftCertificateData(
                              childName: childName,
                              // childName:
                              //     "Fatima", // Yahan Supabase se fetch kiya hua naam dalen
                              certificateId:
                                  "PC-${DateTime.now().millisecondsSinceEpoch}", // Unique ID
                              issuedAt: DateTime.now(),
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PlayCraftCertificatePreviewScreen(
                                  certificate: certificateData,
                                ),
                              ),
                            );

                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (_) => PlayCraftCertificatePreviewScreen(
                            //       certificate: certificateData,
                            //     ),
                            //   ),
                            // );
                            // Collect Action
                            print("Collecting Certificate...");
                          },
                          child: const Text("Collect Certificate",
                              style: TextStyle(
                                  fontFamily: "Regular",
                                  fontSize: 18,
                                  color: Colors.white)),
                        )
                      : const SizedBox
                          .shrink(), // Agar Certificate nahi hai, to button gayab ho jayega
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(20),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 55,
              //     child: ElevatedButton(
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: const Color(0xff1A2B48),
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(30)),
              //       ),
              //       onPressed: () {
              //         // Collect Action
              //       },
              //       child: const Text("Collect Certificate",
              //           style: TextStyle(fontSize: 18, color: Colors.white)),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
    // Scaffold(
    //   appBar: AppBar(
    //     title: const Text("Reward Details"),
    //     backgroundColor: const Color(0xff3b9499),
    //   ),
    //   body:
    //   ListView.builder(
    //     padding: const EdgeInsets.all(20),
    //     itemCount: details.length,
    //     itemBuilder: (context, index) {
    //       final detail = details[index];
    //       return Card(
    //         elevation: 2,
    //         margin: const EdgeInsets.symmetric(vertical: 6),
    //         child: ListTile(
    //           title: Text(detail['label']!,
    //               style: const TextStyle(
    //                   fontWeight: FontWeight.bold, color: Color(0xff3b9499))),
    //           trailing:
    //               Text(detail['value']!, style: const TextStyle(fontSize: 15)),
    //         ),
    //       );
    //     },
    //   ),

    // );
  }
}
