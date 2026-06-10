// // import 'package:flutter/material.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // class SignupScreen extends StatefulWidget {
// //   const SignupScreen({super.key});

// //   @override
// //   State<SignupScreen> createState() => _SignupScreenState();
// // }

// // class _SignupScreenState extends State<SignupScreen> {
// //   final emailController = TextEditingController();
// //   final passwordController = TextEditingController();

// //   bool loading = false;

// //   Future<void> signUp() async {
// //     try {
// //       setState(() => loading = true);

// //       await Supabase.instance.client.auth.signUp(
// //         email: emailController.text.trim(),
// //         password: passwordController.text.trim(),
// //       );

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Signup Successful')),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(e.toString())),
// //       );
// //     }

// //     setState(() => loading = false);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Signup")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             TextField(
// //               controller: emailController,
// //               decoration: const InputDecoration(
// //                 hintText: "Email",
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             TextField(
// //               controller: passwordController,
// //               obscureText: true,
// //               decoration: const InputDecoration(
// //                 hintText: "Password",
// //               ),
// //             ),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: loading ? null : signUp,
// //               child: const Text("Signup"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// final supabase = Supabase.instance.client;

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   bool loading = false;

//   Future<void> signup() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => loading = true);

//     final res = await supabase.auth.signUp(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );

//     if (res.user != null) {
//       // optional: save extra data (name) in table
//       await supabase.from('profiles').insert({
//         'id': res.user!.id,
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Signup Successful")),
//       );
//     }

//     setState(() => loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               /// NAME
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Name"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Name is required";
//                   }
//                   return null;
//                 },
//               ),

//               /// EMAIL
//               TextFormField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Email is required";
//                   }
//                   if (!value.contains("@")) {
//                     return "Enter valid email";
//                   }
//                   return null;
//                 },
//               ),

//               /// PASSWORD
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Password is required";
//                   }
//                   if (value.length < 6) {
//                     return "Password must be at least 6 characters";
//                   }
//                   return null;
//                 },
//               ),

//               /// CONFIRM PASSWORD
//               TextFormField(
//                 controller: confirmPasswordController,
//                 obscureText: true,
//                 decoration:
//                     const InputDecoration(labelText: "Confirm Password"),
//                 validator: (value) {
//                   if (value != passwordController.text) {
//                     return "Passwords do not match";
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 20),

//               loading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: signup,
//                       child: const Text("Signup"),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// final supabase = Supabase.instance.client;

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   bool loading = false;

//   Future<void> signup() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => loading = true);

//     final res = await supabase.auth.signUp(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );

//     if (res.user != null) {
//       await supabase.from('profiles').insert({
//         'id': res.user!.id,
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Signup Successful")),
//       );
//     }

//     setState(() => loading = false);
//   }

//   Widget customField({
//     required String hint,
//     required TextEditingController controller,
//     bool obscure = false,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xffF2B24A), // light orange style
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscure,
//         decoration: InputDecoration(
//           hintText: hint,
//           border: InputBorder.none,
//         ),
//         validator: validator,
//       ),
//     );
//   }

//   Widget actionButton(String text, Color color, VoidCallback onTap) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 14),
//         ),
//         onPressed: onTap,
//         child: Text(text),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),

//                   /// TITLE
//                   const Text(
//                     "CREATE YOUR ADVENTURE!",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   /// EMAIL
//                   customField(
//                     hint: "Parent's Email",
//                     controller: emailController,
//                     validator: (value) =>
//                         value!.isEmpty ? "Email required" : null,
//                   ),

//                   /// PASSWORD
//                   customField(
//                     hint: "Set a Password",
//                     controller: passwordController,
//                     obscure: true,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return "Password required";
//                       }
//                       if (value.length < 6) {
//                         return "Min 6 characters";
//                       }
//                       return null;
//                     },
//                   ),

//                   /// CONFIRM PASSWORD
//                   customField(
//                     hint: "Confirm Password",
//                     controller: confirmPasswordController,
//                     obscure: true,
//                     validator: (value) {
//                       if (value != passwordController.text) {
//                         return "Password not match";
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 15),

//                   /// SIGN UP BUTTON
//                   loading
//                       ? const CircularProgressIndicator()
//                       : actionButton(
//                           "SIGN UP!",
//                           const Color(0xff1DA7C7), // blue button
//                           signup,
//                         ),

//                   const SizedBox(height: 15),

//                   /// OR
//                   const Row(
//                     children: [
//                       Expanded(child: Divider()),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8),
//                         child: Text("OR"),
//                       ),
//                       Expanded(child: Divider()),
//                     ],
//                   ),

//                   const SizedBox(height: 15),

//                   /// GOOGLE BUTTON
//                   actionButton(
//                     "Continue with Google",
//                     Colors.white,
//                     () {},
//                   ),

//                   const SizedBox(height: 10),

//                   /// APPLE BUTTON
//                   actionButton(
//                     "Continue with Apple",
//                     Colors.black,
//                     () {},
//                   ),

//                   const SizedBox(height: 20),

