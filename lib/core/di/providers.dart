import 'package:asmr_coloring_app/shared/services/local_storage_base.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/ads/services/admob_service.dart';
import '../../features/ads/viewmodel/ads_viewmodel.dart';
import '../../features/drawing/repository/drawing_repository.dart';
import '../../features/drawing/viewmodel/drawing_viewmodel.dart';
import '../../features/home/repository/home_repository.dart';
import '../../features/home/viewmodel/home_viewmodel.dart';
import '../../features/levels/repository/level_repository.dart';
import '../../features/levels/viewmodel/level_viewmodel.dart';
import '../../features/rewards/viewmodel/reward_viewmodel.dart';
import '../../features/settings/viewmodel/settings_viewmodel.dart';
import '../../features/skins/viewmodel/skins_viewmodel.dart';
import '../../features/sound/services/sound_service.dart';
import '../../features/splash/viewmodel/splash_viewmodel.dart';
import '../../shared/services/app_preferences_service.dart';
import '../../shared/services/local_content_service.dart';
import '../../shared/services/local_storage.dart';
import '../network/network_info.dart';

List<SingleChildWidget> buildAppProviders() {
  return <SingleChildWidget>[
    Provider<NetworkInfo>(create: (_) => const NetworkInfo()),
    Provider<LocalStorageService>(create: (_) => createLocalStorageService()),
    Provider<AppPreferencesService>(
      create: (context) => AppPreferencesService(
        storage: context.read<LocalStorageService>(),
      ),
    ),
    Provider<LocalContentService>(
      create: (context) => LocalContentService(
        storage: context.read<LocalStorageService>(),
      ),
    ),
    Provider<SoundService>(create: (_) => SoundService()),
    Provider<AdMobService>(create: (_) => const AdMobService()),
    Provider<HomeRepository>(
      create: (context) => HomeRepositoryImpl(
        contentService: context.read<LocalContentService>(),
      ),
    ),
    Provider<LevelRepository>(
      create: (context) => LevelRepositoryImpl(
        contentService: context.read<LocalContentService>(),
      ),
    ),
    Provider<DrawingRepository>(
      create: (context) => DrawingRepositoryImpl(
        contentService: context.read<LocalContentService>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => SettingsViewModel(
        preferencesService: context.read<AppPreferencesService>(),
        soundService: context.read<SoundService>(),
      )..ensureLoaded(),
    ),
    ChangeNotifierProvider(
      create: (context) => SplashViewModel(
        repository: context.read<HomeRepository>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        repository: context.read<HomeRepository>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => DrawingViewModel(
        repository: context.read<DrawingRepository>(),
        soundService: context.read<SoundService>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => LevelViewModel(
        repository: context.read<LevelRepository>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => RewardViewModel(
        repository: context.read<LevelRepository>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => AdsViewModel(
        service: context.read<AdMobService>(),
      ),
    ),
    ChangeNotifierProvider(create: (_) => SkinsViewModel()),
  ];
}
