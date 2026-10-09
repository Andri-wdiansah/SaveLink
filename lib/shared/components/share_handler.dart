import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareHandler {
  static Future<List<SharedMediaFile>> getSharedMedia() => ReceiveSharingIntent.getInitialMedia();
  static Stream<List<SharedMediaFile>> getSharedMediaStream() => ReceiveSharingIntent.getMediaStream();
}
