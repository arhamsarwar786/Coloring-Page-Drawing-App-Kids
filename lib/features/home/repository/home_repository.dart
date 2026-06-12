// import '../../../shared/services/local_content_service.dart';
// import '../model/category_model.dart';

// abstract class HomeRepository {
//   Future<HomeContentModel> loadHomeContent();
//   Future<String?> getLaunchLevelId();
//   Future<void> saveLastPlayedLevel(String levelId);
//   Future<String?> getLastPlayedLevelId();

//   /// Points persistence
//   Future<int> getPoints();
//   Future<void> savePoints(int points);

//   /// Daily bonus & streak
//   Future<String?> getLastDailyBonusDate();
//   Future<void> saveLastDailyBonusDate(String date);
//   Future<int> getCurrentStreak();
//   Future<void> saveCurrentStreak(int streak);
// }

// class HomeRepositoryImpl implements HomeRepository {
//   HomeRepositoryImpl({
//     required LocalContentService contentService,
//   }) : _contentService = contentService;

//   final LocalContentService _contentService;

//   @override
//   Future<HomeContentModel> loadHomeContent() {
//     return _contentService.loadHomeContent();
//   }

//   @override
//   Future<String?> getLaunchLevelId() {
//     return _contentService.getLaunchLevelId();
//   }

//   @override
//   Future<void> saveLastPlayedLevel(String levelId) {
//     return _contentService.saveLastPlayedLevel(levelId);
//   }

//   @override
//   Future<String?> getLastPlayedLevelId() {
//     return _contentService.getLastPlayedLevelId();
//   }

//   @override
//   Future<int> getPoints() {
//     return _contentService.getPoints();
//   }

//   @override

//   // Repository mein update

//   // class HomeRepositoryImpl implements HomeRepository {
//   // @override
//   Future<void> savePoints(int points, String description, String type) async {
//     return _contentService.savePoints(points, description, type);
//   }
// // }
// // Future<void> savePoints(int points, String description, String type) {
// //   print("--- STEP 1: Repository.savePoints called with: $points ---");
// //   // Yahan se bhi description aur type pass karna zaroori hai
// //   return _contentService.savePoints(points, description, type);
// // }
//   // Future<void> savePoints(int points) {
//   //   print("--- STEP 1: Repository.savePoints called with: $points ---");
//   //   return _contentService.savePoints(points);
//   // }

//   @override
//   Future<String?> getLastDailyBonusDate() {
//     return _contentService.getLastDailyBonusDate();
//   }

//   @override
//   Future<void> saveLastDailyBonusDate(String date) {
//     return _contentService.saveLastDailyBonusDate(date);
//   }

//   @override
//   Future<int> getCurrentStreak() {
//     return _contentService.getCurrentStreak();
//   }

//   @override
//   Future<void> saveCurrentStreak(int streak) {
//     return _contentService.saveCurrentStreak(streak);
//   }
// }

