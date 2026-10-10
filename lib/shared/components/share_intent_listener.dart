import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../features/links/link_editor_screen.dart';
import '../../features/links/share_review_screen.dart';
import 'share_handler.dart';

/// Listens for "Share to SaveLink" intents from Android and opens the review
/// flow. Failures are logged instead of breaking the app shell, because the
/// share channel is optional.
class ShareIntentListener extends ConsumerStatefulWidget {
  final Widget child;

  const ShareIntentListener({super.key, required this.child});

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  StreamSubscription<List<SharedMediaFile>>? _subscription;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final initial = await ShareHandler.getSharedMedia();
      if (initial.isNotEmpty) await _handle(initial);
      _subscription = ShareHandler.getSharedMediaStream().listen((files) {
        if (files.isNotEmpty) _handle(files);
      });
    } catch (error, stack) {
      debugPrint('Share intent listener unavailable: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _handle(List<SharedMediaFile> files) async {
    if (_handling || !mounted) return;
    final url = ShareHandler.urlFromSharedFiles(files);
    if (url == null) return;

    _handling = true;
    try {
      final reviewed = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => ShareReviewScreen(url: url)),
      );
      if (reviewed != null && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LinkEditorScreen(initialUrl: reviewed),
          ),
        );
      }
    } finally {
      _handling = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
