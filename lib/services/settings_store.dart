import 'package:hive_flutter/hive_flutter.dart';

class SettingsStore {
  static const String _boxName = 'settings_box_v1';
  static const String _kLocaleCode = 'locale_code';
  static const String _kLanguageChosen = 'language_chosen';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    try {
      return await Hive.openBox(_boxName);
    } on HiveError {
      // Ensure Hive is initialized in case it wasn't yet.
      await Hive.initFlutter();
      return await Hive.openBox(_boxName);
    }
  }

  Future<String?> getLocaleCode() async {
    final box = await _openBox();
    return box.get(_kLocaleCode) as String?;
    }

  Future<void> setLocaleCode(String? code) async {
    final box = await _openBox();
    if (code == null) {
      await box.delete(_kLocaleCode);
    } else {
      await box.put(_kLocaleCode, code);
    }
  }

  Future<bool> isLanguageChosen() async {
    final box = await _openBox();
    return (box.get(_kLanguageChosen) as bool?) ?? false;
  }

  Future<void> setLanguageChosen(bool value) async {
    final box = await _openBox();
    await box.put(_kLanguageChosen, value);
  }
}
