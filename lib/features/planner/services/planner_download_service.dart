import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../model/planner_progress_model.dart';

/// Copies bundled planner PDFs and shares / saves them for parents.
class PlannerDownloadService {
  static const String _assetFolder =
      'assets/PlayCraft_Kids_Hyperlinked_Planner_Bundle';

  Future<Uint8List> loadBytes(PlannerPdfFormat format) async {
    final data = await rootBundle.load('$_assetFolder/${format.assetFileName}');
    return data.buffer.asUint8List();
  }

  /// Opens the native share sheet so parents can Save to Files, Drive, print, etc.
  Future<void> sharePdf(PlannerPdfFormat format) async {
    final bytes = await loadBytes(format);

    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: format.downloadFileName,
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${format.downloadFileName}');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'PlayCraft Kids Planner (${format.shortLabel})',
      text:
          'Your child\'s PlayCraft Kids Hyperlinked Planner — 36 pages of '
          'routines, coloring quests, and calm planning for every day.',
    );
  }

  /// Opens the system print / PDF preview dialog.
  Future<void> printPdf(PlannerPdfFormat format) async {
    final bytes = await loadBytes(format);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: format.downloadFileName,
    );
  }
}
