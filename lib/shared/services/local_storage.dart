import 'local_storage_base.dart';
import 'local_storage_stub.dart'
    if (dart.library.io) 'local_storage_io.dart';

LocalStorageService createLocalStorageService() => createStorageService();
