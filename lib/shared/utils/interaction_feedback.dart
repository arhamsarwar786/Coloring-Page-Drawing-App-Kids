import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../features/sound/services/sound_service.dart';

Future<void> playTapFeedback(BuildContext context) async {
  try {
    await context.read<SoundService>().playTapFeedback();
  } catch (_) {}
}

Future<void> handleTapAction(
  BuildContext context,
  FutureOr<void> Function()? action,
) async {
  if (action == null) {
    return;
  }

  await playTapFeedback(context);
  await action();
}

VoidCallback? tapActionCallback(
  BuildContext context,
  FutureOr<void> Function()? action,
) {
  if (action == null) {
    return null;
  }

  return () {
    handleTapAction(context, action);
  };
}
