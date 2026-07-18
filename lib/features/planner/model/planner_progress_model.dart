class PlannerProgressModel {
  const PlannerProgressModel({
    this.introSeen = false,
    this.unlockCelebrationSeen = false,
    this.lastKnownCompletedCount = 0,
  });

  static const int unlockThreshold = 5;

  final bool introSeen;
  final bool unlockCelebrationSeen;
  final int lastKnownCompletedCount;

  factory PlannerProgressModel.fromJson(Map<String, dynamic> json) {
    return PlannerProgressModel(
      introSeen: json['introSeen'] as bool? ?? false,
      unlockCelebrationSeen: json['unlockCelebrationSeen'] as bool? ?? false,
      lastKnownCompletedCount:
          (json['lastKnownCompletedCount'] as num?)?.toInt() ?? 0,
    );
  }

  PlannerProgressModel copyWith({
    bool? introSeen,
    bool? unlockCelebrationSeen,
    int? lastKnownCompletedCount,
  }) {
    return PlannerProgressModel(
      introSeen: introSeen ?? this.introSeen,
      unlockCelebrationSeen:
          unlockCelebrationSeen ?? this.unlockCelebrationSeen,
      lastKnownCompletedCount:
          lastKnownCompletedCount ?? this.lastKnownCompletedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'introSeen': introSeen,
      'unlockCelebrationSeen': unlockCelebrationSeen,
      'lastKnownCompletedCount': lastKnownCompletedCount,
    };
  }
}

enum PlannerPdfFormat {
  a4,
  usLetter,
}

extension PlannerPdfFormatX on PlannerPdfFormat {
  String get assetFileName {
    switch (this) {
      case PlannerPdfFormat.a4:
        return 'PlayCraft_Kids_Hyperlinked_Planner_A4.pdf';
      case PlannerPdfFormat.usLetter:
        return 'PlayCraft_Kids_Hyperlinked_Planner_US_Letter.pdf';
    }
  }

  String get downloadFileName {
    switch (this) {
      case PlannerPdfFormat.a4:
        return 'PlayCraft_Kids_Planner_A4.pdf';
      case PlannerPdfFormat.usLetter:
        return 'PlayCraft_Kids_Planner_US_Letter.pdf';
    }
  }

  String get label {
    switch (this) {
      case PlannerPdfFormat.a4:
        return 'A4 (International)';
      case PlannerPdfFormat.usLetter:
        return 'US Letter';
    }
  }

  String get shortLabel {
    switch (this) {
      case PlannerPdfFormat.a4:
        return 'A4';
      case PlannerPdfFormat.usLetter:
        return 'US Letter';
    }
  }
}
