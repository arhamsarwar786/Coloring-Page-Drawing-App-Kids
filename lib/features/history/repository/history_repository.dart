import 'dart:convert';

import '../../../shared/services/local_storage_base.dart';
import '../model/drawing_history_entry.dart';

abstract class HistoryRepository {
  Future<List<DrawingHistoryEntry>> getHistoryEntries();
  Future<DrawingHistoryEntry?> getHistoryEntry(String id);
  Future<void> saveHistoryEntry(DrawingHistoryEntry entry);
}

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({
    required LocalStorageService storage,
  }) : _storage = storage;

  static const String _fileName = 'asmr_drawing_history.json';

  final LocalStorageService _storage;

  @override
  Future<List<DrawingHistoryEntry>> getHistoryEntries() async {
    final entries = await _readEntries();
    entries.sort((a, b) => b.lastEditedAt.compareTo(a.lastEditedAt));
    return entries;
  }

  @override
  Future<DrawingHistoryEntry?> getHistoryEntry(String id) async {
    final entries = await _readEntries();
    for (final entry in entries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<void> saveHistoryEntry(DrawingHistoryEntry entry) async {
    if (entry.id.trim().isEmpty ||
        entry.levelId.trim().isEmpty ||
        !entry.snapshot.hasVisibleProgress) {
      return;
    }

    final entries = await _readEntries();
    final index = entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }

    final payload = <String, dynamic>{
      'entries': entries.map((item) => item.toJson()).toList(growable: false),
    };
    await _storage.write(_fileName, jsonEncode(payload));
  }

  Future<List<DrawingHistoryEntry>> _readEntries() async {
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.trim().isEmpty) {
      return <DrawingHistoryEntry>[];
    }

    try {
      final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
      final rawEntries =
          jsonMap['entries'] as List<dynamic>? ?? const <dynamic>[];
      final entries = <DrawingHistoryEntry>[];
      for (final item in rawEntries) {
        if (item is! Map) continue;
        final entry = DrawingHistoryEntry.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (entry.id.trim().isEmpty ||
            entry.levelId.trim().isEmpty ||
            entry.levelTitle.trim().isEmpty) {
          continue;
        }
        entries.add(entry);
      }
      return entries;
    } catch (_) {
      return <DrawingHistoryEntry>[];
    }
  }
}
