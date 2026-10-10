import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/utils/validators.dart';

/// Thin wrapper around the share-intent plugin so the rest of the app never
/// has to touch platform channels directly.
class ShareHandler {
  static Future<List<SharedMediaFile>> getSharedMedia() =>
      ReceiveSharingIntent.instance.getInitialMedia();

  static Stream<List<SharedMediaFile>> getSharedMediaStream() =>
      ReceiveSharingIntent.instance.getMediaStream();

  /// Pulls the first usable URL out of shared text.
  /// Returns `null` when the text holds nothing that looks like a link.
  static String? firstUrlFromText(String? text) {
    if (text == null) return null;
    for (final token in text.split(RegExp(r'\s+'))) {
      final candidate = token.trim();
      if (candidate.isEmpty) continue;
      if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
        if (isValidUrl(candidate)) return candidate;
      } else if (RegExp(r'^[\w-]+(\.[\w-]+)+(/\S*)?$').hasMatch(candidate)) {
        final normalized = normalizeUrl(candidate);
        if (isValidUrl(normalized)) return normalized;
      }
    }
    return null;
  }

  /// Extracts a shareable URL from the files handed over by Android.
  static String? urlFromSharedFiles(List<SharedMediaFile> files) {
    for (final file in files) {
      final url = firstUrlFromText(file.path);
      if (url != null) return url;
    }
    return null;
  }
}
