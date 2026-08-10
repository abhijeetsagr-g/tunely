import 'package:flutter/material.dart';
import 'package:tunely/features/settings/widgets/about_widget.dart';
import 'package:tunely/features/settings/widgets/artist_delimiter_widget.dart';
import 'package:tunely/features/settings/widgets/cache_rescan_buttons.dart';
import 'package:tunely/features/settings/widgets/daily_mix_size_slider.dart';
import 'package:tunely/features/settings/widgets/min_song_dur_slider.dart';
import 'package:tunely/features/settings/widgets/theme_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),

        children: [
          ThemePicker(),

          SizedBox(height: 20),

          Divider(height: 1),

          SizedBox(height: 20),
          ArtistDelimiterWidget(),

          DailyMixSizeSlider(),

          MinSongDurSlider(),

          CacheRescanButtons(),

          SizedBox(height: 20),

          Divider(height: 1),

          SizedBox(height: 20),
          AboutWidget(),

          SizedBox(height: 20),

          Divider(height: 1),
          SizedBox(height: 20),

          Center(child: Text("Submit Your Feedback or Feature Request!")),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
