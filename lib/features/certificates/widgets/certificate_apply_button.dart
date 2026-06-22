import 'package:flutter/material.dart';

import '../models/playcraft_certificate_data.dart';
import '../view/playcraft_certificate_preview_screen.dart';

/// Add this below the score/result UI on ColoringCompletionScreen.
///
/// Pass the child's verified display name and a unique certificate ID from
/// Supabase (recommended) or from your own backend logic.
class CertificateApplyButton extends StatelessWidget {
  const CertificateApplyButton({
    super.key,
    required this.currentScore,
    required this.requiredScore,
    required this.certificate,
  });

  final int currentScore;
  final int requiredScore;
  final PlayCraftCertificateData certificate;

  @override
  Widget build(BuildContext context) {
    final isEligible = currentScore >= requiredScore;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.workspace_premium_outlined),
        label: Text(
          isEligible
              ? 'Apply for Certificate'
              : 'Reach $requiredScore points to unlock your certificate',
        ),
        onPressed: () {
          if (!isEligible) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Keep coloring! You need ${requiredScore - currentScore} more points.',
                ),
              ),
            );
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlayCraftCertificatePreviewScreen(
                certificate: certificate,
              ),
            ),
          );
        },
      ),
    );
  }
}
