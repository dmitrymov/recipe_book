import 'package:flutter/material.dart';
import '../services/settings_store.dart';

class LocaleProvider extends ChangeNotifier {
  final SettingsStore _store;
  Locale? _locale;
  bool _initialized = false;

  LocaleProvider({SettingsStore? store}) : _store = store ?? SettingsStore();

  bool get initialized => _initialized;
  Locale? get locale => _locale;

  Future<void> load() async {
    final code = await _store.getLocaleCode();
    if (code != null) {
      _locale = Locale(code);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    await _store.setLocaleCode(locale?.languageCode);
    await _store.setLanguageChosen(true);
    notifyListeners();
  }

  Future<bool> isLanguageChosen() => _store.isLanguageChosen();
}
