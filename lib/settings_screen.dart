import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_connect/settings_provider.dart';
import 'package:social_connect/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to get the settings
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- DARK MODE TOGGLE ---
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable or disable dark theme'),
                trailing: Switch(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (isOn) {
                    final newMode = isOn ? ThemeMode.dark : ThemeMode.light;
                    // Use listen: false in an event
                    Provider.of<SettingsProvider>(context, listen: false)
                        .setThemeMode(newMode);
                  },
                ),
              ),
              const Divider(),

              // --- GRID/LIST VIEW TOGGLE ---
              ListTile(
                leading: const Icon(Icons.grid_view),
                title: const Text('Grid View on Profile'),
                subtitle: const Text('Show posts as a grid instead of a list'),
                trailing: Switch(
                  value: settings.isGridView,
                  onChanged: (isOn) {
                    Provider.of<SettingsProvider>(context, listen: false)
                        .toggleGridView();
                  },
                ),
              ),
              const Divider(),

              // --- Other Simple Items ---
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Kinekt'),
                subtitle: const Text('Version 1.0.0'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
