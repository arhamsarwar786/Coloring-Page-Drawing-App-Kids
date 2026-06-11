# 🎨 Coloring Page Drawing App – Kids (PlayCraft Kids)

> **An ASMR-inspired, offline-first coloring & drawing app for kids built with Flutter.**  
> Relaxing tap-to-fill coloring pages, star rewards, drawing history, sound feedback, and a Supabase-powered coin leaderboard — all in a single, beautifully themed Flutter app.

---

## 📑 Table of Contents

1. [Project Overview](#-project-overview)
2. [Features](#-features)
3. [Tech Stack & Dependencies](#-tech-stack--dependencies)
4. [Project Structure](#-project-structure)
5. [Architecture (MVVM + Provider)](#-architecture-mvvm--provider)
6. [Feature Modules](#-feature-modules)
   - [Splash](#1-splash)
   - [Home](#2-home)
   - [Levels](#3-levels)
   - [Drawing (Coloring Canvas)](#4-drawing-coloring-canvas)
   - [Coloring](#5-coloring)
   - [Rewards](#6-rewards)
   - [History](#7-history)
   - [Skins](#8-skins)
   - [Settings](#9-settings)
   - [Sound](#10-sound)
   - [Ads](#11-ads)
   - [Auth](#12-auth)
   - [Tracing](#13-tracing)
   - [Privacy](#14-privacy)
7. [Core Layer](#-core-layer)
8. [Shared Layer](#-shared-layer)
9. [Data & Assets](#-data--assets)
10. [Navigation / Routing](#-navigation--routing)
11. [Dependency Injection](#-dependency-injection)
12. [State Management](#-state-management)
13. [Backend – Supabase Integration](#-backend--supabase-integration)
14. [Local Persistence](#-local-persistence)
15. [Theming & Design System](#-theming--design-system)
16. [Getting Started](#-getting-started)
17. [Build & Release](#-build--release)
18. [Known Issues / TODO](#-known-issues--todo)

---

## 🌟 Project Overview

| Property | Value |
|---|---|
| **Package name** | `play_craft_kids` |
| **App title** | Coloring Page Drawing |
| **Version** | 1.0.0+3 |
| **Flutter SDK** | ≥ 3.0.0 < 4.0.0 |
| **Platform targets** | Android · iOS · Web · macOS · Linux |
| **Orientation** | Portrait-only (locked at startup) |
| **UI Mode** | Edge-to-edge, transparent system bars |
| **Backend** | Supabase (coins leaderboard + auth) |
| **Offline** | ✅ All levels & progress work fully offline |

The app lets children tap pre-defined SVG/vector regions on a coloring page and fill them with colors from a curated palette. Completing every region triggers an animated reward screen with stars and coins. Progress is saved locally and optionally synced to Supabase.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🖌️ **Tap-to-Fill Coloring** | Tap any region to flood-fill with the selected palette color |
| ↩️ **Undo / Redo** | Multi-step undo and redo with full action history |
| 🔄 **Reset Canvas** | Clear all fills and start over |
| ⭐ **Star Rewards** | 1–3 stars based on undo usage; 100-coin bonus for perfect accuracy |
| 💰 **Coin System** | Coins awarded per level, synced to Supabase cloud |
| 📂 **Categories** | Levels organized into thematic categories (Animals, Fruits, Vehicles, etc.) |
| 📊 **Level Progression** | Levels unlock sequentially; completed levels show star badges |
| 🕑 **Drawing History** | Resume in-progress sessions; thumbnail previews of past work |
| 🎵 **ASMR Sound Feedback** | Fill sounds, completion jingle, background ambient music |
| 🔇 **Settings** | Toggle music, sound effects, and haptic feedback independently |
| 🎨 **Skins** | Multiple marker brush skin images selectable by the user |
| 🏆 **Reward Screen** | Confetti animation, Lottie celebration, share artwork as image |
| 🔐 **Auth** | Supabase anonymous / email auth for cloud coin sync |
| 📜 **Privacy Policy** | In-app privacy policy screen |
| 📴 **Offline-First** | All content loaded from bundled JSON assets; network optional |

---

## 🛠️ Tech Stack & Dependencies

### Runtime Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | Core framework |
| `provider` | ^6.1.2 | State management (MVVM ChangeNotifier) |
| `hive` | ^2.2.3 | Local key-value storage (NoSQL) |
| `hive_flutter` | ^1.1.0 | Hive Flutter integration |
| `path_provider` | ^2.1.2 | File system paths |
| `share_plus` | ^7.2.1 | Share completed artwork |
| `audioplayers` | ^5.2.1 | Background music & sound effects |
| `flutter_svg` | ^2.0.9 | SVG rendering |
| `path_drawing` | ^1.0.1 | Parse & transform SVG path data for regions |
| `google_fonts` | ^8.0.2 | Typography (Poppins via Google Fonts) |
| `lottie` | ^3.3.0 | Celebration animation (JSON Lottie) |
| `confetti` | ^0.8.0 | Confetti particle effect on completion |
| `supabase_flutter` | ^2.0.0 | Cloud backend (auth + coins leaderboard) |

### Dev Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Unit & widget testing |
| `flutter_launcher_icons` | ^0.13.1 | App icon generation |
| `flutter_lints` | ^3.0.0 | Lint rules |

### Fonts

| Family | File | Usage |
|---|---|---|
| `Poppins` | `fonts/poppins_bold.ttf` | Headings & buttons |
| `Regular` | `fonts/poppins-regular.ttf` | Body text |

---

## 📁 Project Structure

```
play_craft_kids/
├── android/                    # Android native project
│   └── key.properties          # Signing config (not committed)
├── ios/                        # iOS native project
├── web/                        # Web platform
├── macos/                      # macOS desktop platform
├── linux/                      # Linux desktop platform
├── assets/
│   ├── data/
│   │   ├── app_content.json         # Main level/category data (~285 KB)
│   │   ├── realistic_content_pack.json  # Extra realistic-style levels
│   │   └── celebrate.json           # Lottie celebration animation
│   ├── images/                 # 440+ .webp/.png coloring images
│   ├── sounds/                 # background.mp3, splash_music.mp3
│   └── audio/                  # Additional audio clips
├── fonts/
│   ├── poppins_bold.ttf
│   └── poppins-regular.ttf
├── lib/
│   ├── main.dart               # Entry point — Supabase init + runApp
│   ├── app/
│   │   ├── app.dart            # Root widget (MultiProvider + MaterialApp)
│   │   ├── config/
│   │   │   ├── app_config.dart       # App-wide constants
│   │   │   └── supabase_serview.dart # Supabase helpers
│   │   ├── routes/
│   │   │   └── app_routes.dart       # Named route definitions + route args
│   │   └── theme/
│   │       └── app_theme.dart        # Material ThemeData factory
│   ├── core/
│   │   ├── base/
│   │   │   └── base_viewmodel.dart   # BaseViewModel (loading/error state)
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # Brand color palette
│   │   │   ├── app_spacing.dart      # Spacing constants
│   │   │   └── app_strings.dart      # All user-visible strings
│   │   ├── di/
│   │   │   └── providers.dart        # All Provider registrations
│   │   ├── network/
│   │   │   └── network_info.dart     # Network connectivity helper
│   │   ├── services/
│   │   │   └── content_service.dart  # Legacy content service wrapper
│   │   └── utils/
│   │       ├── app_bottom_bar.dart   # Reusable bottom bar widget
│   │       ├── app_colors.dart       # Color utilities
│   │       └── color_parser.dart     # Hex string → Color parser
│   ├── features/
│   │   ├── ads/                # AdMob service + viewmodel
│   │   ├── auth/               # Supabase auth UI + components
│   │   ├── coloring/           # Coloring-specific screens & viewmodel
│   │   ├── drawing/            # Core drawing/fill engine + screen
│   │   ├── history/            # Drawing session history
│   │   ├── home/               # Home screen, categories, daily pick
│   │   ├── levels/             # Level list & level model
│   │   ├── privacy/            # Privacy policy screen
│   │   ├── rewards/            # Reward/completion screen
│   │   ├── settings/           # Settings modal dialog
│   │   ├── skins/              # Marker skin selector
│   │   ├── sound/              # Audio playback service
│   │   ├── splash/             # Animated splash screen
│   │   └── tracing/            # (Legacy) Tracing activity viewmodel
│   └── shared/
│       ├── components/         # Generic UI components
│       ├── services/
│       │   ├── app_preferences_service.dart  # User preferences (Hive)
│       │   ├── local_content_service.dart    # Content + progress service
│       │   ├── local_storage.dart            # Platform-conditional factory
│       │   ├── local_storage_base.dart       # Abstract storage interface
│       │   ├── local_storage_io.dart         # dart:io implementation
│       │   └── local_storage_stub.dart       # Web/stub implementation
│       ├── utils/              # Shared utility functions
│       └── widgets/
│           ├── custom_button.dart  # Branded CTA button
│           └── loader.dart         # Loading indicator widget
├── pubspec.yaml
├── analysis_options.yaml
└── flutter_launcher_icons.yaml
```

---

## 🏗️ Architecture (MVVM + Provider)

The app follows **MVVM (Model-View-ViewModel)** with Flutter's `provider` package as the DI/reactivity backbone.

```
┌─────────────────────────────────────────────┐
│                    VIEW                     │
│  (Screens & Widgets — read ViewModel state) │
└────────────────────┬────────────────────────┘
                     │ Consumer / context.watch
┌────────────────────▼────────────────────────┐
│                 VIEWMODEL                   │
│  (ChangeNotifier — business logic & state)  │
└────────────────────┬────────────────────────┘
                     │ calls
┌────────────────────▼────────────────────────┐
│               REPOSITORY                   │
│  (Abstracts data sources; returns models)   │
└────────────┬───────────────────┬────────────┘
             │                   │
┌────────────▼──────┐  ┌────────▼────────────┐
│ LocalContentService│  │  HistoryRepository  │
│  (JSON assets +   │  │  (Hive local DB)    │
│   Supabase sync)  │  └─────────────────────┘
└───────────────────┘
```

### Key Principles
- **ViewModels** extend `BaseViewModel` which exposes `isLoading` and `errorMessage` state.
- **Repositories** are plain Dart classes; each feature has its own interface + `Impl` pair.
- **Services** are singletons registered at app start via `MultiProvider`.
- **Views** never directly call repositories — they only interact with their ViewModel.

---

## 🧩 Feature Modules

Each feature under `lib/features/` is self-contained and follows the same internal structure:

```
feature/
├── model/        # Dart data classes (immutable, fromJson/toJson)
├── repository/   # Abstract interface + concrete implementation
├── viewmodel/    # ChangeNotifier with business logic
├── view/         # Screen widgets
└── widgets/      # Feature-specific reusable widgets
```

---

### 1. Splash

**Path:** `lib/features/splash/`

| File | Description |
|---|---|
| `view/splash_screen.dart` | Animated splash with logo, subtitle, and loading text |
| `view/_animated_loading_text.dart` | Cycling loading message animation |
| `viewmodel/splash_viewmodel.dart` | Loads home content; navigates to `mainHome` after delay |

- Waits `AppConfig.splashDelayMs` (2200 ms) for content to load.
- Plays `splash_music.mp3` via `SoundService`.
- Transitions to the **MainHome** screen.

---

### 2. Home

**Path:** `lib/features/home/`

| File | Description |
|---|---|
| `view/home_screen.dart` | Full home screen with categories, daily pick, continue card (~54 KB) |
| `view/main_home_screen.dart` | Simplified entry wrapper with bottom nav |
| `viewmodel/home_viewmodel.dart` | Fetches categories + last played level |
| `repository/home_repository.dart` | Interface + `HomeRepositoryImpl` |
| `model/category_model.dart` | `CategoryModel` with list of `LevelModel` |

**HomeViewModel state:**
- `categories` — list of `CategoryModel`
- `lastPlayedLevel` — resumes the most recent session
- `dailyCalm` — featured level of the day

---

### 3. Levels

**Path:** `lib/features/levels/`

| File | Description |
|---|---|
| `view/level_screen.dart` | Grid of level cards with lock/progress/complete badges |
| `viewmodel/` | `LevelViewModel` — filters by category, tracks unlock state |
| `repository/level_repository.dart` | `LevelRepositoryImpl` — delegates to `LocalContentService` |
| `model/level_model.dart` | `LevelModel` + `LevelRegionModel` + `RegionShapeType` |

#### `LevelModel` Fields

| Field | Type | Description |
|---|---|---|
| `id` | `String` | Unique level identifier |
| `title` | `String` | Display name |
| `subtitle` | `String` | Short description |
| `difficulty` | `String` | `"easy"` / `"medium"` / `"hard"` |
| `rewardCoins` | `int` | Coins awarded on completion |
| `recommendedBrushSize` | `double` | Suggested brush radius |
| `palette` | `List<DrawingColorModel>` | Available fill colors |
| `regions` | `List<LevelRegionModel>` | Fillable regions |
| `guideAsset` | `String?` | Path to reference image overlay |
| `previewImage` | `String?` | Thumbnail for level card |
| `imagePath` | `String?` | Colored reference image |
| `activityItem` | `ActivityItem?` | Optional tracing activity metadata |
| `isCompleted` | `bool` | Completion state (from local progress) |
| `stars` | `int` | Star rating 0–3 |

#### `LevelRegionModel` — Shape Types

| Shape | Parameters | Description |
|---|---|---|
| `circle` | `cx, cy, radius` | Circle region |
| `oval` | `cx, cy, rx, ry` | Ellipse region |
| `polygon` | `points: List<Offset>` | Polygon region |
| `path` | `svgPath, viewBoxSize` | Arbitrary SVG path region |

All shapes implement `toPath(Size)` and `contains(Offset, Size)` for hit-testing.

**Target color mapping** is resolved via `getTargetColorIdForRegion()` using either explicit `targetColorId` JSON field or a built-in name-matching lookup table (apple → red/green/brown, etc.).

---

### 4. Drawing (Coloring Canvas)

**Path:** `lib/features/drawing/`

This is the **core feature** of the app.

#### Key Files

| File | Size | Description |
|---|---|---|
| `view/drawing_screen.dart` | ~63 KB | The main coloring canvas screen |
| `viewmodel/drawing_viewmodel.dart` | ~14 KB | Full drawing state + undo/redo/fill logic |
| `model/color_model.dart` | 522 B | `DrawingColorModel` (id + Color) |
| `model/drawing_action.dart` | 1.1 KB | `DrawingAction` for undo/redo stack |
| `model/drawing_brush_size.dart` | 272 B | `DrawingBrushSize` enum (small/standard/large) |
| `model/drawing_point.dart` | 1.8 KB | Point model for freehand strokes |
| `model/drawing_session_snapshot.dart` | 8.3 KB | Serializable snapshot of canvas state |
| `repository/drawing_repository.dart` | — | CRUD for level data & session metadata |

#### `DrawingViewModel` — State

| Getter | Type | Description |
|---|---|---|
| `level` | `LevelModel?` | Currently loaded level |
| `selectedColor` | `DrawingColorModel?` | Active palette color |
| `selectedBrushSize` | `DrawingBrushSize` | Current brush radius |
| `filledRegions` | `Map<String, Color>` | regionId → fill color |
| `canUndo` / `canRedo` | `bool` | Stack availability |
| `completionProgress` | `double` | 0.0 – 1.0 fill ratio |
| `accuracyScore` | `double` | Ratio of correctly-colored regions |
| `isCompleted` | `bool` | All regions filled |
| `isExcellence` | `bool` | Perfect color match (100-coin bonus) |
| `rewardCoins` / `rewardStars` | `int?` | Set on completion |

#### `DrawingViewModel` — Key Methods

| Method | Description |
|---|---|
| `loadLevel(levelId, {drawingSessionId})` | Loads level + restores saved session if available |
| `fillRegionAt(regionId)` | Fills region, pushes undo action, plays sound, checks completion |
| `undo()` / `redo()` | Reverses/reapplies the last fill action |
| `resetCanvas()` | Clears all fills and resets undo stacks |
| `saveHistorySnapshot(snapshot, {thumbnailBytes})` | Persists canvas state to history |
| `checkExcellence()` | Verifies all regions match target colors exactly |

#### Completion Logic

```
All regions filled?
    └── YES → Calculate stars:
               • 0 undos   → ⭐⭐⭐
               • 1-2 undos → ⭐⭐
               • 3+ undos  → ⭐
             → Accuracy ≥ 70%? → markLevelCompleted() in repository
             → Play completion sound
             → Navigate to RewardScreen
```

---

### 5. Coloring

**Path:** `lib/features/coloring/`

| File | Description |
|---|---|
| `view/coloring_screen.dart` | Alternative coloring flow screen (~35 KB) |
| `view/coloring_completion_screen.dart` | Completion view with share option (~27 KB) |
| `view/coloring_summary_screen.dart` | Summary stats screen (~11 KB) |
| `viewmodel/coloring_viewmodel.dart` | `ColoringProvider` — ChangeNotifier for coloring state |

---

### 6. Rewards

**Path:** `lib/features/rewards/`

| File | Description |
|---|---|
| `view/reward_screen.dart` | Animated reward screen with confetti + Lottie |
| `viewmodel/reward_viewmodel.dart` | Marks level completed; loads next level info |

**Route args** (`RewardRouteArgs`):

| Field | Type | Description |
|---|---|---|
| `levelId` | `String` | Completed level |
| `levelTitle` | `String` | Display name |
| `levelNumber` | `int` | Ordinal number |
| `coins` | `int` | Coins earned |
| `stars` | `int` | Stars earned (1–3) |
| `nextLevelId` | `String?` | Next level to navigate to |
| `completedImageBytes` | `Uint8List?` | Screenshot of completed artwork |

---

### 7. History

**Path:** `lib/features/history/`

| File | Description |
|---|---|
| `model/drawing_history_entry.dart` | `DrawingHistoryEntry` model (id, levelId, progress, snapshot, thumbnail) |
| `repository/history_repository.dart` | `HistoryRepositoryImpl` — reads/writes to `LocalStorageService` |
| `viewmodel/history_viewmodel.dart` | Loads all history entries for the continue-drawing UI |

#### `DrawingHistoryEntry` Fields

| Field | Description |
|---|---|
| `id` | Unique session ID (`{levelId}_{timestamp}`) |
| `levelId` | Which level this session belongs to |
| `status` | `inProgress` or `completed` |
| `progress` | 0.0 – 1.0 fill progress |
| `snapshot` | Full `DrawingSessionSnapshot` (filledRegions, palette, brushSize) |
| `thumbnailBase64` | Base64-encoded PNG thumbnail |
| `lastEditedAt` | Timestamp |

---

### 8. Skins

**Path:** `lib/features/skins/`

| File | Description |
|---|---|
| `view/skins_screen.dart` | Grid of marker images; tap to select active skin |
| `viewmodel/skins_viewmodel.dart` | `SkinsViewModel` — tracks selected skin index |
| `model/` | Skin model definition |

Available skins are the marker images in `assets/images/` (`marker.png`, `marker1.png`, `markerf.png`, `markerfi.png`, `markerp.png`, `markers.png`, `markerse.png`, `markert.png`, `markerth.png`).

---

### 9. Settings

**Path:** `lib/features/settings/`

| File | Description |
|---|---|
| `view/settings_screen.dart` | `SettingsDialog` — modal overlay with toggle switches |
| `viewmodel/settings_viewmodel.dart` | `SettingsViewModel` — persists preferences via `AppPreferencesService` |

**Toggleable settings:**

| Setting | Storage key | Default |
|---|---|---|
| 🎵 Music | `music_enabled` | `true` |
| 🔊 Sound effects | `sounds_enabled` | `true` |
| 📳 Haptic feedback | `haptics_enabled` | `true` |

---

### 10. Sound

**Path:** `lib/features/sound/services/sound_service.dart`

Wraps the `audioplayers` package to provide:

| Method | Description |
|---|---|
| `playFillFeedback()` | Short click/pop sound on region fill |
| `playCompletionFeedback()` | Jingle on level completion |
| `playBackgroundMusic()` | Loops `assets/sounds/background.mp3` |
| `playSplashMusic()` | Plays `assets/sounds/splash_music.mp3` |
| `dispose()` | Releases audio player resources |

The `SettingsViewModel` calls `soundService` methods when toggles change.

---

### 11. Ads

**Path:** `lib/features/ads/`

| File | Description |
|---|---|
| `services/admob_service.dart` | Stub `AdMobService` class (placeholder for Google AdMob) |
| `viewmodel/ads_viewmodel.dart` | `AdsViewModel` — manages ad load/show state |

> ⚠️ AdMob integration is stubbed. Implement `AdMobService` with actual ad unit IDs before release.

---

### 12. Auth

**Path:** `lib/features/auth/`

| Folder | Description |
|---|---|
| `view/` | Login / sign-up UI screens |
| `components/` | Reusable auth form widgets |

Uses `supabase_flutter` for anonymous + email/password authentication. Auth state is used in `LocalContentService.savePoints()` to decide whether to sync coins to the cloud `user_coins` table.

---

### 13. Tracing

**Path:** `lib/features/tracing/viewmodel/`

| File | Description |
|---|---|
| `tracing_viewmodel.dart` | `TracingViewModel` — letter/shape tracing activity logic (~10 KB) |
| `activity_item.dart` | `ActivityItem` model — tracing prompt metadata |
| `activity_category_model.dart` | Category wrapper for activity items |

> 📝 Tracing was partially removed from the main drawing flow (UI toggles and strings have been cleaned up). The ViewModel and model remain for optional use by `LevelModel.activityItem`.

---

### 14. Privacy

**Path:** `lib/features/privacy/view/privacy_screen.dart`

Simple in-app `WebView` or text screen rendering the privacy policy. Accessible from the Settings dialog.

---

## 🔩 Core Layer

### `BaseViewModel` (`lib/core/base/base_viewmodel.dart`)

```dart
abstract class BaseViewModel extends ChangeNotifier {
  bool get isLoading;
  String? get errorMessage;
  void setLoading(bool value);
  void setError(String? message);
}
```

All feature ViewModels extend this, giving every screen consistent loading/error state.

---

### `AppConfig` (`lib/app/config/app_config.dart`)

| Constant | Value |
|---|---|
| `appTitle` | `'Coloring Page Drawing'` |
| `contentAssetPath` | `'assets/data/app_content.json'` |
| `realisticPackAssetPath` | `'assets/data/realistic_content_pack.json'` |
| `splashDelayMs` | `2200` |

---

### `AppColors` (`lib/core/constants/app_colors.dart`)

| Name | Hex | Usage |
|---|---|---|
| `rose` | `#FF867F` | Primary accent |
| `coral` | `#FFB26B` | Secondary accent |
| `peach` | `#FFF0D9` | Background tint |
| `sky` | `#9AD7F3` | Highlight |
| `mint` | `#9ED9C2` | Success tint |
| `ink` | `#293241` | Primary text |
| `shell` | `#FFFBF5` | Card/surface background |
| `warmGrey` | `#7A6F68` | Muted text |
| `success` | `#2A9D8F` | Completion state |
| `warning` | `#F4A261` | Warning state |

---

### `AppStrings` (`lib/core/constants/app_strings.dart`)

All user-visible strings are centralized in `AppStrings` as `static const String` values, enabling easy localization in the future.

---

## 🔗 Shared Layer

### Services

#### `LocalContentService`

The central data hub:
- Loads `app_content.json` + `realistic_content_pack.json` from bundle assets.
- Merges the two content packs (deduplicates by level ID).
- Applies saved progress (`isCompleted`, `stars`) from local storage.
- Persists state to `asmr_drawing_progress.json` in app documents.
- Syncs coin balance to Supabase `user_coins` table on save.

**Content unlock thresholds (Supabase):**

| Coins | Unlock |
|---|---|
| ≥ 100 | `is_item_unlocked` |
| ≥ 200 | `is_stage_unlocked` |
| ≥ 500 | `is_premium_unlocked` |

#### `AppPreferencesService`

Thin wrapper over `LocalStorageService` for reading/writing user preferences (music, sounds, haptics).

#### `LocalStorageService` (platform-conditional)

| Platform | Implementation |
|---|---|
| Mobile / Desktop | `LocalStorageIOImpl` — uses `dart:io` `File` |
| Web / Stub | `LocalStorageStubImpl` — in-memory Map |

Factory function `createLocalStorageService()` in `local_storage.dart` picks the right impl at compile time.

---

### Shared Widgets

| Widget | File | Description |
|---|---|---|
| `CustomButton` | `widgets/custom_button.dart` | Branded elevated button with press animation |
| `Loader` | `widgets/loader.dart` | Centered `CircularProgressIndicator` |

---

## 📦 Data & Assets

### `assets/data/app_content.json` (~285 KB)

Main content file. Top-level structure:

```json
{
  "categories": [
    {
      "id": "animals",
      "title": "Animals",
      "levels": [ { ...LevelModel fields... } ]
    }
  ]
}
```

### `assets/data/realistic_content_pack.json` (~18 KB)

Supplementary pack merged into existing categories at runtime. Same category/level structure.

### `assets/data/celebrate.json`

Lottie animation JSON used on the reward screen.

### `assets/images/` — 440+ images

- `{name}.webp` — Colored reference images
- `un_colored_{name}.webp` — Black & white coloring page images
- `marker*.png` — Brush skin images
- `splash.png` — Splash screen artwork
- `bg.png`, `animalbg.png`, etc. — Category background images
- `boy.png`, `girl.png` — Prompt card character images

### `assets/sounds/`

| File | Size | Usage |
|---|---|---|
| `background.mp3` | 3.2 MB | Looping ambient music |
| `background.wav` | 529 KB | Alternate ambient (WAV) |
| `splash_music.mp3` | 275 KB | Splash screen music |

---

## 🗺️ Navigation / Routing

All routes are defined in [`AppRoutes`](lib/app/routes/app_routes.dart) using named routes and a centralized `onGenerateRoute` switch.

| Route Constant | Path | Screen | Args |
|---|---|---|---|
| `AppRoutes.splash` | `/` | `SplashScreen` | — |
| `AppRoutes.home` | `/home` | `HomeScreen` | — |
| `AppRoutes.mainHome` | `/main-home` | `MainHomeScreen` | — |
| `AppRoutes.drawing` | `/drawing` | `DrawingScreen` | `DrawingRouteArgs` |
| `AppRoutes.levels` | `/levels` | `LevelScreen` | — |
| `AppRoutes.skins` | `/skins` | `SkinsScreen` | — |
| `AppRoutes.settings` | `/settings` | `SettingsDialog` | — |
| `AppRoutes.privacy` | `/privacy` | `PrivacyScreen` | — |
| `AppRoutes.reward` | `/reward` | `RewardScreen` | `RewardRouteArgs` |

### Route Argument Classes

**`DrawingRouteArgs`**
```dart
DrawingRouteArgs({
  required String levelId,
  String? levelTitle,
  int? levelNumber,
  String? drawingSessionId,  // null = fresh session, non-null = resume
})
```

**`RewardRouteArgs`**
```dart
RewardRouteArgs({
  required String levelId,
  required String levelTitle,
  required int levelNumber,
  required int coins,
  required int stars,
  String? nextLevelId,
  Uint8List? completedImageBytes,
})
```

---

## 💉 Dependency Injection

All providers are registered in [`buildAppProviders()`](lib/core/di/providers.dart), called inside `MultiProvider` at the root widget:

```
Provider (singleton, no rebuild):
  NetworkInfo
  LocalStorageService
  AppPreferencesService
  LocalContentService
  SoundService           ← disposed on app close
  AdMobService
  HomeRepository
  LevelRepository
  DrawingRepository
  HistoryRepository

ChangeNotifierProvider (reactive):
  SettingsViewModel      ← calls ensureLoaded() eagerly
  SplashViewModel
  HomeViewModel
  DrawingViewModel
  HistoryViewModel
  RewardViewModel
  AdsViewModel
  SkinsViewModel
  ColoringProvider
```

Dependency resolution is done via `context.read<T>()` at provider creation time — no service locator or get_it.

---

## ⚡ State Management

The app uses **`provider`** with **`ChangeNotifier`** ViewModels:

| Pattern | Usage |
|---|---|
| `Consumer<VM>` | Widget rebuilds that depend on full ViewModel |
| `context.watch<VM>()` | Rebuild on any ViewModel change |
| `context.read<VM>()` | One-time read (event handlers, initState) |
| `ValueListenableBuilder` | `brushSizeNotifier` in DrawingViewModel — fine-grained rebuild for brush size only |
| `Provider<T>` | Pure services that never notify (repositories, sound, etc.) |

---

## ☁️ Backend – Supabase Integration

**Project URL:** `https://skywvbfwotpxlwiglxpl.supabase.co`

### Database Tables

#### `user_coins`

| Column | Type | Description |
|---|---|---|
| `user_id` | `uuid` (FK → auth.users) | User identifier |
| `coins` | `int` | Current coin balance |
| `updated_at` | `timestamptz` | Last sync timestamp |
| `is_item_unlocked` | `bool` | Coins ≥ 100 |
| `is_stage_unlocked` | `bool` | Coins ≥ 200 |
| `is_premium_unlocked` | `bool` | Coins ≥ 500 |

### Coin Sync Flow

```
User completes level
  → DrawingViewModel._evaluateCompletion()
  → RewardViewModel marks completed
  → HomeViewModel.savePoints(totalCoins)
  → LocalContentService.savePoints(coins)
      ├── Persist to local JSON file
      └── Supabase.client.from('user_coins').upsert({...})
```

> ⚠️ **Security Note:** The Supabase anon key is currently hardcoded in `main.dart`. Move to environment variables or a secrets manager before production release.

---

## 💾 Local Persistence

All local data is stored as a single JSON file: `asmr_drawing_progress.json`

### State File Schema

```json
{
  "lastPlayedLevelId": "apple",
  "totalPoints": 350,
  "lastDailyBonusDate": "2026-06-11",
  "currentStreak": 5,
  "progress": {
    "apple": { "isCompleted": true, "stars": 3, "rewardCoins": 50 },
    "banana": { "isCompleted": false, "stars": 0, "rewardCoins": 0 }
  }
}
```

### Drawing History

Each session is saved as a separate entry keyed by `{levelId}_{timestamp}`:

```json
{
  "id": "apple_1749648000000",
  "levelId": "apple",
  "levelTitle": "Apple",
  "status": "inProgress",
  "progress": 0.6,
  "lastEditedAt": "2026-06-11T10:00:00Z",
  "thumbnailBase64": "iVBORw...",
  "snapshot": {
    "filledRegions": { "body": 4294901760 },
    "selectedColorId": "red",
    "brushSizeKey": "standard"
  }
}
```

---

## 🎨 Theming & Design System

### `AppTheme.light()` (`lib/app/theme/app_theme.dart`)

Returns a `ThemeData` with:
- Primary color: `AppColors.rose`
- Background: `AppColors.shell`
- Text theme: Poppins font family
- Card theme: rounded corners, soft shadows
- System UI: edge-to-edge, transparent status & nav bars

### Color Palette

```
Rose    #FF867F  ████  Primary CTA
Coral   #FFB26B  ████  Secondary
Peach   #FFF0D9  ████  Background
Sky     #9AD7F3  ████  Info/highlight
Mint    #9ED9C2  ████  Success tint
Ink     #293241  ████  Text
Shell   #FFFBF5  ████  Surface/card
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK **≥ 3.0.0**
- Dart SDK **≥ 3.0.0**
- Android Studio / Xcode (for device builds)
- A Supabase project (optional — app works fully offline)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/arhamsarwar786/Coloring-Page-Drawing-App-Kids.git
cd Coloring-Page-Drawing-App-Kids

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# 4. Run on a specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome    # Web
```

### Environment Configuration

The Supabase credentials are currently hardcoded in `lib/main.dart`. For production, extract them:

```bash
# Create a .env file (use flutter_dotenv or similar)
SUPABASE_URL=https://skywvbfwotpxlwiglxpl.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

---

## 📦 Build & Release

### Android

```bash
# Generate signing key (first time only)
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Configure android/key.properties (already exists — fill in values)

# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Install pods
cd ios && pod install && cd ..

# Build release IPA
flutter build ipa --release
```

### App Icon Generation

```bash
# Edit flutter_launcher_icons.yaml, then:
flutter pub run flutter_launcher_icons
```

---

## 📋 Known Issues / TODO

| # | Status | Item |
|---|---|---|
| 1 | ✅ Done | Create `TODO.md` |
| 2 | ✅ Done | Remove tracing UI (strings, toolbar toggle) |
| 3 | ⚠️ Partial | Remove trace logic from `drawing_viewmodel.dart` and `canvas_widget.dart` |
| 4 | ✅ Done | Fix drawing screen scroll — canvas fully expandable |
| 5 | ✅ Done | Fix prompt card — boy/girl reference image on right with name |
| 6 | 🔲 Pending | Update skins — use `marker*.png` images as selectable skins |
| 7 | ✅ Done | Fix settings — proper modal dialog with transparent barrier |
| 8 | 🔲 Pending | Remove "kids drawing fun" containers from home/skins |
| 9 | 🔲 Pending | Enhance splash & kids sounds if needed |
| 10 | 🔲 Pending | AdMob — replace stub `AdMobService` with real ad unit IDs |
| 11 | 🔲 Pending | Move Supabase anon key out of source code |
| 12 | 🔲 Pending | Add unit tests for `DrawingViewModel` and `LocalContentService` |
| 13 | 🔲 Pending | Remove dead commented-out code in `local_content_service.dart` |
| 14 | 🔲 Pending | Remove debug `print()` statements before release |

---

## 📄 License

This project is private. All rights reserved © 2026 PlayCraft Kids.

---

*Documentation generated on 2026-06-11. For questions, open an issue or contact the maintainer.*
