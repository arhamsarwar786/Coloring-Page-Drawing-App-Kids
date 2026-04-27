import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/components/doodle_text.dart';
import '../../../shared/components/sticker_icon_button.dart';
import '../../../shared/utils/interaction_feedback.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StickerIconButton(
                size: 56,
                icon: Icons.arrow_back_rounded,
                // assetName: 'assets/images/retry.png',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 22),
              const Center(
                child: DoodleText(
                  'PRIVACY',
                  fontSize: 34,
                  fillColor: Color(0xFF1FA8F4),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF222222), width: 2),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 0,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  'This is a temporary in-app privacy placeholder. Replace this with your final privacy text or website URL when ready.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: tapActionCallback(
                    context,
                    () => Navigator.pop(context),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF33E61F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    AppStrings.back,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
