import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../shared/services/local_storage_base.dart';
import '../model/drawing_history_entry.dart';

abstract class HistoryRepository {
  Future<List<DrawingHistoryEntry>> getHistoryEntries();
  Future<DrawingHistoryEntry?> getHistoryEntry(String id);
  Future<void> saveHistoryEntry(DrawingHistoryEntry entry);
}

// Top level functions for compute isolate
String _encodeHistoryIsolate(List<DrawingHistoryEntry> entries) {
  final payload = <String, dynamic>{
    'entries': entries.map((item) => item.toJson()).toList(growable: false),
  };
  return jsonEncode(payload);
}

List<DrawingHistoryEntry> _decodeHistoryIsolate(String raw) {
  final jsonMap = jsonDecode(raw) as Map<String, dynamic>;
  final rawEntries = jsonMap['entries'] as List<dynamic>? ?? const <dynamic>[];
  final entries = <DrawingHistoryEntry>[];
  for (final item in rawEntries) {
    if (item is! Map) continue;
    try {
      final entry = DrawingHistoryEntry.fromJson(Map<String, dynamic>.from(item));
      if (entry.id.trim().isEmpty ||
          entry.levelId.trim().isEmpty ||
          entry.levelTitle.trim().isEmpty) {
        continue;
      }
      entries.add(entry);
    } catch (_) {
      // ignore invalid entry
    }
  }
  return entries;
}

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl({
    required LocalStorageService storage,
  }) : _storage = storage;

  static const String _fileName = 'asmr_drawing_history.json';

  final LocalStorageService _storage;
  List<DrawingHistoryEntry>? _cachedEntries;
  bool _isSaving = false;
  bool _isDecoding = false;
  Future<List<DrawingHistoryEntry>>? _decodeFuture;

  @override
  Future<List<DrawingHistoryEntry>> getHistoryEntries() async {
    final entries = await _readEntries();
    final sorted = List<DrawingHistoryEntry>.from(entries);
    sorted.sort((a, b) => b.lastEditedAt.compareTo(a.lastEditedAt));
    return sorted;
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
    _cachedEntries = entries;

    if (_isSaving) return;
    _isSaving = true;

    try {
      // Offload heavy JSON stringification to another thread
      final encodedString = await compute(_encodeHistoryIsolate, entries);
      await _storage.write(_fileName, encodedString);
    } finally {
      _isSaving = false;
    }
  }

  Future<List<DrawingHistoryEntry>> _readEntries() async {
    if (_cachedEntries != null) {
      return _cachedEntries!;
    }

    if (_decodeFuture != null) {
      return _decodeFuture!;
    }

    _decodeFuture = _performReadEntries();
    final result = await _decodeFuture!;
    _decodeFuture = null;
    return result;
  }

  Future<List<DrawingHistoryEntry>> _performReadEntries() async {
    final raw = await _storage.read(_fileName);
    if (raw == null || raw.trim().isEmpty) {
      _cachedEntries = <DrawingHistoryEntry>[];
      return _cachedEntries!;
    }

    try {
      // Offload heavy JSON parsing to another thread
      final entries = await compute(_decodeHistoryIsolate, raw);
      _cachedEntries = entries;
      return entries;
    } catch (_) {
      _cachedEntries = <DrawingHistoryEntry>[];
      return _cachedEntries!;
    }
  }
}
