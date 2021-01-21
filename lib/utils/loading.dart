
class Loading {

  final Map<String, bool> _loading = {};

  /// Check if a loader is loading
  bool isLoading(List<String> keys) =>
      keys.isNotEmpty &&
          keys.map((key) => _loading[key] ?? false).reduce((v1, v2) => v1 || v2);

  /// Sets if a loader is loading
  void setLoading(String key, bool isLoading) => _loading[key] = isLoading;
}