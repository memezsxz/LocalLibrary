extension Addons on String {
  String removeTrailing(String pattern) {
    if (pattern.isEmpty) return this;
    var i = length;
    while (startsWith(pattern, i - pattern.length)) {
      i -= pattern.length;
    }
    return substring(0, i);
  }
}