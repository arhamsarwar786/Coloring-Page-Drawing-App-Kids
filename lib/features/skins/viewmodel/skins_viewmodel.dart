import '../../../core/base/base_viewmodel.dart';
import '../model/skin_catalog.dart';
import '../model/skin_model.dart';

class SkinsViewModel extends BaseViewModel {
  String _selectedSkinId = 'marker';
  int _unlockedCount = 1;

  String get selectedSkinId => _selectedSkinId;
  int get unlockedCount => _unlockedCount;
  SkinModel get selectedSkin => SkinCatalog.byId(_selectedSkinId);
  List<SkinModel> get skins => SkinCatalog.items;

  void selectSkin(String skinId) {
    if (_selectedSkinId == skinId) return;
    _selectedSkinId = skinId;
    notifyListeners();
  }

  // int _unlockedCount = 1;
  void unlockByLevel(int levelNumber) {
  _unlockedCount = ((levelNumber - 1) ~/ 5) + 1;

  if (_unlockedCount > SkinCatalog.items.length) {
    _unlockedCount = SkinCatalog.items.length;
  }

  notifyListeners();
}

  // void unlockNextSkin() {
  //   if (_unlockedCount < SkinCatalog.items.length) {
  //     _unlockedCount + 5;
  //     notifyListeners();
  //   }
  // }
}
