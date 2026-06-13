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
    return CoinHistory(
      description: json['description'] ?? 'No Description',
      amount: json['amount'] ?? 0, // Table mein column 'amount' hai
      type: json['type'] ?? 'general',
      date: DateTime.parse(json['created_at'] ??
          DateTime.now().toIso8601String()), // 'created_at' use karein
    );
  }
}
