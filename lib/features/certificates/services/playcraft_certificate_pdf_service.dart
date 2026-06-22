import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/playcraft_certificate_data.dart';

/// Generates the PlayCraft Kids certificate shown in the product design.
///
/// The PlayCraft wordmark, paint palette, stars, pencils, medal and borders
/// are all vector widgets/SVG. No image asset is required for this template.
class PlayCraftCertificatePdfService {
  PlayCraftCertificatePdfService._();

  static final PdfColor _navy = PdfColor.fromInt(0xFF173B6C);
  static final PdfColor _blue = PdfColor.fromInt(0xFF3686E8);
  static final PdfColor _sky = PdfColor.fromInt(0xFFEAF5FF);
  static final PdfColor _mint = PdfColor.fromInt(0xFFDDF8EE);
  static final PdfColor _purple = PdfColor.fromInt(0xFF7E66D8);
  static final PdfColor _yellow = PdfColor.fromInt(0xFFFFD45B);
  static final PdfColor _orange = PdfColor.fromInt(0xFFFF9E45);
  static final PdfColor _pink = PdfColor.fromInt(0xFFF87B9B);
  static final PdfColor _green = PdfColor.fromInt(0xFF42B883);
  static final PdfColor _cream = PdfColor.fromInt(0xFFFFFDF7);
  static final PdfColor _gold = PdfColor.fromInt(0xFFD99B27);
  static final PdfColor _lightGold = PdfColor.fromInt(0xFFFFE8A5);
  static final PdfColor _gray = PdfColor.fromInt(0xFF617184);
  static final PdfColor _lightGray = PdfColor.fromInt(0xFFD7E0EA);

