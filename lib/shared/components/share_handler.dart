import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareHandler {
  static Future<List<SharedMediaFile>> getSharedMedia() => ReceiveSharingIntent.instance.getInitialMedia();
  static Stream<List<SharedMediaFile>> getSharedMediaStream() => ReceiveSharingIntent.instance.getMediaStream();
}
