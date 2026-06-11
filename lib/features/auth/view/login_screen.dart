import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:play_craft_kids/features/auth/components/custom_textfield.dart';
import 'package:play_craft_kids/features/auth/view/sign_up_screen.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/view/main_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  // Future<void> login() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => loading = true);

  //   try {
  //     final res = await supabase.auth.signInWithPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );

  //     if (res.user != null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Login Successful!")),
  //       );
  //       // Yahan aap next screen par navigate kar sakte hain
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: ${e.toString()}")),
  //     );
  //   }

  //   setState(() => loading = false);
  // }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Successful!")),
          );

          // 🚀 SUCCESS: HomeScreen par bhejein
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainHomeScreen()),
          );
        }
      }
    } on AuthException catch (e) {
      // Ye ghalat email ya password ke liye best hai
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFC2E1E6),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bgg.png"), fit: BoxFit.cover)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // SidebarIcon(
              //   icon: Icons.arrow_back_rounded,
              //   assetName: 'assets/images/pop-button.png',
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              Image.asset("assets/images/logo.png", height: 250),
              // const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4ED),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("WELCOME BACK!",
                          style: TextStyle(
                              fontFamily: "Regular",
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown)),
                      const SizedBox(height: 20),

                      /// Email Field
                      ///
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

                      /// Password Field
                      ///
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

// CustomTextField(
//                         controller: confirmPasswordController,
//                         hint: "Confirm Password",
//                         obscure: !_isConfirmPasswordVisible,
//                         validator: (val) {
//                           if (val != passwordController.text) {
//                             return "Passwords do not match";
//                           }
//                           return null;
//                         },
//                         onToggleVisibility: () {
//                           setState(() {
//                             _isConfirmPasswordVisible =
//                                 !_isConfirmPasswordVisible;
//                           });
//                         },
//                       ),

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
                                onPressed: login,
                                child: const Text("LOGIN",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Regular",
                          fontWeight: FontWeight.w500,
                          color: Colors.black)),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignupScreen()));
                    },
                    child: Text(
                      ' Sign Up',
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

  Widget _buildCustomTextField(TextEditingController controller, String hint,
      bool obscure, String? Function(String?)? validator) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2B24A),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}
