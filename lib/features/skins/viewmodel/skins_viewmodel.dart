import '../../../core/base/base_viewmodel.dart';
import '../model/skin_catalog.dart';
import '../model/skin_model.dart';

class SkinsViewModel extends BaseViewModel {
  String _selectedSkinId = 'markerp';

  String get selectedSkinId => _selectedSkinId;
  SkinModel get selectedSkin => SkinCatalog.byId(_selectedSkinId);
  List<SkinModel> get skins => SkinCatalog.items;

  void selectSkin(String skinId) {
    if (_selectedSkinId == skinId) return;
    _selectedSkinId = skinId;
    notifyListeners();
  }
}