//                   /// LOGIN TEXT
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Already an Explorer? "),
//                       GestureDetector(
//                         onTap: () {},
//                         child: const Text(
//                           "LOGIN",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/features/auth/components/custom_textfield.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
import 'package:play_craft_kids/features/home/view/main_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Future<void> signup() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => loading = true);

  //   final res = await supabase.auth.signUp(
  //     email: emailController.text.trim(),
  //     password: passwordController.text.trim(),
  //   );

  //   if (res.user != null) {
  //     await supabase.from('profiles').insert({
  //       'id': res.user!.id,
  //       'name': nameController.text.trim(),
  //       'email': emailController.text.trim(),
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Signup Successful")),
  //     );
  //   }

  //   setState(() => loading = false);
  // }

  // Future<void> signup() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => loading = true);

  //   try {
  //     final res = await supabase.auth.signUp(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );

  //     // 🔥 TOKEN AUR USER CHECK
  //     if (res.session != null) {
  //       print("✅ Token mil gaya: ${res.session!.accessToken}");
  //       print("👤 User ID: ${res.user!.id}");
  //     }

  //     if (res.user != null) {
  //       await supabase.from('profiles').insert({
  //         'id': res.user!.id,
  //         'name': nameController.text.trim(),
  //         'email': emailController.text.trim(),
  //       });

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Signup Successful")),
  //         );

  //         // 🚀 NEXT SCREEN PAR MOVE KAREIN
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) =>
  //                   MainHomeScreen()), // Yahan apni HomeScreen ka naam likhein
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Error: $e"); // Agar error aaya toh console mein dikh jayega
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: ${e.toString()}")),
  //     );
  //   }

  //   setState(() => loading = false);
  // }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        // Profile insert
        await supabase.from('profiles').insert({
          'id': res.user!.id,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup Successful!")),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainHomeScreen(),
            ),
            (route) => false,
          );
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => MainHomeScreen()),
          // );
        }
      }
    } on AuthException catch (e) {
      // Ye Auth (Login/Signup) ke errors hain (e.g., Email already exists)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}")),
      );
    } on PostgrestException catch (e) {
      // Ye Database (profiles table) ke errors hain
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Error: ${e.message}")),
      );
    } catch (e) {
      // Network ya baki koi bhi random error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFC2E1E6), // Background color
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bgg.png"), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 250,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4ED), // Panel color
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("CREATE YOUR ADVENTURE!",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                      const SizedBox(height: 20),

                      /// CustomTextFields integrate kar diye hain
                      // _buildCustomTextField(
                      //     nameController, "Name", false, null),
                      // _buildCustomTextField(
                      //     emailController,
                      //     "Email",
                      //     false,
                      //     (val) =>
                      //         val!.contains("@") ? null : "Enter valid email"),
                      // _buildCustomTextField(
                      //     passwordController,
                      //     "Set a Password",
                      //     true,
                      //     (val) => val!.length >= 6 ? null : "Min 6 chars"),
                      // _buildCustomTextField(
                      //     confirmPasswordController,
                      //     "Confirm Password",
                      //     true,
                      //     (val) => val == passwordController.text
                      //         ? null
                      //         : "Passwords do not match"),
                      CustomTextField(
                        obscure: false,
                        controller: emailController,
                        hint: "Email",
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Email is required";
                          }

                          if (!val.contains("@")) {
                            return "Enter valid email";
                          }

                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: passwordController,
                        hint: "Password",
                        obscure: !_isPasswordVisible,
                        validator: (val) =>
                            val!.isNotEmpty ? null : "Password required",
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),

                      CustomTextField(
                        controller: confirmPasswordController,
                        hint: "Confirm Password",
                        obscure: !_isConfirmPasswordVisible,
                        validator: (val) {
                          if (val != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1EA7C7),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: signup,
                                child: const Text("SIGN UP!",
                                    style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: Colors.white,
                                        fontSize: 16)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      //  Color.fromARGB(255, 68, 152, 207),
                      shadows: const [
                        Shadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 1)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => LoginScreen()));
                    },
                    child: Text(
                      ' Login',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 68, 152, 207),
                        shadows: const [
                          Shadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Aapka CustomTextField design jo logic ke sath attach ho gaya hai
  // Widget _buildCustomTextField(TextEditingController controller, String hint,
  //     bool obscure, String? Function(String?)? validator) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 8),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFF2B24A), // Field Orange Color
  //       borderRadius: BorderRadius.circular(30),
  //     ),
  //     child: TextFormField(
  //       controller: controller,
  //       obscureText: obscure,
  //       validator: validator,
  //       decoration: InputDecoration(
  //         hintText: hint,
  //         hintStyle: const TextStyle(color: Colors.white),
  //         border: InputBorder.none,
  //         contentPadding:
  //             const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
  //       ),
  //     ),
  //   );
  // }
}

// final _formKey = GlobalKey<FormState>();
// final emailController = TextEditingController();
// final passwordController = TextEditingController();
// // final supabase = Supabase.instance.client;

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     // backgroundColor: kBackgroundColor,
//     body: SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               // decoration: BoxDecoration(color: kFormPanelColor, borderRadius: BorderRadius.circular(25)),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     const Text("CREATE YOUR ADVENTURE!",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         )),
//                     CustomTextField(
//                       controller: emailController,
//                       hintText: "Parent's Email",
//                       icon: Icons.email_rounded,
//                     ),

//                     /// Password field
//                     CustomTextField(
//                       controller: passwordController,
//                       hintText: "Set a Password",
//                       obscureText: true,
//                       icon: Icons.lock_rounded,
//                     ),

//                     // CustomField(hint: "Parent's Email", icon: Icons.email_rounded, controller: emailController),
//                     // CustomField(hint: "Set a Password", icon: Icons.lock_rounded, controller: passwordController, obscure: true),
//                     // ActionButton(text: "SIGN UP!", backgroundColor: kButtonPrimaryColor, textColor: Colors.white, onTap: () {}),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             // ActionButton(text: "Continue with Google", backgroundColor: Colors.white, textColor: Colors.black87, prefixIcon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20), onTap: () {}),
//           ],
//         ),
//       ),
//     ),
//   );
// }
