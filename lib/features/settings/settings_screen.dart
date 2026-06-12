import 'package:flutter/material.dart';
import 'package:tunely/features/settings/widgets/about_widget.dart';
import 'package:tunely/features/settings/widgets/artist_delimiter_widget.dart';
import 'package:tunely/features/settings/widgets/cache_rescan_buttons.dart';
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
      body: CustomScrollView(
        slivers: [
          const ThemePickerWidget(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          const SliverToBoxAdapter(child: Divider(height: 1)),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const ArtistDelimiterWidget(),

          const MinSongDurSlider(),

          const CacheRescanButtons(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          const SliverToBoxAdapter(child: Divider(height: 1)),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          const AboutWidget(),
        ],
      ),
    );
  }
}
