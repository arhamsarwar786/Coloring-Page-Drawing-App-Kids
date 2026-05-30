import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:provider/provider.dart';

import '../../../shared/components/doodle_text.dart';
import '../../../shared/components/marker_preview.dart';
import '../../../shared/components/sticker_icon_button.dart';
import '../../../shared/utils/interaction_feedback.dart';
import '../viewmodel/skins_viewmodel.dart';

class SkinsScreen extends StatelessWidget {
  const SkinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/bg.png",
                  ),
                  fit: BoxFit.cover)),
          child: Column(
            children: <Widget>[
              // Header

              SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  children: [
                    ClipPath(
                      clipper: AppBarClipper(),
                      child: Container(
                        height: 140,
                        color: const Color(0xff3b9499),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10.0, bottom: 20),
                              child: StickerIconButton(
                                icon: Icons.arrow_back_rounded,
                                assetName: 'assets/images/close.png',
                                size: 48,
                                backgroundColor: Colors.white,
                                iconColor: const Color(0xFF17A7F2),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),

                            Expanded(
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Shadow Layer
                                      Transform.translate(
                                        offset: const Offset(6, 6),
                                        child: Text(
                                          "SKINS",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w900,
                                            color:
                                                Colors.black.withOpacity(0.35),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),

                                      // Pink 3D Layer
                                      Transform.translate(
                                        offset: const Offset(3, 3),
                                        child: Text(
                                          "SKINS",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFF4FA3),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),

                                      // Main White Text
                                      Text(
                                        "SKINS",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // const Expanded(
                            //   child: Center(
                            //     child: DoodleText(
                            //       'SKINS',
                            //       fontSize: 32,
                            //       fillColor: Colors.white,
                            //       shadowColor: Color(0x33000000),
                            //     ),
                            //   ),
                            // ),

                            const SizedBox(width: 48),

                            // const SizedBox(width: 60),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              //   decoration: const BoxDecoration(
              //     color: Color(0xFF17A7F2),
              //     borderRadius:
              //         BorderRadius.vertical(bottom: Radius.circular(32)),
              //   ),
              //   child: Row(
              //     children: [
              //       StickerIconButton(
              //         icon: Icons.arrow_back_rounded,
              //         assetName: 'assets/images/close.png',
              //         size: 48,
              //         backgroundColor: Colors.white,
              //         iconColor: const Color(0xFF17A7F2),
              //         onPressed: () => Navigator.pop(context),
              //       ),
              //       const Expanded(
              //         child: Center(
              //           child: DoodleText(
              //             'SKINS',
              //             fontSize: 32,
              //             fillColor: Colors.white,
              //             shadowColor: Color(0x33000000),
              //           ),
              //         ),
              //       ),
              //       const SizedBox(width: 48), // Spacer to center the title
              //     ],
              //   ),
              // ),

              // Content
              Expanded(
                child: Consumer<SkinsViewModel>(
                  builder: (context, viewModel, _) {
                    return GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: viewModel.skins.length,
                      itemBuilder: (context, index) {
                        final skin = viewModel.skins[index];
                        final isSelected = skin.id == viewModel.selectedSkinId;
                        final isLocked = index >= viewModel.unlockedCount;
                        return InkWell(
                          onTap: isLocked
                              ? null
                              : tapActionCallback(
                                  context,
                                  () => viewModel.selectSkin(skin.id),
                                ),
                          // onTap: tapActionCallback(
                          //   context,
                          //   () => viewModel.selectSkin(skin.id),
                          // ),
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE58FFF)
                                    : Colors.transparent,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Image.asset(
                                    skin.image ?? 'assets/images/marker.png',
                                    fit: BoxFit.contain,
                                    height: 100,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            MarkerPreview(
                                      barrelColor: skin.barrelColor,
                                      capColor: skin.capColor,
                                      bandColor: skin.bandColor,
                                      nibColor: skin.nibColor,
                                      size: 100,
                                      showFace: skin.face,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF60D66A),
                                      size: 32,
                                    ),
                                  ),
                                if (isLocked)
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.lock_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
