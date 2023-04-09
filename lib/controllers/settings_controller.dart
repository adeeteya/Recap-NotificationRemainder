import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/models/settings_data.dart';
import 'package:recap/services/isar_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsData>(
  (ref) => SettingsNotifier(
    SettingsData(
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark,
      true,
    ),
  ),
);

class SettingsNotifier extends StateNotifier<SettingsData> {
  SettingsNotifier(super.state) {
    initialize();
  }

  Future initialize() async {
    state = await IsarService().isar.settingsDatas.get(0) ??
        SettingsData(ThemeMode.system == ThemeMode.dark, true);
  }

  Future setInitialHint(bool showInitialHint) async {
    state = state.copyWith(showInitialHint: showInitialHint);
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.settingsDatas.put(state);
    });
  }

  Future toggleInitialHint() async {
    state = state.copyWith(showInitialHint: !state.showInitialHint);
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.settingsDatas.put(state);
    });
  }

  Future toggleThemeMode() async {
    state = state.copyWith(isDarkTheme: !state.isDarkTheme);
    await IsarService().isar.writeTxn(() async {
      await IsarService().isar.settingsDatas.put(state);
    });
  }
}
