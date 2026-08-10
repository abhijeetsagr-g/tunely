import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/const/app_route.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/core/utils/extracted_gradient_container.dart';
import 'package:tunely/core/utils/fur_artist_name.dart';
import 'package:tunely/features/settings/cubit/management_cubit.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/shell/widget/continue_listening_placeholder.dart';
import 'package:tunely/shared/model/tune.dart';
import 'package:tunely/shared/widget/album_art.dart';

class ContinueListeningCard extends StatelessWidget {
  const ContinueListeningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaybackBloc, PlaybackState>(
      buildWhen: (p, c) =>
          p.currentItem != c.currentItem ||
          p.position != c.position ||
          p.duration != c.duration,
      builder: (context, ps) {
        final tune = ps.currentItem;
        if (tune == null) return const ContinueListeningPlaceholder();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: ExtractedGradientContainer(
            songId: tune.songId,
            borderRadius: 20,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 14),
              child: _TopRow(tune: tune, ps: ps),
            ),
          ),
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.tune, required this.ps});
  final Tune tune;
  final PlaybackState ps;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AlbumArt(artUri: tune.artUri, size: const Size(64, 64)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ps.isPlaying ? 'Now Playing' : 'Continue Listening',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer.withAlpha(150),
                  fontSize: 10,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tune.title.toTitleCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                formatArtistName(
                  context.read<ManagementCubit>().state.artistDelimiters,
                  tune.artist,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onPrimaryContainer.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _PlayButton(isPlaying: ps.isPlaying),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying});
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => isPlaying
          ? Navigator.pushNamed(context, AppRoute.player)
          : context.read<PlaybackBloc>().add(PlayEvent()),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        child: Icon(
          isPlaying ? Icons.open_in_full_rounded : Icons.play_arrow_rounded,
          color: cs.onPrimary,
        ),
      ),
    );
  }
}
