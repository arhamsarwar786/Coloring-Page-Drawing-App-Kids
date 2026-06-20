import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/base/base_viewmodel.dart';
import '../../levels/repository/level_repository.dart';

class RewardViewModel extends BaseViewModel {
  RewardViewModel({
    required LevelRepository repository,
  }) : _repository = repository {
    load();
  }

  final LevelRepository _repository;
  final SupabaseClient _supabase =
      Supabase.instance.client; // Supabase client access

  int _coins = 0;
  int _completedLevels = 0;

  int get coins => _coins;
  int get completedLevels => _completedLevels;

  Future<void> load() async {
    setLoading(true);

    // 1. Levels se sirf completed levels count lein
    final levels = await _repository.getAllLevels();
    _completedLevels = levels.where((level) => level.isCompleted).length;

    // 2. Real-time balance ke liye Supabase se coins fetch karein
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await _supabase
            .from('user_coins')
            .select('coins')
            .eq('user_id', userId)
            .single();

        _coins = response['coins'] as int;
      }
    } catch (e) {
      // Agar DB se load na ho sake toh purane method par fallback karein
      _coins = levels
          .where((level) => level.isCompleted)
          .fold<int>(0, (sum, level) => sum + level.rewardCoins);
    }

    setLoading(false);
  }

  Future<void> collectReward(dynamic reward) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final newBalance = _coins - (reward.requiredCoins as int);

      // 1. Coins update
      await Supabase.instance.client
          .from('user_coins')
          .update({'coins': newBalance}).eq('user_id', userId);

      // 2. Sirf coin_history mein record daalein (table error nahi aayega)
      await Supabase.instance.client.from('coin_history').insert({
        'user_id': userId,
        'amount': -(reward.requiredCoins as int), // Negative amount
        'description': 'Claimed: ${reward.title}',
        'created_at': DateTime.now().toIso8601String(),
      });

      _coins = newBalance;
      notifyListeners();
    } catch (e) {
      print("Error: $e");
    }
  }
}
