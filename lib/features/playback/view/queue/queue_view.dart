import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/extensions/title_case.dart';
import 'package:tunely/features/playback/bloc/playback_bloc.dart';
import 'package:tunely/features/playback/view/queue/widget/queue_widget.dart';
import 'package:tunely/features/playback/view/widget/control_button.dart';
import 'package:tunely/features/playback/view/widget/player_gradient_background.dart';

class QueueView extends StatelessWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PlayerGradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 30,
                children: [
                  _QueueAppBar(),
                  Expanded(child: QueueWidget()),
                  ControlButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueAppBar extends StatelessWidget {
  const _QueueAppBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        BlocBuilder<PlaybackBloc, PlaybackState>(
          builder: (context, state) {
            if (state.currentItem == null) return const SizedBox();
            return Expanded(
              child: Center(
                child: Text(
                  state.currentItem?.title.toTitleCase() ?? "Unknown Title",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}
