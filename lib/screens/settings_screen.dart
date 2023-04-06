import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsData = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile.adaptive(
            value: settingsData.isDarkTheme,
            title: const Text("Dark Mode"),
            onChanged: (_) async {
              await ref.read(settingsProvider.notifier).toggleThemeMode();
            },
          ),
          const Divider(),
          SwitchListTile.adaptive(
            value: settingsData.showInitialHint,
            title: const Text("Show Hint at Startup"),
            onChanged: (_) async {
              await ref.read(settingsProvider.notifier).toggleInitialHint();
            },
          ),
        ],
      ),
    );
  }
}
