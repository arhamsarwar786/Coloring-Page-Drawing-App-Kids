// import 'package:flutter/material.dart';
// import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
// import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
// import 'package:play_craft_kids/features/rewards/viewmodel/reward_viewmodel.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class TrackingScreen extends StatefulWidget {
//   final dynamic reward; // Aapke reward ka model
//   const TrackingScreen({super.key, required this.reward});

//   @override
//   State<TrackingScreen> createState() => _TrackingScreenState();
// }

// // reward_tracking_history.dart
// // TrackingScreen ka naya logic (Popup ki jagah direct screen update)

// class _TrackingScreenState extends State<TrackingScreen> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cityController =
//       TextEditingController(text: "Lahore");
//   final TextEditingController _parentNameController = TextEditingController();
//   final TextEditingController _childNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   String? _errorMessage; // Ye variable error show karne ke liye

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: double.infinity,
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(
//               "assets/images/reward.webp"), // Replace with your image path
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(
//             Colors.white.withOpacity(0.5),
//             BlendMode.lighten,
//           ), // Adjust the fit to your liking
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent, // Main background color
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
// Padding(
//   padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
//   child: Row(
//     children: <Widget>[
//       Expanded(
//         child: SizedBox(
//           height: 90,
//           // width: double.infinity,
//           child: Stack(
//             children: [
//               ClipPath(
//                 clipper: AppBarClipper(),
//                 child: Container(
//                   height: 120,
//                   margin: EdgeInsets.only(bottom: 10),
//                   color: const Color(0xff3b9499),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: SidebarIcon(
//                           icon: Icons.arrow_back_rounded,
//                           assetName:
//                               'assets/images/pop-button.png',
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ),

//                       // Title
//                       // Title
//                       Expanded(
//                         child: Center(
//                           child: FittedBox(
//                             fit: BoxFit.scaleDown,
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 // Shadow Layer
//                                 Transform.translate(
//                                   offset: const Offset(6, 6),
//                                   child: Text(
//                                     "Tracking Screen",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 30,
//                                       fontFamily: "Regular",
//                                       fontWeight: FontWeight.w900,
//                                       color: Colors.black
//                                           .withOpacity(0.35),
//                                       letterSpacing: 1,
//                                     ),
//                                   ),
//                                 ),

//                                 // Pink 3D Layer
//                                 Transform.translate(
//                                   offset: const Offset(3, 3),
//                                   child: Text(
//                                     "Tracking Screen",
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(
//                                       fontSize: 30,
//                                       fontFamily: "Regular",
//                                       fontWeight: FontWeight.w900,
//                                       color: Color(0xFFFF4FA3),
//                                       letterSpacing: 1,
//                                     ),
//                                   ),
//                                 ),

//                                 // Main White Text
//                                 Text(
//                                   "Tracking Screen",
//                                   textAlign: TextAlign.center,
//                                   style: const TextStyle(
//                                     fontSize: 30,
//                                     fontFamily: "Regular",
//                                     fontWeight: FontWeight.w900,
//                                     color: Colors.white,
//                                     letterSpacing: 1,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(width: 60),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

//               const Text("ENTER DELIVERY ADDRESS",
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xff3b9499))),
//               const SizedBox(height: 20),

//               // TextField
//          Container(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2B24A),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextFormField(
//                   controller: _parentNameController,
//                   decoration: const InputDecoration(
//                     hintText: "Enter Parent Name",
//                     border: InputBorder.none,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),

// // Example for Parent Name - Repeat this structure for Child Name and Phone
//               Container(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2B24A),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextFormField(
//                   controller: _childNameController,
//                   decoration: const InputDecoration(
//                     hintText: "Enter Child Name",
//                     border: InputBorder.none,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),

// // Example for Parent Name - Repeat this structure for Child Name and Phone
//               Container(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2B24A),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextFormField(
//                   controller: _phoneController,
//                   decoration: const InputDecoration(
//                     hintText: "Enter Phone",
//                     border: InputBorder.none,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),

