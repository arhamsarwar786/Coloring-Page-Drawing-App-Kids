// class RewardModel {
//   final String id;
//   final String title;
//   final int requiredCoins;
//   final String imageUrl;
//   final int stock;

//   RewardModel({
//     required this.id,
//     required this.title,
//     required this.requiredCoins,
//     required this.imageUrl,
//     required this.stock,
//   });

//   factory RewardModel.fromJson(Map<String, dynamic> json) {
//     return RewardModel(
//       id: json['id'],
//       title: json['title'],
//       requiredCoins: json['required_coins'],
//       imageUrl: json['image_url'] ?? '',
//       stock: json['stock'],
//     );
//   }
// }

class RewardModel {
  final String id;
  final String title;
  final int requiredCoins;
  final String? imageUrl;
  final int stock;

  RewardModel({
    required this.id,
    required this.title,
    required this.requiredCoins,
    this.imageUrl,
    required this.stock,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      // ID ko string mein convert karna zaroori hai
      id: json['id'].toString(),
      // Title wahi hona chahiye jo database mein hai
      title: json['title'] ?? 'No Title',
      // Yahan column ka naam 'required_coins' hona chahiye
      requiredCoins: (json['required_coins'] ?? 0) as int,
      imageUrl: json['image_url'],
      stock: (json['stock'] ?? 0) as int,
    );
    // return RewardModel(
    //   id: json['id'],
    //   title: json['title'],
    //   // requiredCoins: json['required_coins'],
    //   requiredCoins: json['required_coins'] ?? 0,
    //   imageUrl: json['image_url'] ?? "",
    //   stock: json['stock'] ?? 0,
    // );
  }
}
