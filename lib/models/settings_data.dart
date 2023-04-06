import 'package:isar/isar.dart';

part 'settings_data.g.dart';

@collection
class SettingsData {
  Id id = 0;

  bool isDarkTheme;
  bool showInitialHint;

  SettingsData(this.isDarkTheme, this.showInitialHint);
  SettingsData copyWith({bool? isDarkTheme, bool? showInitialHint}) {
    return SettingsData(isDarkTheme ?? this.isDarkTheme,
        showInitialHint ?? this.showInitialHint);
  }
}
