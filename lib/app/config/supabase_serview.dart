// import 'package:supabase_flutter/supabase_flutter.dart';

// class AppService {
//   final client = Supabase.instance.client;

//   Future<List<dynamic>> getCategories() async {
//     final data = await client.from('categories').select();
//     return data;
//   }
// }

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// 🔥 STEP 2: SAVE COINS
// Future<void> saveCoins(String userId, int coins) async {
//   await supabase.from('user_coins').upsert({
//     'user_id': userId,
//     'coins': coins,
//     'updated_at': DateTime.now().toIso8601String(),
//   });
// }

// Future<int> loadCoins(String userId) async {
//   final data = await supabase
//       .from('user_coins')
//       .select('coins')
//       .eq('user_id', userId)
//       .maybeSingle();

//   return data?['coins'] ?? 0;
// }
