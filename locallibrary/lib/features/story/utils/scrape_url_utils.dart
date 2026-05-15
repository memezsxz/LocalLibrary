String? validateStoryUrlMessage(String raw) {
  final v = normalizeUrl(raw);
  if (v.isEmpty) return 'Problem: Url is required';

  final uri = Uri.tryParse(v);
  if (uri == null ||
      (uri.host != 'www.wattpad.com' && uri.host != 'wattpad.com')) {
    return 'Problem: not a wattpad.com URL';
  }

  // Expect /story/<digits>(-slug...)
  if (uri.pathSegments.length < 2 || uri.pathSegments.first != 'story') {
    return 'Problem: expected /story/<digits>(-slug)';
  }

  // First segment after /story must start with digits
  final idMatch = RegExp(r'^\d+').firstMatch(uri.pathSegments[1]);
  if (idMatch == null) {
    return 'Problem: missing numeric id after /story/';
  }

  return null; // valid!
}

String normalizeUrl(String raw) {
  // Trim, optionally force https + www if you prefer
  var v = raw.trim();
  // if (!v.startsWith('http')) v = 'https://$v';
  // v = v.replaceFirst('wattpad.com', 'www.wattpad.com'); // normalize host
  return v;
}
