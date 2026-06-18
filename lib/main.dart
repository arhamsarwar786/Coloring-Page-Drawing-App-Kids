import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://skywvbfwotpxlwiglxpl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNreXd2YmZ3b3RweGx3aWdseHBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMDI3NDUsImV4cCI6MjA5NjU3ODc0NX0.8c70N43kzT9szn2zmXSn2lT15kRlxhEcoJ05rZqDkBs',
  );

  runApp(const MyApp());
}

// class MyApp extends AsmrDrawingApp {
//   const MyApp({super.key});
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit ko yahan wrap karein
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Apne design ka standard size likhein
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const AsmrDrawingApp();
        // return MaterialApp(
        //   debugShowCheckedModeBanner: false,
        //   home: child,
        // );
      },
      // child: const AsmrDrawingApp(),
    );
  }
}

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
