import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://skywvbfwotpxlwiglxpl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNreXd2YmZ3b3RweGx3aWdseHBsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMDI3NDUsImV4cCI6MjA5NjU3ODc0NX0.8c70N43kzT9szn2zmXSn2lT15kRlxhEcoJ05rZqDkBs',
  );

  runApp(const MyApp());
}

class MyApp extends AsmrDrawingApp {
  const MyApp({super.key});
}
