import '../../../core/base/base_viewmodel.dart';
import '../services/admob_service.dart';

class AdsViewModel extends BaseViewModel {
  AdsViewModel({
    required AdMobService service,
  }) : _service = service;

  final AdMobService _service;
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    await _service.initialize();
    _initialized = true;
    notifyListeners();
  }
}
