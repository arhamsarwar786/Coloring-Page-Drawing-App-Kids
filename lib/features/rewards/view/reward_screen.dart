import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../shared/utils/interaction_feedback.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key, required this.args});

  final RewardRouteArgs args;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool _isSharing = false;

  RewardRouteArgs get args => widget.args;

  void _openReplay(BuildContext context) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.drawing,
      arguments: DrawingRouteArgs(levelId: args.levelId),
    );
  }

  void _openNext(BuildContext context) {
    final nextLevelId = args.nextLevelId;
    if (nextLevelId != null) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.drawing,
        arguments: DrawingRouteArgs(levelId: nextLevelId),
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }

  Future<void> _shareArtwork() async {
    final bytes = args.completedImageBytes;
    if (bytes == null || bytes.isEmpty || _isSharing) {
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      final temporaryDirectory = await getTemporaryDirectory();
      final safeTitle =
          args.levelTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
      final file = File(
        '${temporaryDirectory.path}/drawing_${args.levelNumber}_$safeTitle.png',
      );
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        <XFile>[XFile(file.path)],
        text: 'I completed ${args.levelTitle} in Coloring Page Drawing!',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD7EFFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 12.0 : 20.0;
            final verticalPadding = constraints.maxHeight < 760 ? 16.0 : 28.0;
            final cardWidth = (constraints.maxWidth - (horizontalPadding * 2))
                .clamp(280.0, 420.0)
                .toDouble();
            final isCompact = constraints.maxWidth < 390;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - verticalPadding - 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _RewardPostCard(
                      args: args,
                      width: cardWidth,
                      isCompact: isCompact,
                      isSharing: _isSharing,
                      onShare: _shareArtwork,
                    ),
                    SizedBox(height: isCompact ? 20 : 30),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 16,
                      children: <Widget>[
                        _ActionTileButton(
                          width: isCompact ? 124 : 140,
                          height: isCompact ? 82 : 92,
                          backgroundColor: const Color(0xFF5AA6FF),
                          borderColor: const Color(0xFF2D64C8),
                          shadowColor: const Color(0x332D64C8),
                          onTap: () => _openReplay(context),
                          child: Icon(
                            Icons.replay_rounded,
                            size: isCompact ? 42 : 50,
                            color: Colors.white,
                          ),
                        ),
                        _ActionTileButton(
                          width: isCompact ? 176 : 220,
                          height: isCompact ? 82 : 92,
                          backgroundColor: const Color(0xFF7DE952),
                          borderColor: const Color(0xFF45A92B),
                          shadowColor: const Color(0x3345A92B),
                          onTap: () => _openNext(context),
                          child: Text(
                            args.nextLevelId != null ? 'NEXT' : 'HOME',
                            style: GoogleFonts.fredoka(
                              fontSize: isCompact ? 30 : 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: const <Shadow>[
                                Shadow(
                                  color: Color(0x55000000),
                                  offset: Offset(0, 2),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Reward Card With Share Action and Post Details
class _RewardPostCard extends StatelessWidget {
  const _RewardPostCard({
    required this.args,
    required this.width,
    required this.isCompact,
    required this.isSharing,
    required this.onShare,
  });

  final RewardRouteArgs args;
  final double width;
  final bool isCompact;
  final bool isSharing;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final imageBytes = args.completedImageBytes;
    final imageSize = width - (isCompact ? 28 : 36);
    final titleFontSize = isCompact ? 22.0 : 28.0;
    final actionIconSize = isCompact ? 30.0 : 34.0;

    return Container(
      width: width,
      padding: EdgeInsets.fromLTRB(
        isCompact ? 14 : 18,
        isCompact ? 14 : 18,
        isCompact ? 14 : 18,
        isCompact ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: isCompact ? 38 : 42,
                height: isCompact ? 38 : 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color(0xFFF58529),
                      Color(0xFFFEDA77),
                      Color(0xFFDD2A7B),
                      Color(0xFF8134AF),
                      Color(0xFF515BD4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: isCompact ? 22 : 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'JOHN',
                  style: GoogleFonts.fredoka(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: 
                  
 isSharing ? null : tapActionCallback(context, onShare),





               
                icon: Icon(
                  Icons.share_rounded,
                  size: isCompact ? 26 : 30,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: imageSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: imageBytes != null && imageBytes.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.memory(
                      imageBytes,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  )
                : Container(
                    color: const Color(0xFFF7F7F7),
                    alignment: Alignment.center,
                    child: Text(
                      args.levelTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF555555),
                      ),
                    ),
                  ),
          ),
          // const SizedBox(height: 16),
          // Row(
          //   children: <Widget>[
          //     Icon(
          //       Icons.favorite,
          //       color: const Color(0xFFFF2F68),
          //       size: actionIconSize + 2,
          //     ),
          //     const SizedBox(width: 14),
          //     Icon(
          //       Icons.mode_comment_outlined,
          //       color: Colors.black,
          //       size: actionIconSize,
          //     ),
          //     const SizedBox(width: 14),
          //     GestureDetector(
          //       onTap: isSharing ? null : tapActionCallback(context, onShare),
          //       child: Opacity(
          //         opacity: isSharing ? 0.55 : 1,
          //         child: Icon(
          //           Icons.send_outlined,
          //           color: Colors.black,
          //           size: actionIconSize,
          //         ),
          //       ),
          //     ),
          //     const Spacer(),
          //     Icon(
          //       Icons.bookmark,
          //       color: Colors.black,
          //       size: actionIconSize,
          //     ),
          //   ],
          // ),
          
          
          const SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     Container(
          //       width: 8,
          //       height: 8,
          //       decoration: const BoxDecoration(
          //         color: Color(0xFF1EA1FF),
          //         shape: BoxShape.circle,
          //       ),
          //     ),
          //     const SizedBox(width: 6),
          //     _dot(),
          //     const SizedBox(width: 6),
          //     _dot(),
          //   ],
          // ),
          // const SizedBox(height: 10),
          
          Text(
            'EXCELLENT!',
            style: GoogleFonts.fredoka(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level ${args.levelNumber} completed - +${args.coins} coins',
            style: GoogleFonts.fredoka(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4D4D4D),
            ),
          ),
          // const SizedBox(height: 14),

          // SizedBox(
          //   width: double.infinity,
          //   child: GestureDetector(
          //     onTap: isSharing ? null : tapActionCallback(context, onShare),
          //     child: AnimatedOpacity(
          //       duration: const Duration(milliseconds: 180),
          //       opacity: isSharing ? 0.6 : 1,
          //       child: Container(
          //         padding: EdgeInsets.symmetric(
          //           horizontal: isCompact ? 14 : 16,
          //           vertical: isCompact ? 12 : 14,
          //         ),
          //         decoration: BoxDecoration(
          //           color: const Color(0xFFF5F9FF),
          //           borderRadius: BorderRadius.circular(16),
          //           border: Border.all(color: const Color(0xFFDDE7F4)),
          //         ),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: <Widget>[
          //             Icon(
          //               isSharing
          //                   ? Icons.hourglass_top_rounded
          //                   : Icons.ios_share_rounded,
          //               size: isCompact ? 20 : 22,
          //               color: const Color(0xFF1A1A1A),
          //             ),
          //             const SizedBox(width: 10),
          //             Text(
          //               isSharing ? 'Sharing...' : 'Share My Drawing',
          //               style: GoogleFonts.fredoka(
          //                 fontSize: isCompact ? 16 : 18,
          //                 fontWeight: FontWeight.w600,
          //                 color: const Color(0xFF1A1A1A),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFB9BDC3),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ActionTileButton extends StatelessWidget {
  const _ActionTileButton({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.onTap,
    required this.child,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapActionCallback(context, onTap),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
