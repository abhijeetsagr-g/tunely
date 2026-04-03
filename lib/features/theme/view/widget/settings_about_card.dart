import 'package:flutter/material.dart';
import 'package:tunely/core/const/app_const.dart';
import 'package:tunely/features/theme/view/widget/settings_tile.dart';

class SettingsAboutCard extends StatelessWidget {
  final Color accent;

  const SettingsAboutCard({super.key, required this.accent});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        SettingsTile(
          leading: Image.asset(AppConst.primaryIcon),
          title: 'Tunely',
          subtitle: 'Version 0.1',
        ),
        SettingsTile(
          leading: Icon(Icons.code),
          title: "Abhijeet",
          subtitle: "Dev",
        ),
        SettingsTile(
          leading: Icon(Icons.library_music_outlined, color: accent, size: 22),
          title: 'Licenses',
          subtitle: 'Open source licenses',
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: onSurface.withAlpha(35),
          ),
          onTap: () =>
              showLicensePage(context: context, applicationName: 'Tunely'),
        ),
      ],
    );
  }
}
