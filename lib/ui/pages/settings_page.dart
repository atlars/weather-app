import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/provider/theme.dart';
import 'package:weather_app/util/extensions.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(currentThemeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme mode'),
            trailing: Text(themeMode.name.capitalize()),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const _ThemeModeDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeModeDialog extends ConsumerWidget {
  const _ThemeModeDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    void onModeTap(ThemeMode themeMode) {
      ref.read(currentThemeModeProvider.notifier).set(themeMode);
      Navigator.of(context).pop();
    }

    return SimpleDialog(
      clipBehavior: Clip.antiAlias,
      children: [
        for (final themeMode in ThemeMode.values)
          ListTile(
            onTap: () => onModeTap(themeMode),
            title: Text(themeMode.name.capitalize()),
          )
      ],
    );
  }
}
