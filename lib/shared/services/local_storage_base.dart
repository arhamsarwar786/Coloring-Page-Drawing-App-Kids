abstract class LocalStorageService {
  Future<String?> read(String fileName);
  Future<void> write(String fileName, String content);
}