import 'package:play_craft_kids/features/home/model/category_model.dart';
import 'package:play_craft_kids/shared/services/local_content_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HomeRepository {
  Future<HomeContentModel> loadHomeContent();
  Future<String?> getLaunchLevelId();
  Future<void> saveLastPlayedLevel(String levelId);
  Future<String?> getLastPlayedLevelId();

  /// Points persistence - Yahan 3 arguments add karein
  Future<int> getPoints();
  Future<void> savePoints(int points, String description, String type);

  /// Daily bonus & streak
  Future<String?> getLastClaimedDate();
  Future<void> saveDailyBonus(String date, int newStreak);
  Future<String?> getLastDailyBonusDate();
  Future<void> saveLastDailyBonusDate(String date);
  Future<int> getCurrentStreak();
  Future<void> saveCurrentStreak(int streak);
}

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required LocalContentService contentService,
  }) : _contentService = contentService;

  final LocalContentService _contentService;

  @override
  Future<HomeContentModel> loadHomeContent() {
    return _contentService.loadHomeContent();
  }

  @override
  Future<String?> getLaunchLevelId() {
    return _contentService.getLaunchLevelId();
  }

  @override
  Future<void> saveLastPlayedLevel(String levelId) {
    return _contentService.saveLastPlayedLevel(levelId);
  }

  @override
  Future<String?> getLastPlayedLevelId() {
    return _contentService.getLastPlayedLevelId();
  }

  @override
  Future<int> getPoints() {
    return _contentService.getPoints();
  }

  @override
  Future<void> savePoints(int points, String description, String type) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Balance update
    await Supabase.instance.client.from('user_coins').upsert({
      'user_id': userId,
      'coins': points,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');

    // 2. History insert
    await Supabase.instance.client.from('coin_history').insert({
      'user_id': userId,
      'amount': points,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 3. Bonus Logic: Agar "Automatic Daily Bonus" hai, toh log update karein
    if (description == 'Automatic Daily Bonus') {
      String today = DateTime.now().toIso8601String().split('T')[0];
      // Yahan ab error nahi aayega kyunki ye method is class mein define hai
      await saveDailyBonus(today, 1);
    }
  }

// Ensure ye method implementation mein zaroor ho

  @override
  Future<void> saveDailyBonus(String date, int newStreak) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // Sirf YYYY-MM-DD ka part nikalna
    String dateOnly = date.split('T')[0];

    try {
      await Supabase.instance.client.from('daily_bonus_logs').upsert({
        'user_id': userId,
        'last_claimed_date': dateOnly, // Yahan sirf dateOnly bhejein
        'current_streak': newStreak,
      }, onConflict: 'user_id');
      print("Bonus log success!");
    } catch (e) {
      print("Error saving bonus log: $e");
    }
  }
  // @override
  // Future<void> saveDailyBonus(String date, int newStreak) async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   try {
  //     // Ye line confirm karein ke column names sahi hain (user_id, last_claimed_date, current_streak)
  //     await Supabase.instance.client.from('daily_bonus_logs').upsert({
  //       'user_id': userId,
  //       'last_claimed_date': date, // Ye format '2026-06-12' hona chahiye
  //       'current_streak': newStreak,
  //     }, onConflict: 'user_id');
  //     print("Bonus log success!");
  //   } catch (e) {
  //     print("Error saving bonus log: $e"); // Debug console mein check karein
  //   }
  // }

  // @override
  // Future<void> saveDailyBonus(String date, int newStreak) async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   await Supabase.instance.client.from('daily_bonus_logs').upsert({
  //     'user_id': userId,
  //     'last_claimed_date': date,
  //     'current_streak': newStreak,
  //   }, onConflict: 'user_id');
  // }

  // @override
  // Future<void> savePoints(int points, String description, String type) async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return;

  //   // 1. Balance update (user_coins table mein update)
  //   await Supabase.instance.client.from('user_coins').upsert({
  //     'user_id': userId,
  //     'coins': points,
  //     'updated_at': DateTime.now().toIso8601String(),
  //   }, onConflict: 'user_id');

  //   // 2. History insert (coin_history table mein entry)
  //   // Isse aapka Coins History page sahi dikhega

  //   await Supabase.instance.client.from('coin_history').insert({
  //     'user_id': userId,
  //     'amount': points, // Yahan total coins ya change amount jayega
  //     'description': description, // "Level Completion" ya "Daily Bonus"
  //     'created_at': DateTime.now().toIso8601String(),
  //   });
  //   // await Supabase.instance.client.from('coin_history').insert({
  //   //   'user_id': userId,
  //   //   'amount': points,
  //   //   'description': description,
  //   //   'created_at': DateTime.now().toIso8601String(),
  //   // });

  //   // Local service ko bhi update rakhein (agar zaroori ho)
  //   return _contentService.savePoints(points, description, type);
  // }

  // Future<void> savePoints(int points, String description, String type) async {
  //   print("--- STEP 1: Repository.savePoints called with: $points ---");
  //   return _contentService.savePoints(points, description, type);
  // }

  @override
  Future<String?> getLastDailyBonusDate() {
    return _contentService.getLastDailyBonusDate();
  }

  @override
  Future<void> saveLastDailyBonusDate(String date) {
    return _contentService.saveLastDailyBonusDate(date);
  }

  @override
  Future<int> getCurrentStreak() {
    return _contentService.getCurrentStreak();
  }

  @override
  Future<void> saveCurrentStreak(int streak) {
    return _contentService.saveCurrentStreak(streak);
  }

  @override
  Future<String?> getLastClaimedDate() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('daily_bonus_logs')
        .select('last_claimed_date')
        .eq('user_id', userId)
        .maybeSingle();

    // Yahan check karein ke data aa raha hai ya nahi
    print("DB Se mili date: ${response?['last_claimed_date']}");

    return response?['last_claimed_date']?.toString();
  }

  // @override
  // Future<String?> getLastClaimedDate() async {
  //   final userId = Supabase.instance.client.auth.currentUser?.id;
  //   if (userId == null) return null;

  //   final response = await Supabase.instance.client
  //       .from('daily_bonus_logs')
  //       .select('last_claimed_date')
  //       .eq('user_id', userId)
  //       .maybeSingle();

  //   return response?['last_claimed_date'] as String?;
  // }

//   @override
// Future<void> saveDailyBonus(String date, int newStreak) async {
//   final userId = Supabase.instance.client.auth.currentUser?.id;
//   if (userId == null) return;

//   await Supabase.instance.client.from('daily_bonus_logs').upsert({
//     'user_id': userId,
//     'last_claimed_date': date,
//     'current_streak': newStreak,
//   }, onConflict: 'user_id');
// }

//   // Future<void> saveDailyBonus(String date, int newStreak) async {
//   //   final userId = Supabase.instance.client.auth.currentUser?.id;
//   //   if (userId == null) return;

//   //   await Supabase.instance.client.from('daily_bonus_logs').upsert({
//   //     'user_id': userId,
//   //     'last_claimed_date': date,
//   //     'current_streak': newStreak,
//   //   });
//   // }
}
