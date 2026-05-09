import 'dart:typed_data';

import 'package:asmr_coloring_app/features/drawing/viewmodel/drawing_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/components/app_gradient_background.dart';
import '../../../shared/widgets/loader.dart';
import '../../history/model/drawing_history_entry.dart';
import '../../history/viewmodel/history_viewmodel.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryViewModel>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Consumer<HistoryViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Loader();
              }

              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Row(
                      children: <Widget>[
                        _HistoryIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Drawing History',
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2A44),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: viewModel.load,
                      child: viewModel.isEmpty
                          ? const _EmptyHistoryState()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                              itemCount: viewModel.entries.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final entry = viewModel.entries[index];
                                int? completionCount;
                                if (entry.isCompleted) {
                                  final sameLevelCompleted = viewModel.entries
                                      .where((e) => e.levelId == entry.levelId && e.isCompleted)
                                      .toList();
                                  sameLevelCompleted.sort((a, b) => a.lastEditedAt.compareTo(b.lastEditedAt));
                                  final order = sameLevelCompleted.indexWhere((e) => e.id == entry.id) + 1;
                                  if (order > 1) {
                                    completionCount = order;
                                  }
                                }

                                return _HistoryCard(
                                  entry: entry,
                                  completionCount: completionCount,
                                  onTap: () =>
                                      _openHistoryEntry(context, entry),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openHistoryEntry(
    BuildContext context,
    DrawingHistoryEntry entry,
  ) async {
    final drawingVm = context.read<DrawingViewModel>();

    // If the drawing screen is already active for this level, just pop back to it
    // to avoid duplicated listeners and singleton state conflicts.
    if (drawingVm.isActive && drawingVm.level?.id == entry.levelId) {
      Navigator.pop(context);
      return;
    }

    await Navigator.pushNamed(
      context,
      AppRoutes.drawing,
      arguments: DrawingRouteArgs(
        levelId: entry.levelId,
        levelTitle: entry.levelTitle,
        levelNumber: entry.levelNumber,
        drawingSessionId: entry.id,
      ),
    );
    if (!context.mounted) return;
    await context.read<HistoryViewModel>().load();
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(28),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x1A16325C),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  size: 40,
                  color: Color(0xFFF28B1D),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No drawings yet',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2A44),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start drawing and your saved progress will appear here automatically.',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF65738A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    this.completionCount,
    required this.onTap,
  });

  final DrawingHistoryEntry entry;
  final int? completionCount;
  final VoidCallback onTap;

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailBytes = entry.decodeThumbnail();
    final progressLabel = '${(entry.progress * 100).round()}%';
    final badgeColor =
        entry.isCompleted ? const Color(0xFF2FB36D) : const Color(0xFFF29A2E);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(32),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x120F2A50),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _HistoryThumbnail(
                bytes: thumbnailBytes == null
                    ? null
                    : Uint8List.fromList(thumbnailBytes),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            entry.levelTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E2742),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entry.status.label,
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            entry.levelNumber == null
                                ? 'Saved drawing'
                                : 'Level ${entry.levelNumber}',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6A768E),
                            ),
                          ),
                        ),
                        if (completionCount != null && completionCount! > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4F8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_ordinal(completionCount!)} Time',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5A667E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: entry.progress.clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: const Color(0xFFF2F5FA),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                badgeColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          progressLabel,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF22304B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatLastEdited(entry.lastEditedAt),
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7D879C),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: const Color(0xFFBDC5D1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatLastEdited(DateTime value) {
    final now = DateTime.now();
    final difference = now.difference(value);
    if (difference.inMinutes < 1) {
      return 'Edited just now';
    }
    if (difference.inHours < 1) {
      return 'Edited ${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return 'Edited ${difference.inHours} hr ago';
    }
    return 'Edited ${value.day}/${value.month}/${value.year}';
  }
}

class _HistoryThumbnail extends StatelessWidget {
  const _HistoryThumbnail({required this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes == null || bytes!.isEmpty
          ? const Center(
              child: Icon(
                Icons.brush_outlined,
                size: 48,
                color: Color(0xFFBDC5D1),
              ),
            )
          : Image.memory(
              bytes!,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
    );
  }
}

class _HistoryIconButton extends StatelessWidget {
  const _HistoryIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: const Color(0xFF25314B),
            size: 26,
          ),
        ),
      ),
    );
  }
}
