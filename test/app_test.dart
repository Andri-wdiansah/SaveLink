import 'package:flutter_test/flutter_test.dart';
import 'package:savelink/core/utils/validators.dart';
import 'package:savelink/models/link_item.dart';

void main() {
  group('URL validation', () {
    test('valid https URL',
        () => expect(isValidUrl('https://example.com'), true));
    test('invalid empty string', () => expect(isValidUrl(''), false));
    test('normalization adds https',
        () => expect(normalizeUrl('example.com'), 'https://example.com'));
  });
  group('Link model', () {
    test('serialization roundtrip', () {
      final item = LinkItem(
          id: 1,
          title: 'Test',
          url: 'https://test.com',
          description: 'Desc',
          tags: 'tag1',
          favorite: true,
          pinned: false,
          archived: false,
          createdAt: '2024-01-01T00:00:00Z',
          updatedAt: '2024-01-01T00:00:00Z');
      final map = item.toMap();
      final rebuilt = LinkItem.fromMap(map);
      expect(rebuilt.title, 'Test');
      expect(rebuilt.url, 'https://test.com');
      expect(rebuilt.favorite, true);
    });
  });
}
