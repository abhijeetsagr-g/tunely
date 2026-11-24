import 'package:flutter/material.dart';
import 'package:tunely/features/settings/widgets/about_widget.dart';
import 'package:tunely/features/settings/widgets/accent_color_picker.dart';
import 'package:tunely/features/settings/widgets/artist_delimiter_widget.dart';
import 'package:tunely/features/settings/widgets/cache_rescan_buttons.dart';
import 'package:tunely/features/settings/widgets/daily_mix_size_slider.dart';
import 'package:tunely/features/settings/widgets/font_selector.dart';
import 'package:tunely/features/settings/widgets/font_size_selector.dart';
import 'package:tunely/features/settings/widgets/min_song_dur_slider.dart';
import 'package:tunely/features/settings/widgets/settings_section.dart';
import 'package:tunely/features/settings/widgets/theme_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),

        children: const [
          SettingsSection(
            title: 'Appearance',
            children: [ThemePicker(), AccentColorPicker()],
          ),
          SettingsSection(
            title: 'Text',
            children: [FontFamilySelector(), FontSizeSelector()],
          ),
          Divider(height: 1),
          SettingsSection(
            title: 'Library',
            children: [
              ArtistDelimiterWidget(),
              MinSongDurSlider(),
              DailyMixSizeSlider(),
              CacheRescanButtons(),
            ],
          ),
          Divider(height: 1),
          SizedBox(height: 28),
          AboutWidget(),
          SizedBox(height: 28),
          Center(child: Text('Submit Your Feedback or Feature Request!')),
        ],
      ),
    );
  }
}
