import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/components/doodle_text.dart';
import '../../../shared/components/sticker_icon_button.dart';
import '../viewmodel/settings_viewmodel.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => Navigator.pop(context), // Background tap to close
      child: Material(
        color: Colors.black.withOpacity(0.5), // Slightly darker dim for focus
        child: Align(
          alignment: AlignmentGeometry.xy(0, 0.25),
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping the dialog itself
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Consumer<SettingsViewModel>(
                  builder: (_, viewModel, __) {
                    return Container(
                      height: size.height * 0.265,
                      width: size.width * 0.858, // Card size as per screenshot
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFb0b0b0),
                            blurRadius: 0,
                            spreadRadius: 1.5,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DoodleText(
                            AppStrings.settingsTitle.toUpperCase(),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            fillColor: Color(0xFF3c8fde),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SettingIconTile(
                                assetName: viewModel.musicEnabled
                                    ? 'assets/images/music.png'
                                    : 'assets/images/music-off.png',
                                active: viewModel.musicEnabled,
                                onTap: viewModel.toggleMusic,
                              ),
                              _SettingIconTile(
                                assetName: viewModel.soundEnabled
                                    ? 'assets/images/sound.png'
                                    : 'assets/images/sound-off.png',
                                active: viewModel.soundEnabled,
                                onTap: viewModel.toggleSound,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Privacy Policy Button (Same as screenshot style)
                          // Privacy Policy Button (Replaced with Asset Image)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.privacy);
                            },
                            child: Image.asset(
                              'assets/images/privacy plicy botton.png',
                              width: 230,
                              // height: 48,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// FLOATING RED CLOSE BUTTON (Top Right)
                Positioned(
                  top: -20,
                  right: -10,
                  child: StickerIconButton(
                    icon: Icons.close_rounded,
                    assetName:
                        'assets/images/close.png', // Ensure this exists or use Icon
                    size: 50,
                    iconColor: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingIconTile extends StatelessWidget {
  final String assetName;
  final bool active;
  final VoidCallback onTap;

  const _SettingIconTile({
    required this.assetName,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 45,
        height: 45,
        child: Image.asset(
          assetName,
          fit: BoxFit.contain,
          // Filters can be added here if you want to dim the 'off' state programmatically
        ),
      ),
    );
  }
}
