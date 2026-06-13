// // lib/models/coin_history.dart

// class CoinHistory {
//   final String description; // e.g., "Level Completion", "Bonus"

//   final int amount;

//   final int type; // 0 for Level, 1 for Bonus, 2 for Others

//   final DateTime date;

//   CoinHistory(
//       {required this.description,
//       required this.amount,
//       required this.type,
//       required this.date});

//   // Supabase se data fetch karne ke liye factory method

//   factory CoinHistory.fromJson(Map<String, dynamic> json) {
//     return CoinHistory(
//       description: json['description'] ?? '',
//       amount: json['amount'] ?? 0,
//       type: json['type'] ?? 0,
//       date: DateTime.parse(json['created_at']),
//     );
//   }
// }

class CoinHistory {
  final String description;
  final int amount; // Database mein yeh 'coins' column hai
  final String type; // Database mein humne TEXT rakha tha
  final DateTime date;

  CoinHistory(
      {required this.description,
      required this.amount,
      required this.type,
      required this.date});

  // factory CoinHistory.fromJson(Map<String, dynamic> json) {
  //   return CoinHistory(
  //     description: json['description'] ?? 'No Description',
  //     amount: json['amount'] ?? 0, // 'coins' ki jagah 'amount' karein
  //     type: json['type'] ?? 'general',
  //     date: DateTime.parse(json['created_at'] ??
  //         DateTime.now()
  //             .toIso8601String()), // 'updated_at' ki jagah 'created_at'
  //   );
  // }

  factory CoinHistory.fromJson(Map<String, dynamic> json) {
    int rawAmount = json['amount'] ?? 0;
    String desc = json['description'] ?? 'No Description';

    // Auto-fix purane galat amounts jo total sum save ho gaye the
    int sanitizedAmount = rawAmount;
    if (desc.contains('Welcome')) {
      sanitizedAmount = 50;
    } else if (desc.contains('Level')) {
      sanitizedAmount = 20;
    } else if (desc.contains('Daily') || desc.contains('Bonus')) {
      sanitizedAmount = 10;
    }

    return CoinHistory(
      description: desc,
      amount: sanitizedAmount, // Sahi amount use karein
      type: json['type'] ?? 'general',
      date: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