  /// Builds a fixed, one-page, A4 landscape certificate PDF.
  static Future<Uint8List> buildPdf(PlayCraftCertificateData data) async {
    final pdf = pw.Document(
      title: 'PlayCraft Kids Certificate - ${data.childName}',
      author: 'PlayCraft Kids',
      subject: 'Certificate of Creative Achievement',
    );
    // final imageBytes =
    //     (await rootBundle.load('assets/app_icon.png')).buffer.asUint8List();
    // final image = pw.MemoryImage(imageBytes);

    final imageBytes = (await rootBundle.load('assets/images/app_icon.png'))
        .buffer
        .asUint8List();

    // 2. MemoryImage mein convert karein
    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildCertificate(data, image),
      ),
    );

    return pdf.save();
  }

  /// Opens the native share sheet with the generated certificate.
  static Future<void> share(PlayCraftCertificateData data) async {
    final bytes = await buildPdf(data);
    final safeName = data.childName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    await Printing.sharePdf(
      bytes: bytes,
      filename:
          'playcraft_certificate_${safeName.isEmpty ? 'child' : safeName}.pdf',
    );
  }

  static pw.Widget _buildCertificate(
      PlayCraftCertificateData data, pw.MemoryImage image) {
    const pageWidth = 841.89;
    const pageHeight = 595.28;
    final nameFontSize = _nameFontSize(data.childName);

    return pw.Container(
      width: pageWidth,
      height: pageHeight,
      color: _cream,
      child: pw.Stack(
        children: [
          // Pastel background shapes.
          pw.Positioned(
            left: -1,
            top: -1,
            child: _circle(110, _blue),
          ),
          pw.Positioned(
            left: 92,
            top: -28,
            child: _circle(55, _purple),
          ),
          pw.Positioned(
            right: -2,
            top: -17,
            child: _circle(116, _pink),
          ),
          pw.Positioned(
            left: -20,
            bottom: -25,
            child: _circle(120, _mint),
          ),
          pw.Positioned(
            right: -24,
            bottom: -29,
            child: _circle(140, _yellow),
          ),
          pw.Positioned(
            right: 122,
            bottom: -6,
            child: _circle(58, _green),
          ),

          // Double rounded certificate border.
          pw.Positioned(
            left: 23,
            right: 23,
            top: 23,
            bottom: 23,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _navy, width: 3),
                borderRadius: pw.BorderRadius.circular(22),
              ),
            ),
          ),
          pw.Positioned(
            left: 31,
            right: 31,
            top: 31,
            bottom: 31,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _lightGold, width: 1),
                borderRadius: pw.BorderRadius.circular(18),
              ),
            ),
          ),

          // Corner doodles.
          pw.Positioned(
              left: 57, top: 52, child: _star(size: 31, colorHex: '#FFD45B')),
          pw.Positioned(
              right: 54, top: 50, child: _star(size: 36, colorHex: '#F87B9B')),
          pw.Positioned(
              left: 58,
              bottom: 50,
              child: _star(size: 30, colorHex: '#3686E8')),
          pw.Positioned(
              right: 58,
              bottom: 52,
              child: _star(size: 30, colorHex: '#42B883')),
          pw.Positioned(
            left: 92,
            bottom: 56,
            child: _pencil(width: 64, height: 22, angle: 20),
          ),
          pw.Positioned(
            right: 132,
            top: 61,
            child: _pencil(width: 72, height: 24, angle: -24),
          ),

          // Logo and brand line.
          pw.Positioned(
            top: 52,
            left: 0,
            right: 0,
            child: pw.Center(child: _playCraftLogo(image)),
          ),
          pw.Positioned(
            top: 94,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                'A joyful place to create, learn, and celebrate imagination',
                style: pw.TextStyle(
                  font: pw.Font.helvetica(),
                  fontSize: 9.5,
                  color: _gray,
                ),
              ),
            ),
          ),

          // Heading.
          pw.Positioned(
            top: 130,
            left: 40,
            right: 40,
            child: pw.Center(
              child: pw.Text(
                'CERTIFICATE OF CREATIVE ACHIEVEMENT',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 25,
                  color: _navy,
                  letterSpacing: 1.15,
                ),
              ),
            ),
          ),
          pw.Positioned(
            top: 157,
            left: 0,
            right: 0,
            child: pw.Center(child: _goldDivider()),
          ),

          // Recipient name.
          pw.Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                'This certificate is proudly presented to',
                style: pw.TextStyle(
                  font: pw.Font.helvetica(),
                  fontSize: 12,
                  color: _gray,
                ),
              ),
            ),
          ),
          pw.Positioned(
            top: 212,
            left: 145,
            right: 145,
            child: pw.Center(
              child: pw.Text(
                data.childName.trim().isEmpty
                    ? 'Creative Star'
                    : data.childName.trim(),
                maxLines: 1,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: nameFontSize,
                  color: _purple,
                ),
              ),
            ),
          ),
          pw.Positioned(
            top: 267,
            left: 220,
            right: 220,
            child: pw.Container(height: 1.2, color: _purple),
          ),

          // Achievement message.
          pw.Positioned(
            top: 290,
            left: 130,
            right: 130,
            child: pw.Text(
              data.achievementText,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: pw.Font.helvetica(),
                fontSize: 12.8,
                color: _navy,
                lineSpacing: 4,
              ),
            ),
          ),

          // Milestone card and medal.
          pw.Positioned(
            left: 220,
            right: 220,
            top: 347,
            child: pw.Container(
              height: 54,
              padding: const pw.EdgeInsets.only(left: 95, top: 11, right: 16),
              decoration: pw.BoxDecoration(
                color: _sky,
                border: pw.Border.all(color: _blue, width: 1),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data.milestoneTitle,
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 12.5,
                      color: _navy,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Keep exploring, keep coloring, and keep creating amazing things!',
                    style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 9.8,
                      color: _gray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Positioned(
            left: 246,
            top: 345,
            child: _medal(data.milestoneNumber),
          ),

          // Issue details.
          pw.Positioned(
            left: 55,
            bottom: 79,
            child: pw.Text(
              'Certificate ID: ${data.certificateId}',
              style: pw.TextStyle(
                font: pw.Font.helvetica(),
                fontSize: 8.5,
                color: _gray,
              ),
            ),
          ),
          pw.Positioned(
            right: 55,
            bottom: 79,
            child: pw.Text(
              'Issued: ${_formatDate(data.issuedAt)}',
              style: pw.TextStyle(
                font: pw.Font.helvetica(),
                fontSize: 8.5,
                color: _gray,
              ),
            ),
          ),

          // Signatures.
          pw.Positioned(
            left: 112,
            bottom: 38,
            child: _signature(
              signature: data.teamSignatureName,
              label: 'PlayCraft Kids Team',
            ),
          ),
          pw.Positioned(
            right: 112,
            bottom: 38,
            child: _signature(
              signature: 'Proudly Celebrating ${_firstName(data.childName)}',
              label: data.parentSignatureName,
            ),
          ),

          // Footer dots.
          pw.Positioned(
            left: 0,
            right: 0,
            bottom: 33,
            child: pw.Center(child: _footerDots()),
          ),
        ],
      ),
    );
  }

  static pw.Widget _circle(double size, PdfColor color) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(size / 2),
      ),
    );
  }

  static pw.Widget _playCraftLogo(pw.MemoryImage image) {
//     final image = pw.MemoryImage (
//   (await rootBundle.load('assets/my_image.png')).buffer.asUint8List(),
// );
    final letters = <MapEntry<String, PdfColor>>[
      MapEntry('P', _blue),
      MapEntry('L', _purple),
      MapEntry('A', _orange),
      MapEntry('Y', _green),
      MapEntry('C', _pink),
      MapEntry('R', _blue),
      MapEntry('A', _purple),
      MapEntry('F', _orange),
      MapEntry('T', _green),
    ];

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Image(image, width: 40, height: 40),
        // _svg(_paintPaletteSvg(), width: 77, height: 40),
        pw.SizedBox(width: 4),
        ...letters.map(
          (entry) => pw.Text(
            entry.key,
            style: pw.TextStyle(
              font: pw.Font.helveticaBold(),
              fontSize: 28,
              color: entry.value,
            ),
          ),
        ),
        pw.SizedBox(width: 11),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: pw.BoxDecoration(
            color: _navy,
            borderRadius: pw.BorderRadius.circular(11),
          ),
          child: pw.Text(
            'KIDS',
            style: pw.TextStyle(
              font: pw.Font.helveticaBold(),
              fontSize: 8.2,
              color: PdfColors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _goldDivider() {
    return pw.SizedBox(
      width: 350,
      height: 16,
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: 0,
            right: 0,
            top: 7,
            child: pw.Container(height: 1.4, color: _gold),
          ),
          pw.Positioned(
            left: 169,
            top: 0,
            child: _star(size: 14, colorHex: '#D99B27'),
          ),
        ],
      ),
    );
  }

  static pw.Widget _medal(int milestoneNumber) {
    return pw.SizedBox(
      width: 72,
      height: 83,
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: 4,
            top: 35,
            child: _svg(_ribbonSvg('#7E66D8'), width: 34, height: 45),
          ),
          pw.Positioned(
            right: 3,
            top: 35,
            child: _svg(_ribbonSvg('#3686E8'), width: 34, height: 45),
          ),
          pw.Positioned(
            left: 8,
            top: 5,
            child: pw.Container(
              width: 57,
              height: 57,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: _gold,
                border: pw.Border.all(color: _lightGold, width: 3),
                borderRadius: pw.BorderRadius.circular(29),
              ),
              child: pw.Text(
                milestoneNumber.toString(),
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _signature(
      {required String signature, required String label}) {
    return pw.SizedBox(
      width: 150,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            signature,
            textAlign: pw.TextAlign.center,
            maxLines: 1,
            style: pw.TextStyle(
              font: pw.Font.helveticaOblique(),
              fontSize: 12,
              color: _navy,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(height: 1, color: _lightGray),
          pw.SizedBox(height: 7),
          pw.Text(
            label,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: pw.Font.helvetica(),
              fontSize: 8.5,
              color: _gray,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footerDots() {
    final dotColors = <PdfColor>[_blue, _purple, _orange, _green, _pink];
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: dotColors
          .map(
            (color) => pw.Container(
              width: 5,
              height: 5,
              margin: const pw.EdgeInsets.symmetric(horizontal: 2.5),
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(3),
              ),
            ),
          )
          .toList(),
    );
  }

  static pw.Widget _star({required double size, required String colorHex}) {
    return _svg(
      '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <polygon points="50,4 61,37 96,37 67,57 78,92 50,71 22,92 33,57 4,37 39,37" fill="$colorHex"/>
</svg>
''',
      width: size,
      height: size,
    );
  }

  static pw.Widget _pencil({
    required double width,
    required double height,
    required int angle,
  }) {
    return _svg(_pencilSvg(angle), width: width, height: height);
  }

  static pw.Widget _svg(String svg,
      {required double width, required double height}) {
    return pw.SizedBox(
      width: width,
      height: height,
      child: pw.SvgImage(svg: svg),
    );
  }

  static String _paintPaletteSvg() => '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 165 70">
  <circle cx="31" cy="35" r="24" fill="#FF9E45" stroke="#FFFFFF" stroke-width="2"/>
  <circle cx="42" cy="46" r="8" fill="#FFFDF7"/>
  <circle cx="21" cy="25" r="4" fill="#7E66D8"/>
  <circle cx="31" cy="19" r="4" fill="#3686E8"/>
  <circle cx="42" cy="26" r="4" fill="#42B883"/>
  <circle cx="17" cy="37" r="4" fill="#F87B9B"/>
  <rect x="59" y="35" width="55" height="12" rx="6" fill="#173B6C"/>
  <rect x="64" y="38" width="43" height="6" rx="3" fill="#FFD45B"/>
  <circle cx="118" cy="41" r="7" fill="#173B6C"/>
</svg>
''';

  static String _pencilSvg(int angle) => '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 80 34">
  <g transform="rotate($angle 40 17)">
    <rect x="7" y="11" width="48" height="12" rx="4" fill="#FFD45B" stroke="#173B6C" stroke-width="1.4"/>
    <rect x="7" y="11" width="9" height="12" fill="#F87B9B"/>
    <path d="M55 11 L69 17 L55 23 Z" fill="#FFFDF7" stroke="#173B6C" stroke-width="1.4"/>
    <path d="M66 15 L72 17 L66 19 Z" fill="#173B6C"/>
  </g>
</svg>
''';

  static String _ribbonSvg(String colorHex) => '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 34 48">
  <path d="M5 2 L28 2 L23 45 L17 38 L10 45 Z" fill="$colorHex"/>
</svg>
''';

  static String _formatDate(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _firstName(String fullName) {
    final cleaned = fullName.trim();
    if (cleaned.isEmpty) return 'Our Star';
    return cleaned.split(RegExp(r'\s+')).first;
  }

  static double _nameFontSize(String name) {
    final length = name.trim().length;
    if (length <= 15) return 38;
    if (length <= 22) return 32;
    if (length <= 30) return 26;
    return 22;
  }
}
