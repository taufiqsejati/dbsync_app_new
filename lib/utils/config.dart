class Config {
  String? get baseUrl => 'http://192.168.0.116';

  Uri? get uri {
    if (baseUrl == null) return null;
    return Uri.parse(baseUrl!);
  }
}
