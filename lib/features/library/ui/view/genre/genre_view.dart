import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tunely/features/library/cubit/library_cubit.dart';
import 'package:tunely/shared/widget/content_view.dart';

class GenreView extends StatelessWidget {
  const GenreView({super.key, required this.genre});
  final GenreModel genre;

  @override
  Widget build(BuildContext context) {
    final tunes = context.read<LibraryCubit>().getTunesByGenre(genre.genre);
    return Scaffold(
      body: ContentView(
        title: genre.genre,
        tunes: tunes,
        artWidget: Icon(Icons.tune),
      ),
    );
  }
}
