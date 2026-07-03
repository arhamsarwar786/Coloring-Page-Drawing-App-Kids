import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:play_craft_kids/app/config/app_config.dart';
import 'package:play_craft_kids/features/auth/components/custom_textfield.dart';
import 'package:play_craft_kids/features/auth/view/login_screen.dart';
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

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        emailRedirectTo:
            kIsWeb ? Uri.base.origin : AppConfig.emailVerificationRedirectUrl,
      );

      if (res.user != null) {
        await _addSignupCoins(res.user!.id);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "VERIFY YOUR EMAIL",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Regular",
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              content: const Text(
                "We have sent a verification link to your email. Please check your inbox and verify your email to activate your account.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Regular",
                  color: Colors.black87,
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1EA7C7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to login screen
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontFamily: "Regular",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}")),
      );
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Error: ${e.message}")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _addSignupCoins(String userId) async {
    const signupCoins = 50;
    final createdAt = DateTime.now().toIso8601String();

    try {
      final existingCoins = await supabase
          .from('user_coins')
          .select('coins')
          .eq('user_id', userId)
          .maybeSingle();

      if (existingCoins != null) return;

      await Future.wait([
        supabase.from('coin_history').insert({
          'user_id': userId,
          'amount': signupCoins,
          'description': 'Signup Bonus',
          'type': 'bonus',
          'created_at': createdAt,
        }),
        supabase.from('user_coins').insert({
          'user_id': userId,
          'coins': signupCoins,
          'updated_at': createdAt,
        }),
      ]);
    } catch (e) {
      debugPrint("Signup coins error: $e");
    }
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
              // const SizedBox(height: 20),
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
                              fontFamily: "Regular",
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

                          if (!val.contains("@gmail.com")) {
                            return "Enter valid email";
                          }

                          return null;
                        },
                      ),

                      CustomTextField(
                        controller: passwordController,
                        hint: "Password",
                        obscure: !_isPasswordVisible,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Password required";
                          } else if (val.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null; // Sab theek hai
                        },
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        // validator: (val) =>
                        //     val!.isNotEmpty ? null : "Password required",
                        // onToggleVisibility: () {
                        //   setState(() {
                        //     _isPasswordVisible = !_isPasswordVisible;
                        //   });
                        // },
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
                                        fontFamily: "Regular",
                                        color: Colors.white,
                                        fontSize: 16)),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment
                    .center, // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Regular",
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
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Regular",
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
