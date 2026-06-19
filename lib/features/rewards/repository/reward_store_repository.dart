import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/reward_model.dart';

class RewardStoreRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sare rewards fetch karne ke liye
  Future<List<RewardModel>> getRewards() async {
    try {
      // .select() ka matlab hai sab kuch le aao
      final response = await _supabase.from('rewards_catalog').select('*');

      // Print karke dekhein console mein kya aa raha hai
      print("Database Response: $response");

      final List<dynamic> data = response as List;
      return data.map((e) => RewardModel.fromJson(e)).toList();
    } catch (e) {
      print("Repository Error: $e");
      return [];
    }
  }

  // Future<List<RewardModel>> getRewards() async {
  //   final response =
  //       await _supabase.from('rewards_catalog').select().eq('is_active', true);
  //   print("Database se kya aaya: $response");
  //   return (response as List).map((e) => RewardModel.fromJson(e)).toList();
  // }

  // Reward claim karne ke liye RPC call
  Future<void> redeemReward(Map<String, dynamic> data) async {
    await _supabase.rpc('redeem_reward', params: data);
  }
}
