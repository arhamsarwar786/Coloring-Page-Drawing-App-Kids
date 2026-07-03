// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'app/app.dart'; // Ensure this points to where AsmrDrawingApp is defined

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await Supabase.initialize(
//       url: 'https://sayjckdxhzigfuplwhvv.supabase.co',
//       anonKey:
//           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNheWpja2R4aHppZ2Z1cGx3aHZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NTA4ODMsImV4cCI6MjA5ODEyNjg4M30.QKlogPiXnDL7opX7ScZPQj5MqFM1Kw-SGE1OALsfY5E"
//       // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNreXd2YmZ3b3RweGx3aWdseHBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMDI3NDUsImV4cCI6MjA5NjU3ODc0NX0.8c70N43kzT9szn2zmXSn2lT15kRlxhEcoJ05rZqDkBs',
//       );

//   final appLinks = AppLinks();
// //  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   // Yahan add karein:
//   appLinks.uriLinkStream.listen((Uri uri) {
//     debugPrint("DEEP LINK RECEIVED: $uri");

//     // Ye line bahut zaroori hai, ye token extract karke verify karegi
//     Supabase.instance.client.auth.getSessionFromUrl(uri);
//   });
//   // final appLinks = AppLinks();

//   // appLinks.uriLinkStream.listen((Uri uri) {
//   //   debugPrint("DEEP LINK RECEIVED: $uri");
//   // });

//   runApp( MyApp());
// }

// class MyApp extends StatelessWidget {
//   // const MyApp({super.key});
//    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return AsmrDrawingApp(navigatorKey: navigatorKey);
//         // Yahan se hum AuthWrapper ko call karenge
//         // return const AuthWrapper();
//       },
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {

//   @override
// void initState() {
//   super.initState();

//   // Verification link aur login change ko handle karne ke liye listener
//   Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//     final event = data.event;
//     final session = data.session;

//     if (event == AuthChangeEvent.signedIn && session != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         print("User successfully verified, redirecting to home...");

//         // NOTE: Yahan '/home' ki jagah apni main screen ka route name dein
//         // Agar aapke pass route name nahi hai, toh check karein AppRoutes mein kya hai
//         navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
//       });
//     }
//   });
// }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   // Verification link handle karne ke liye listener
//   //   Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//   //     final event = data.event;
//   //     final session = data.session;

//   //     if (event == AuthChangeEvent.signedIn && session != null) {
//   //       // Ye command ensure karti hai ke UI build hone ke baad navigate ho
//   //       WidgetsBinding.instance.addPostFrameCallback((_) {
//   //         print("User successfully verified, redirecting to home...");

//   //         // '/home' ki jagah apni main screen ka sahi route name dein

//   //         // Navigator.of(context)
//   //         //     .pushNamedAndRemoveUntil('/home', (route) => false);
//   //       });
//   //     }
//   //     // if (event == AuthChangeEvent.signedIn) {
//   //     //   print("User successfully verified and signed in!");

//   //     //   Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
//   //     //   // Yahan aap navigator laga sakti hain
//   //     // }
//   //   });

//   // }

//   @override
//   Widget build(BuildContext context) {
//     // Ye aapka original AsmrDrawingApp load karega
//     return const AsmrDrawingApp();
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/config/app_config.dart';
import 'app/app.dart';
import 'app/routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.mainHome,
            (route) => false,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => AsmrDrawingApp(navigatorKey: navigatorKey),
    );
  }
}

// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'app/app.dart';

// // --- YAHAN DEKHEIN: navigatorKey ko yahan Global banaya hai ---
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.landscapeLeft,
//     DeviceOrientation.landscapeRight,
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   await Supabase.initialize(
//     url: 'https://sayjckdxhzigfuplwhvv.supabase.co',
//     anonKey:
//         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNheWpja2R4aHppZ2Z1cGx3aHZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NTA4ODMsImV4cCI6MjA5ODEyNjg4M30.QKlogPiXnDL7opX7ScZPQj5MqFM1Kw-SGE1OALsfY5E",
//   );

//   final appLinks = AppLinks();
//   appLinks.uriLinkStream.listen((Uri uri) {
//     debugPrint("DEEP LINK RECEIVED: $uri");
//     Supabase.instance.client.auth.getSessionFromUrl(uri);
//   });

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(360, 690),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         // AsmrDrawingApp mein Global navigatorKey pass kar rahe hain
//         return AsmrDrawingApp(navigatorKey: navigatorKey);
//       },
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   @override
//   void initState() {
//     super.initState();

//     // Global navigatorKey yahan direct access ho rahi hai
//     Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//       final event = data.event;
//       final session = data.session;

//       if (event == AuthChangeEvent.signedIn && session != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           print("User successfully verified, redirecting to home...");

//           // '/home' ki jagah wo route name rakhein jo aapke AppRoutes mein hai
//           navigatorKey.currentState
//               ?.pushNamedAndRemoveUntil('/home', (route) => false);
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const AsmrDrawingApp();
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Sizer ko root par rakhein taake .h aur .w crash na ho
//     return Sizer(
//       builder: (context, orientation, deviceType) {
//         // Wrap the app in MediaQuery to apply global text scaling
//         return MediaQuery(
//           data: MediaQuery.of(context).copyWith(
//             textScaler: const TextScaler.linear(0.9),
//           ),
//           child: const AsmrDrawingApp(),
//         );
//       },
//     );
//   }
// }

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   @override
//   void initState() {
//     super.initState();

//     // Ye listener handle karega jab user email link click karke wapis app mein aayega
//     Supabase.instance.client.auth.onAuthStateChange.listen((data) {
//       final event = data.event;
//       if (event == AuthChangeEvent.signedIn) {
//         print("User successfully verified and signed in!");
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const AsmrDrawingApp();
//   }
// }
