import 'package:flutter/material.dart';
import 'package:play_craft_kids/features/drawing/view/drawing_screen.dart';
import 'package:play_craft_kids/features/home/components/app_bar_clipper.dart';
import 'package:printing/printing.dart';

import '../models/playcraft_certificate_data.dart';
import '../services/playcraft_certificate_pdf_service.dart';

/// Push this page after the child has reached the required score/coin condition.
/// It gives the parent a preview, print option and share/save action.
class PlayCraftCertificatePreviewScreen extends StatelessWidget {
  const PlayCraftCertificatePreviewScreen({
    super.key,
    required this.certificate,
  });

  final PlayCraftCertificateData certificate;

  @override
  Widget build(BuildContext context) {
    print("Preview Screen is building!");
    return Container(
      // height: double.infinity,
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage(
      //         "assets/images/reward.webp"), // Replace with your image path
      //     fit: BoxFit.cover,
      //     colorFilter: ColorFilter.mode(
      //       Colors.white.withOpacity(0.3),
      //       BlendMode.lighten,
      //     ), // Adjust the fit to your liking
      //   ),
      // ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   title: const Text('Creative Achievement Certificate'),
        //   actions: [
        //     IconButton(
        //       tooltip: 'Share certificate',
        //       icon: const Icon(Icons.share_outlined),
        //       onPressed: () => PlayCraftCertificatePdfService.share(certificate),
        //     ),
        //   ],
        // ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 90,
                      // width: double.infinity,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: AppBarClipper(),
                            child: Container(
                              height: 120,
                              margin: EdgeInsets.only(bottom: 10),
                              color: const Color(0xff3b9499),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: SidebarIcon(
                                      icon: Icons.arrow_back_rounded,
                                      assetName: 'assets/images/pop-button.png',
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),

                                  // Title
                                  // Title
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
                                                "Creative Achievement Certificate",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  fontFamily: "Regular",
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black
                                                      .withOpacity(0.35),
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),

                                            // Pink 3D Layer
                                            Transform.translate(
                                              offset: const Offset(3, 3),
                                              child: Text(
                                                "Creative Achievement Certificate",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 30,
                                                  fontFamily: "Regular",
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFFFF4FA3),
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),

                                            // Main White Text
                                            Text(
                                              "Creative Achievement Certificate",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontFamily: "Regular",
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

                                  const SizedBox(width: 60),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PdfPreview(
                // pages: [],
                // canChangeOrientation: true,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                allowPrinting: true,
                allowSharing: true,

                // usePrintDialog: true,
                pdfFileName: 'playcraft_certificate.pdf',
                build: (_) =>
                    PlayCraftCertificatePdfService.buildPdf(certificate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
