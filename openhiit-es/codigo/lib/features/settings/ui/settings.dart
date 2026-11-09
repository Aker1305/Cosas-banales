// settings_page.dart
import 'package:background_hiit_timer/utils/voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:openhiit/core/providers/theme_provider/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showColorPicker(BuildContext context, Color currentColor) {
    Color pickedColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Color de énfasis'),
          content: MaterialColorPicker(
            allowShades: false,
            selectedColor: pickedColor,
            onMainColorChange: (swatch) {
              setState(() => pickedColor = swatch!);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                context.read<ThemeProvider>().setSeedColor(pickedColor);
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seedColor = context.watch<ThemeProvider>().seedColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text('Apariencia'),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Tema'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _themeModeLabel(context.watch<ThemeProvider>().themeMode),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onPressed: (context) => _showThemePicker(context),
              ),
              CustomSettingsTile(
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  title: const Text('Color de énfasis'),
                  subtitle: const Text('Color principal de la app'),
                  trailing: CircleColor(
                    color: seedColor,
                    circleSize: 32,
                  ),
                  onTap: () => _showColorPicker(context, seedColor),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Audio'),
            tiles: [
              CustomSettingsTile(child: const _VoiceAnnouncementsTile()),
            ],
          ),
          SettingsSection(
            title: const Text('Acerca de'),
            tiles: [
              SettingsTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de privacidad'),
                trailing: const Icon(Icons.open_in_new),
                onPressed: (context) async {
                  final Uri url =
                      Uri.parse('https://a-mabe.github.io/OpenHIIT/');
                  if (!await launchUrl(url)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versión'),
                trailing: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) => Text(
                    snapshot.hasData
                        ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                        : '—',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'Claro',
        ThemeMode.dark => 'Oscuro',
        ThemeMode.system => 'Sistema',
      };

  void _showThemePicker(BuildContext context) {
    final current = context.read<ThemeProvider>().themeMode;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tema'),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (ThemeMode? value) {
              if (value != null) {
                context.read<ThemeProvider>().setThemeMode(value);
                Navigator.of(context).pop();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: ThemeMode.values.map((mode) {
                return RadioListTile<ThemeMode>(
                  title: Text(_themeModeLabel(mode)),
                  value: mode,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// On/off switch for spoken set/round announcements during a workout.
class _VoiceAnnouncementsTile extends StatefulWidget {
  const _VoiceAnnouncementsTile();

  @override
  State<_VoiceAnnouncementsTile> createState() =>
      _VoiceAnnouncementsTileState();
}

class _VoiceAnnouncementsTileState extends State<_VoiceAnnouncementsTile> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _enabled = prefs.getBool(voiceAnnouncementsPrefKey) ?? true;
      });
    });
  }

  Future<void> _set(bool value) async {
    setState(() => _enabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(voiceAnnouncementsPrefKey, value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      key: const Key('voiceAnnouncementsSwitch'),
      secondary: const Icon(Icons.record_voice_over_outlined),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      title: const Text('Anuncios por voz'),
      subtitle: const Text('Dice en voz alta la serie y la tanda actuales'),
      value: _enabled,
      onChanged: _set,
    );
  }
}
