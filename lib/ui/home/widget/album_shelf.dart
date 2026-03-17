import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/core/common/album_card.dart';
import 'package:tunely/logic/provider/query/query_cubit.dart';
import 'package:tunely/logic/provider/query/query_state.dart';

class AlbumShelf extends StatelessWidget {
  const AlbumShelf({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueryCubit, QueryState>(
      builder: (context, state) {
        final albums = context.read<QueryCubit>().albums;
        if (albums.isEmpty) return const SizedBox();
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AlbumCard(album: albums[index]),
            );
          },
        );
      },
    );
  }
}
