import 'package:shared_preferences/shared_preferences.dart';

import 'save_adapter.dart';

/// Concrete implementation of [SaveAdapter].
/// This uses [SharedPreferences] to save and load.
class SharedPreferenceAdapter extends SaveAdapter {

  /// Creates a [SaveAdapter] using [SharedPreferences].
  ///
  /// [saveKey] will be a String to be used when saving and loading theme.
  /// If not provided this defaults to `theme_provider.theme`.
  SharedPreferenceAdapter({this.saveKey = 'theme_provider.theme'});
  /// String to be used when saving and loading theme.
  final String saveKey;

  @override
  Future<String?> loadTheme(final String providerId, [final String? defaultId]) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('$saveKey.$providerId') ?? defaultId;
  }

  @override
  Future<void> saveTheme(final String providerId, final String themeId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString('$saveKey.$providerId', themeId);
  }

  @override
  Future<void> forgetTheme(final String providerId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('$saveKey.$providerId');
  }
}
