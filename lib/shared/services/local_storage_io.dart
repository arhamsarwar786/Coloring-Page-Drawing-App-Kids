import 'dart:io';

import 'local_storage_base.dart';

class IoLocalStorageService implements LocalStorageService {
  @override
  Future<String?> read(String fileName) async {
    final file = await _resolve(fileName);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  @override
  Future<void> write(String fileName, String content) async {
    final file = await _resolve(fileName);
    await file.parent.create(recursive: true);
    await file.writeAsString(content, flush: true);
  }

  Future<File> _resolve(String fileName) async {
    final baseDir = Directory.systemTemp;
    return File(
        '${baseDir.path}${Platform.pathSeparator}$fileName');
  }
}

LocalStorageService createStorageService() => IoLocalStorageService();
