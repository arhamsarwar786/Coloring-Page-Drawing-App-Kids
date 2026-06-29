# Coloring Page Drawing App - Kids: Developer Documentation

Welcome to the **Coloring Page Drawing App**! This document provides a high-level overview of the app's architecture, its core features, and the user flow. It is designed to help new developers quickly understand how the app works and where to find specific functionalities.

## 🎯 App Purpose
This is an interactive and educational Flutter application designed for kids. The primary goal is to encourage creativity and learning through coloring, drawing, and tracing activities. To keep kids engaged, the app includes a gamified progression system where users earn coins and stars for completing artworks, which can be spent in a virtual Reward Store.

---

## 📂 Feature Overview & Directory Structure
The app follows a feature-first folder architecture located in `lib/features/`. Each folder encapsulates the UI, logic, and state related to that specific feature.

### 1. 🎨 Coloring (`lib/features/coloring`)
**Purpose:** The core feature where kids can color pre-defined images.
**How it works:** 
- Users select an image and enter the `ColoringScreen`. 
- They can select colors and fill in the regions.
- Upon completion, the `ColoringCompletionScreen` analyzes the masterpiece. It calculates a "completeness score" (`_matchPercent`). 
- Based on the score, the user is awarded stars (up to 3) and coins. It supports both Portrait and Landscape orientations dynamically.

### 2. ✍️ Drawing (`lib/features/drawing`)
**Purpose:** A freestyle drawing canvas.
**How it works:** Kids get a blank canvas where they can freely draw using different brushes and colors. Their imagination is the only limit.

### 3. 📝 Tracing (`lib/features/tracing`)
**Purpose:** An educational feature for tracing letters, numbers, or shapes.
**How it works:** Helps toddlers and young kids develop fine motor skills by guiding their fingers along defined paths. 

### 4. 🏆 Rewards Store (`lib/features/rewards`)
**Purpose:** A gamified shop to spend earned coins.
**How it works:**
- Handled primarily by `RewardStoreScreen`.
- Kids can browse available rewards (e.g., physical toys or digital gifts).
- If they have enough coins, they can "purchase" the reward. 
- A purchase triggers the `TrackingScreen`, as some rewards may have a simulated or real delivery time (e.g., "7 days").
- If coins are insufficient, a warning ("COINS KAM HAIN!") is shown.

### 5. 📜 Certificates (`lib/features/certificates`)
**Purpose:** Rewards kids with a sense of achievement.
**How it works:** Uses `playcraft_certificate_pdf_service.dart` to dynamically generate a PDF certificate when a user completes a major milestone or level. This certificate can be viewed or saved.

### 6. 🔐 Authentication (`lib/features/auth`)
**Purpose:** User account management.
**How it works:** Allows parents/kids to create an account (`LoginScreen`) to save their progress, coins, and history to the cloud. Unauthenticated users are often prompted to log in to save their earned coins.

### 7. 📈 Levels (`lib/features/levels`)
**Purpose:** Manages the game progression and difficulty.
**How it works:** Activities are grouped into categories and levels. Completing one level unlocks the next. `DrawingRepository` handles fetching the next level.

### 8. 🖼️ History (`lib/features/history`)
**Purpose:** An art gallery of the kid's past work.
**How it works:** Saves completed colorings and drawings so parents and kids can look back at their creations.

### 9. 🏠 Home (`lib/features/home`)
**Purpose:** The main dashboard.
**How it works:** Serves as the navigation hub where users can choose to go to Coloring, Drawing, Tracing, or the Reward Store.

### 10. 🎵 Sound (`lib/features/sound`)
**Purpose:** Audio management.
**How it works:** Handles background music (BGM) and sound effects (SFX) like cheering, confetti pops, or button clicks to make the app feel alive.

### 11. 🧩 Skins (`lib/features/skins`)
**Purpose:** Customization options.
**How it works:** Allows users to change the appearance of the app's UI or unlock special brushes using their coins.

### 12. ⚙️ Settings & Privacy (`lib/features/settings` & `lib/features/privacy`)
**Purpose:** Parental controls and app configuration.
**How it works:** Toggles for sound/music, account deletion, and strict privacy policies required for children's apps (COPPA compliance).

### 13. 📢 Ads (`lib/features/ads`)
**Purpose:** Monetization.
**How it works:** Integrated logic for displaying kid-safe advertisements.

### 14. 💦 Splash (`lib/features/splash`)
**Purpose:** The entry point.
**How it works:** Shows the app logo, initializes necessary services, and checks authentication state before routing to `Home`.

---

## 🔄 General App Flow

1. **App Launch:** `Splash` screen loads assets and state -> Routes to `Home`.
2. **Dashboard Selection:** User selects an activity (e.g., "Coloring").
3. **Level Selection:** User browses categories/levels -> Selects a specific picture.
4. **Gameplay Loop:** 
   - User colors the picture (`ColoringScreen`).
   - Finishes and submits.
   - Evaluated on `ColoringCompletionScreen`.
   - Rewards (Stars/Coins) are added to the user's balance.
   - Confetti animation plays! 🎉
   - User can go to "Next Level" or "Home".
5. **Reward Loop:** User visits the `Reward Store`, views balance, and spends coins on cool items. 

---

## 🛠️ Key Technical Notes for Developers
- **Responsiveness:** The app heavily relies on `flutter_screenutil` (using `.w`, `.h`, `.sp`). Be extremely careful when dealing with `OrientationBuilder` (Landscape vs Portrait) to ensure values don't scale improperly.
- **State Management:** Uses `Provider` (e.g., `ColoringProvider`) for state injection.
- **Orientation:** While most of the app is Portrait, key gameplay screens (like Coloring and its Completion screen) fully support Landscape for tablet-friendly use. 

Happy Coding! 🚀
