import 'package:intl/intl.dart';

/// Formats an ISO-8601 timestamp stored in SQLite for display.
/// Falls back to the raw value when it cannot be parsed.
String formatTimestamp(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  return DateFormat.yMMMd().add_jm().format(parsed.toLocal());
}

/// Splits a comma separated tag column into clean, de-duplicated tag names.
List<String> parseTags(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final seen = <String>{};
  for (final part in raw.split(',')) {
    final tag = part.trim();
    if (tag.isNotEmpty) seen.add(tag);
  }
  return seen.toList();
}

/// Normalizes user tag input back into the stored comma separated form.
String normalizeTags(String? raw) => parseTags(raw).join(', ');

/// Host of a URL, used as a compact subtitle. Returns the raw value on failure.
String urlHost(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;
  return uri.host;
}
