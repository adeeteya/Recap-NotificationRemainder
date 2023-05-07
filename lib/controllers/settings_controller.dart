import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/models/settings_data.dart';
import 'package:recap/services/isar_service.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsData>(() => SettingsNotifier());

class SettingsNotifier extends Notifier<SettingsData> {
  @override
  SettingsData build() {
    initialize();
    return SettingsData(
      SchedulerBinding.instance.window.platformBrightness == Brightness.dark,
      true,
      Colors.amber.value,
    );
  }

  Future initialize() async {
    state = await IsarService().isar.settingsDatas.get(0) ??
        SettingsData(
          SchedulerBinding.instance.window.platformBrightness ==
              Brightness.dark,
          true,
          Colors.amber.value,
        );
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
