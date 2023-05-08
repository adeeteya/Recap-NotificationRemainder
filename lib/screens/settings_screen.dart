import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recap/controllers/settings_controller.dart';
import 'package:recap/widgets/change_theme_color_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsData = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Back",
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Theme Color"),
            onTap: () async {
              int? newSelectedColor = await showChangeThemeColorDialog(
                  context, settingsData.colorValue);
              if (newSelectedColor != null) {
                ref
                    .read(settingsProvider.notifier)
                    .changeThemeColor(newSelectedColor);
              }
            },
            trailing: SizedBox(
              height: 35,
              width: 35,
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  color: Color(settingsData.colorValue),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
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
