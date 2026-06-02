import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:play_craft_kids/features/tracing/viewmodel/tracing_viewmodel.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_header.dart';
import 'package:play_craft_kids/features/tracing/widgets/tracing_board.dart';
import 'package:play_craft_kids/features/tracing/view/tracing_completion_screen.dart';

class TracingScreen extends StatefulWidget {
  const TracingScreen({super.key});

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  TracingProvider? _provider;

  @override
  void initState() {
    super.initState();
    // Stop background music when tracing starts
    // MusicService.instance.stopBackgroundMusic();

    // Add a listener to the provider to push the completion screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _provider = Provider.of<TracingProvider>(context, listen: false);
      _provider?.addListener(_onProviderChange);
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    // Resume background music when leaving tracing screen
    // MusicService.instance.startBackgroundMusic();
    super.dispose();
  }

  void _onProviderChange() {
    if (!mounted) return;
    final provider = Provider.of<TracingProvider>(context, listen: false);
    if (provider.status == TracingStatus.passed) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TracingCompletionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TracingProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TracingHeader(),
            ),
            const SizedBox(height: 36),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TracingBoard(provider: provider),
              ),
            ),
            const SizedBox(height: 36),
          ],
        );
      },
    );
  }
}
