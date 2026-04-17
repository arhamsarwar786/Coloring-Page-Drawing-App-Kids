import 'local_storage_base.dart';

class StubLocalStorageService implements LocalStorageService {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> read(String fileName) async => _store[fileName];

  @override
  Future<void> write(String fileName, String content) async {
    _store[fileName] = content;
  }
}

LocalStorageService createStorageService() => StubLocalStorageService();