//               Container(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2B24A),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextFormField(
//                   controller: _cityController,
//                   decoration: const InputDecoration(
//                     hintText: "City: Lahore",
//                     border: InputBorder.none,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),
// // Complete Home Address Field

//               Container(
//                 // padding: EdgeInsets.symmetric(horizontal: 20),
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF2B24A),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: TextFormField(
//                   controller: _addressController,
//                   // obscureText: obscure,
//                   // validator: validator,
//                   decoration: InputDecoration(
//                     hintText: "Enter address",
//                     hintStyle: const TextStyle(
//                       color: Colors.black,
//                       fontFamily: "Regular",
//                     ),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                   ),
//                 ),
//               ),

//               // Error Message (Agar city Lahore nahi hui)
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Text(_errorMessage!,
//                       style: const TextStyle(
//                           color: Colors.red,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18)),
//                 ),

//               const SizedBox(height: 20),

//               // Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Cancel"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xff3b9499),
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   ElevatedButton(
//                     child: const Text("Confirm"),
//                     onPressed: () async {
//                       String street = _addressController.text.trim();
//                       String city = _cityController.text.trim();

//                       if (street.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text("Please enter address")));
//                         return;
//                       }

//                       String fullAddress = "$street, $city";

//                       bool? confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           title: const Text("Confirm Purchase"),
//                           content: const Text(
//                               "Are you sure you want to spend these coins to purchase this product?"),
//                           actions: [
//                             TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: const Text("Cancel")),
//                             ElevatedButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: const Text("Confirm")),
//                           ],
//                         ),
//                       );

//                       if (confirm == true) {
//                         try {
//                           // 3. Database Insert
//                           await Supabase.instance.client
//                               .from('reward_claims')
//                               .insert({
//                             'user_id':
//                                 Supabase.instance.client.auth.currentUser!.id,
//                             'reward_id': widget.reward.id.toString(),
//                             'reward_title': widget.reward.title.toString(),
//                             'coins_spent': widget.reward.requiredCoins,
//                             'address': fullAddress,
//                             'status': 'pending',
//                             'parent_name': _parentNameController.text.trim(),
//                             'child_name': _childNameController.text.trim(),
//                             'phone': _phoneController.text.trim(),
//                             'email': 'user@email.com',
//                             'city': city,
//                             'created_at': DateTime.now().toIso8601String(),
//                           });

//                           // 4. Coins Deduct
//                           await context
//                               .read<RewardViewModel>()
//                               .collectReward(widget.reward);

//                           // FIX: Screen pop karne se pehle mounted check lagayein
//                           if (!mounted) return;

//                           Navigator.pop(context);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                                 content: Text("Reward Claimed Successfully!")),
//                           );
//                         } catch (e) {
//                           if (!mounted) return;
//                           print("Error: $e");
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text("Error: $e")),
//                           );
//                         }
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     // <--- '@override' lagana zaroori hai
//     _addressController.dispose();
//     _cityController.dispose();
//     _parentNameController.dispose(); // Add this
//     _childNameController.dispose(); // Add this
//     _phoneController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
// import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
// import 'package:play_craft_kids/features/rewards/viewmodel/reward_viewmodel.dart';
// import 'package:provider/provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class TrackingScreen extends StatefulWidget {
//   final dynamic reward;
//   const TrackingScreen({super.key, required this.reward});

//   @override
//   State<TrackingScreen> createState() => _TrackingScreenState();
// }

// class _TrackingScreenState extends State<TrackingScreen> {
//   final _formKey = GlobalKey<FormState>(); // Validation ke liye key

//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _cityController =
//       TextEditingController(text: "Lahore");
//   final TextEditingController _parentNameController = TextEditingController();
//   final TextEditingController _childNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   // Helper function for validation
//   String? _validateField(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Please enter $fieldName';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: double.infinity,
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage("assets/images/reward.webp"),
//           fit: BoxFit.cover,
//           colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: Form(
//           key: _formKey, // Form ko wrap kiya
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // ... Header code ...
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
//                   child: Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: SizedBox(
//                           height: 90,
//                           // width: double.infinity,
//                           child: Stack(
//                             children: [
//                               ClipPath(
//                                 clipper: AppBarClipper(),
//                                 child: Container(
//                                   height: 120,
//                                   margin: EdgeInsets.only(bottom: 10),
//                                   color: const Color(0xff3b9499),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(20.0),
//                                         child: SidebarIcon(
//                                           icon: Icons.arrow_back_rounded,
//                                           assetName:
//                                               'assets/images/pop-button.png',
//                                           onPressed: () {
//                                             Navigator.pop(context);
//                                           },
//                                         ),
//                                       ),

//                                       // Title
//                                       // Title
//                                       Expanded(
//                                         child: Center(
//                                           child: FittedBox(
//                                             fit: BoxFit.scaleDown,
//                                             child: Stack(
//                                               alignment: Alignment.center,
//                                               children: [
//                                                 // Shadow Layer
//                                                 Transform.translate(
//                                                   offset: const Offset(6, 6),
//                                                   child: Text(
//                                                     "Tracking Screen",
//                                                     textAlign: TextAlign.center,
//                                                     style: TextStyle(
//                                                       fontSize: 30,
//                                                       fontFamily: "Regular",
//                                                       fontWeight:
//                                                           FontWeight.w900,
//                                                       color: Colors.black
//                                                           .withOpacity(0.35),
//                                                       letterSpacing: 1,
//                                                     ),
//                                                   ),
//                                                 ),

//                                                 // Pink 3D Layer
//                                                 Transform.translate(
//                                                   offset: const Offset(3, 3),
//                                                   child: Text(
//                                                     "Tracking Screen",
//                                                     textAlign: TextAlign.center,
//                                                     style: const TextStyle(
//                                                       fontSize: 30,
//                                                       fontFamily: "Regular",
//                                                       fontWeight:
//                                                           FontWeight.w900,
//                                                       color: Color(0xFFFF4FA3),
//                                                       letterSpacing: 1,
//                                                     ),
//                                                   ),
//                                                 ),

//                                                 // Main White Text
//                                                 Text(
//                                                   "Tracking Screen",
//                                                   textAlign: TextAlign.center,
//                                                   style: const TextStyle(
//                                                     fontSize: 30,
//                                                     fontFamily: "Regular",
//                                                     fontWeight: FontWeight.w900,
//                                                     color: Colors.white,
//                                                     letterSpacing: 1,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),

//                                       const SizedBox(width: 60),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Text("ENTER DELIVERY DETAILS",
//                     style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff3b9499))),
//                 const SizedBox(height: 20),

//                 // Form Fields
//                 _buildTextField(
//                     _parentNameController, "Enter Parent Name", "parent name"),
//                 _buildTextField(
//                     _childNameController, "Enter Child Name", "child name"),
//                 _buildTextField(_phoneController, "Enter Phone", "phone number",
//                     isNumeric: true),
//                 _buildTextField(_cityController, "City: Lahore", "city"),
//                 _buildTextField(_addressController, "Enter address", "address"),

//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey),
//                       child: const Text("Cancel"),
//                     ),
//                     const SizedBox(width: 20),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xff3b9499)),
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           // Validation pass ho gayi
//                           bool? confirm = await _showConfirmationDialog();
//                           if (confirm == true) {
//                             _submitClaim();
//                           }
//                         }
//                       },
//                       child: const Text("Confirm"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String hint, String fieldName,
//       {bool isNumeric = false}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF2B24A),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         ),
//         validator: (value) => _validateField(value, fieldName),
//       ),
//     );
//   }

//   Future<bool?> _showConfirmationDialog() {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Confirm Purchase"),
//         content: const Text("Are you sure you want to purchase this reward?"),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text("Cancel")),
//           ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text("Confirm")),
//         ],
//       ),
//     );
//   }

//   Future<void> _submitClaim() async {
//     try {
//       await Supabase.instance.client.from('reward_claims').insert({
//         'user_id': Supabase.instance.client.auth.currentUser!.id,
//         'reward_id': widget.reward.id.toString(),
//         'reward_title': widget.reward.title.toString(),
//         'coins_spent': widget.reward.requiredCoins,
//         'address': _addressController.text.trim(),
//         'status': 'pending',
//         'parent_name': _parentNameController.text.trim(),
//         'child_name': _childNameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'city': _cityController.text.trim(),
//       });

//       await context.read<RewardViewModel>().collectReward(widget.reward);

//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Success!")));
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   void dispose() {
//     _addressController.dispose();
//     _cityController.dispose();
//     _parentNameController.dispose();
//     _childNameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter
import 'package:play_craft_kids/core/utils/custom_app_bar.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:play_craft_kids/features/rewards/viewmodel/reward_viewmodel.dart';
import 'package:play_craft_kids/shared/components/sticker_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ... (TrackingScreen class remains the same) ...

class TrackingScreen extends StatefulWidget {
  final dynamic reward;
  const TrackingScreen({super.key, required this.reward});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController =
      TextEditingController(text: "Lahore");
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  // --- UPDATED WIDGET ---
  Widget _buildTextField(
      TextEditingController controller, String hint, String fieldName,
      {bool isNumeric = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2B24A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        // Yahan input formatters add kiye gaye hain
        inputFormatters: isNumeric
            ? [
                FilteringTextInputFormatter.digitsOnly, // Sirf 0-9
                LengthLimitingTextInputFormatter(11), // Max 11 digits
              ]
            : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (value) => _validateField(value, fieldName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/reward.webp"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Header (Same as your provided code)
                  CustomAppBar(title: "Tracking Screen"),

                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Expanded(
                  //         child: SizedBox(
                  //           height: 90,
                  //           // width: double.infinity,
                  //           child: Stack(
                  //             children: [
                  //               ClipPath(
                  //                 clipper: AppBarClipper(),
                  //                 child: Container(
                  //                   height: 120,
                  //                   margin: EdgeInsets.only(bottom: 10),
                  //                   color: const Color(0xff3b9499),
                  //                   child: Row(
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.center,
                  //                     children: [
                  //                       Padding(
                  //                         padding: const EdgeInsets.all(20.0),
                  //                         child: SidebarIcon(
                  //                           icon: Icons.arrow_back_rounded,
                  //                           assetName:
                  //                               'assets/images/pop-button.png',
                  //                           onPressed: () {
                  //                             Navigator.pop(context);
                  //                           },
                  //                         ),
                  //                       ),

                  //                       // Title
                  //                       // Title
                  //                       Expanded(
                  //                         child: Center(
                  //                           child: FittedBox(
                  //                             fit: BoxFit.scaleDown,
                  //                             child: Stack(
                  //                               alignment: Alignment.center,
                  //                               children: [
                  //                                 // Shadow Layer
                  //                                 Transform.translate(
                  //                                   offset: const Offset(6, 6),
                  //                                   child: Text(
                  //                                     "Tracking Screen",
                  //                                     textAlign:
                  //                                         TextAlign.center,
                  //                                     style: TextStyle(
                  //                                       fontSize: 30,
                  //                                       fontFamily: "Regular",
                  //                                       fontWeight:
                  //                                           FontWeight.w900,
                  //                                       color: Colors.black
                  //                                           .withOpacity(0.35),
                  //                                       letterSpacing: 1,
                  //                                     ),
                  //                                   ),
                  //                                 ),

                  //                                 // Pink 3D Layer
                  //                                 Transform.translate(
                  //                                   offset: const Offset(3, 3),
                  //                                   child: Text(
                  //                                     "Tracking Screen",
                  //                                     textAlign:
                  //                                         TextAlign.center,
                  //                                     style: const TextStyle(
                  //                                       fontSize: 30,
                  //                                       fontFamily: "Regular",
                  //                                       fontWeight:
                  //                                           FontWeight.w900,
                  //                                       color:
                  //                                           Color(0xFFFF4FA3),
                  //                                       letterSpacing: 1,
                  //                                     ),
                  //                                   ),
                  //                                 ),

                  //                                 // Main White Text
                  //                                 Text(
                  //                                   "Tracking Screen",
                  //                                   textAlign: TextAlign.center,
                  //                                   style: const TextStyle(
                  //                                     fontSize: 30,
                  //                                     fontFamily: "Regular",
                  //                                     fontWeight:
                  //                                         FontWeight.w900,
                  //                                     color: Colors.white,
                  //                                     letterSpacing: 1,
                  //                                   ),
                  //                                 ),
                  //                               ],
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),

                  //                       const SizedBox(width: 60),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const Text("ENTER DELIVERY DETAILS",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff3b9499))),
                  const SizedBox(height: 20),

                  // _buildTextField(
                  //     _parentNameController, "Enter Parent Name", "parent name"),

                  _buildTextField(_parentNameController, "Enter Parent Name",
                      "parent name"),
                  _buildTextField(
                      _childNameController, "Enter Child Name", "child name"),
                  _buildTextField(_phoneController,
                      "Enter Phone (e.g. 03001234567)", "phone number",
                      isNumeric: true),
                  _buildTextField(_emailController, "Enter Email",
                      "email"), // Ye line form fields mein add kar dein
                  _buildTextField(_cityController, "City: Lahore", "city"),
                  _buildTextField(
                      _addressController, "Enter address", "address"),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff3b9499)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            bool? confirm = await _showConfirmationDialog();
                            if (confirm == true) {
                              _submitClaim();
                            }
                          }
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User bahar click karke band na kar sake
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context, false),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Dialog par click karne se band nahi hoga
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 300,
                    height: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff6EC6D0),
                      borderRadius: BorderRadius.circular(36.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E4CE),
                        borderRadius: BorderRadius.circular(26.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("CONFIRM PURCHASE",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: "Regular",
                                  color: Color(0xff3b9499))),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Are you sure you want to purchase this reward?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Regular",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff3b9499)),
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close button

                  Positioned(
                    top: -10,
                    right: -10,
                    child: StickerIconButton(
                      icon: Icons.close,
                      assetName: 'assets/images/close.png',
                      size: 48,
                      backgroundColor: Colors.white,
                      iconColor: Colors.red,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Positioned(
                  //   top: -10,
                  //   right: -10,
                  //   child: GestureDetector(
                  //     onTap: () => Navigator.pop(context, false),
                  //     child: Container(
                  //       decoration: const BoxDecoration(
                  //           color: Colors.white, shape: BoxShape.circle),
                  //       child: const Icon(Icons.close,
                  //           color: Colors.red, size: 40),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<bool?> _showConfirmationDialog() {
  //   return
  //   showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Confirm Purchase"),
  //       content: const Text("Are you sure you want to purchase this reward?"),
  //       actions: [
  //         TextButton(
  //             onPressed: () => Navigator.pop(context, false),
  //             child: const Text("Cancel")),
  //         ElevatedButton(
  //             onPressed: () => Navigator.pop(context, true),
  //             child: const Text("Confirm")),
  //       ],
  //     ),
  //   );

  // }

  Future<void> _submitClaim() async {
    try {
      await Supabase.instance.client.from('reward_claims').insert({
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'reward_id': widget.reward.id.toString(),
        'reward_title': widget.reward.title.toString(),
        'coins_spent': widget.reward.requiredCoins,
        'address': _addressController.text.trim(),
        'status': 'pending',
        'parent_name': _parentNameController.text.trim(),
        'child_name': _childNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'email': _emailController.text.trim(),
      });

      await context.read<RewardViewModel>().collectReward(widget.reward);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Success!")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _parentNameController.dispose();
    _childNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
