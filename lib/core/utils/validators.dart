bool isValidUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return false;
  try {
    final uri = Uri.tryParse(trimmed);
    if (uri == null || (!uri.hasScheme && !trimmed.contains('.'))) return false;
    final normalized = trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final check = Uri.parse(normalized);
    return check.hasScheme && check.host.isNotEmpty;
  } catch (_) {
    return false;
  }
}

String normalizeUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  return (trimmed.startsWith('http://') || trimmed.startsWith('https://')) ? trimmed : 'https://$trimmed';
}
