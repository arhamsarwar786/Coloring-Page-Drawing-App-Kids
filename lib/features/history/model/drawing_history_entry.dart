import 'dart:convert';

import '../../drawing/model/drawing_session_snapshot.dart';

enum DrawingHistoryStatus {
  inProgress,
  completed;

  String get value {
    switch (this) {
      case DrawingHistoryStatus.inProgress:
        return 'in_progress';
      case DrawingHistoryStatus.completed:
        return 'completed';
    }
  }

  String get label {
    switch (this) {
      case DrawingHistoryStatus.inProgress:
        return 'In Progress';
      case DrawingHistoryStatus.completed:
        return 'Completed';
    }
  }

  static DrawingHistoryStatus fromValue(String? value) {
    switch (value) {
      case 'completed':
        return DrawingHistoryStatus.completed;
      case 'in_progress':
      default:
        return DrawingHistoryStatus.inProgress;
    }
  }
}

class DrawingHistoryEntry {
  const DrawingHistoryEntry({
    required this.id,
    required this.levelId,
    required this.levelTitle,
    required this.levelNumber,
    required this.progress,
    required this.status,
    required this.lastEditedAt,
    required this.snapshot,
    this.thumbnailBase64,
  });

  final String id;
  final String levelId;
  final String levelTitle;
  final int? levelNumber;
  final double progress;
  final DrawingHistoryStatus status;
  final DateTime lastEditedAt;
  final String? thumbnailBase64;
  final DrawingSessionSnapshot snapshot;

  bool get isCompleted => status == DrawingHistoryStatus.completed;
  bool get hasThumbnail =>
      thumbnailBase64 != null && thumbnailBase64!.trim().isNotEmpty;

  DrawingHistoryEntry copyWith({
    String? id,
    String? levelId,
    String? levelTitle,
    int? levelNumber,
    double? progress,
    DrawingHistoryStatus? status,
    DateTime? lastEditedAt,
    String? thumbnailBase64,
    bool clearThumbnail = false,
    DrawingSessionSnapshot? snapshot,
  }) {
    return DrawingHistoryEntry(
      id: id ?? this.id,
      levelId: levelId ?? this.levelId,
      levelTitle: levelTitle ?? this.levelTitle,
      levelNumber: levelNumber ?? this.levelNumber,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      thumbnailBase64:
          clearThumbnail ? null : thumbnailBase64 ?? this.thumbnailBase64,
      snapshot: snapshot ?? this.snapshot,
    );
  }

  List<int>? decodeThumbnail() {
    final raw = thumbnailBase64;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'levelId': levelId,
      'levelTitle': levelTitle,
      'levelNumber': levelNumber,
      'progress': progress,
      'status': status.value,
      'lastEditedAt': lastEditedAt.toIso8601String(),
      'thumbnailBase64': thumbnailBase64,
      'snapshot': snapshot.toJson(),
    };
  }

  factory DrawingHistoryEntry.fromJson(Map<String, dynamic> json) {
    return DrawingHistoryEntry(
      id: json['id'] as String? ?? '',
      levelId: json['levelId'] as String? ?? '',
      levelTitle: json['levelTitle'] as String? ?? '',
      levelNumber: (json['levelNumber'] as num?)?.toInt(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      status: DrawingHistoryStatus.fromValue(json['status'] as String?),
      lastEditedAt: DateTime.tryParse(json['lastEditedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      thumbnailBase64: json['thumbnailBase64'] as String?,
      snapshot: DrawingSessionSnapshot.fromJson(
        json['snapshot'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}
