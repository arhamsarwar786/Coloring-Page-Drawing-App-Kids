import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/doodle_text.dart';
import '../../../shared/components/sticker_icon_button.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x99FFFFFF), Color(0xCCDAF7FF)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Consumer<SettingsViewModel>(
                        builder: (context, viewModel, _) {
                          return Container(
                            constraints:
                                const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.fromLTRB(
                                24, 26, 24, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 0,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const DoodleText(
                                  AppStrings.settingsTitle,
                                  fontSize: 34,
                                  fillColor: Color(0xFF1FA8F4),
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _SettingIconTile(
                                      icon: Icons.music_note_rounded,
                                      assetName:
                                          'assets/images/music.png',
                                      label: AppStrings.musicLabel,
                                      active: viewModel.musicEnabled,
                                      onTap: viewModel.toggleMusic,
                                    ),
                                    _SettingIconTile(
                                      icon: Icons.vibration_rounded,
                                      assetName:
                                          'assets/images/phone.png',
                                      label: AppStrings.hapticsLabel,
                                      active: viewModel.hapticsEnabled,
                                      onTap: viewModel.toggleHaptics,
                                    ),
                                    _SettingIconTile(
                                      icon: Icons.volume_up_rounded,
                                      assetName:
                                          'assets/images/sound.png',
                                      label: AppStrings.soundsLabel,
                                      active: viewModel.soundEnabled,
                                      onTap: viewModel.toggleSound,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: 260,
                                  child: FilledButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.privacy);
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF2DF200),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24),
                                      ),
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 18),
                                    ),
                                    child: const Text(
                                      AppStrings.privacyPolicy,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: -20,
                        right: -12,
                        child: StickerIconButton(
                          icon: Icons.close_rounded,
                          assetName: 'assets/images/close.png',
                          size: 72,
                          backgroundColor: const Color(0xFFFF2A2A),
                          iconColor: Colors.white,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingIconTile extends StatelessWidget {
  const _SettingIconTile({
    required this.icon,
    this.assetName,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String? assetName;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFE8FFF0)
                  : const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: active
                    ? const Color(0xFF33E61F)
                    : const Color(0xFF222222),
                width: 2.5,
              ),
            ),
            child: assetName != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      assetName!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(icon,
                              size: 44,
                              color: const Color(0xFF111111)),
                    ),
                  )
                : Icon(icon,
                    size: 44, color: const Color(0xFF111111)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            active ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: active
                  ? const Color(0xFF27A800)
                  : const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}
