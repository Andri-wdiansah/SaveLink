import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/core/utils/formatters.dart';
import 'package:savelink/core/utils/validators.dart';
import 'package:savelink/shared/components/share_handler.dart';

void main() {
  group('validators', () {
    test('accepts real URLs and rejects junk', () {
      expect(isValidUrl('https://example.com'), isTrue);
      expect(isValidUrl('example.com'), isTrue);
      expect(isValidUrl(''), isFalse);
      expect(isValidUrl('not a url'), isFalse);
    });

    test('normalizeUrl adds a scheme only when missing', () {
      expect(normalizeUrl('example.com'), 'https://example.com');
      expect(normalizeUrl('http://example.com'), 'http://example.com');
      expect(normalizeUrl('  '), '');
    });
  });

  group('formatters', () {
    test('parseTags trims, splits and de-duplicates', () {
      expect(parseTags('work, flutter , work'), ['work', 'flutter']);
      expect(parseTags(''), isEmpty);
      expect(parseTags(null), isEmpty);
    });

    test('normalizeTags produces a stable comma separated string', () {
      expect(normalizeTags(' a ,b,,a '), 'a, b');
    });

    test('urlHost extracts the host and falls back to the raw value', () {
      expect(urlHost('https://docs.flutter.dev/install'), 'docs.flutter.dev');
      expect(urlHost('garbage'), 'garbage');
    });

    test('formatTimestamp handles valid, empty and invalid input', () {
      expect(formatTimestamp(''), '');
      expect(formatTimestamp(null), '');
      expect(formatTimestamp('not-a-date'), 'not-a-date');
      expect(formatTimestamp('2024-01-01T10:00:00Z'), isNotEmpty);
    });
  });

  group('share handler', () {
    test('finds a URL inside shared text', () {
      expect(
        ShareHandler.firstUrlFromText('Check this out https://flutter.dev/x'),
        'https://flutter.dev/x',
      );
      expect(
        ShareHandler.firstUrlFromText('flutter.dev'),
        'https://flutter.dev',
      );
    });

    test('ignores text without a link', () {
      expect(ShareHandler.firstUrlFromText('just some words'), isNull);
      expect(ShareHandler.firstUrlFromText(''), isNull);
      expect(ShareHandler.firstUrlFromText(null), isNull);
    });
  });
}
