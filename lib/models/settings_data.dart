import 'package:isar/isar.dart';

part 'settings_data.g.dart';

@collection
class SettingsData {
  Id id = 0;

  bool isDarkTheme;
  bool showInitialHint;
  int colorValue;

  SettingsData(this.isDarkTheme, this.showInitialHint, this.colorValue);
  SettingsData copyWith(
      {bool? isDarkTheme, bool? showInitialHint, int? colorValue}) {
    return SettingsData(isDarkTheme ?? this.isDarkTheme,
        showInitialHint ?? this.showInitialHint, colorValue ?? this.colorValue);
  }
}
