/// Abstract implementation on how to save a theme
abstract class SaveAdapter {
  /// Loads the theme previously saved on disk.
  /// If previous record not found, returns [defaultId].
  /// If [defaultId] is not given `null` will be returned.
  Future<String?> loadTheme(final String providerId, [final String? defaultId]);

  /// Saves the given theme id on the disk.
  Future<void> saveTheme(final String providerId, final String themeId);

  /// Remove current configuration from disk.
  Future<void> forgetTheme(final String providerId);
}
