import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunely/logic/service/deezer_service.dart';

sealed class ArtistImageState {}

class ArtistImageInitial extends ArtistImageState {}

class ArtistImageLoading extends ArtistImageState {}

class ArtistImageLoaded extends ArtistImageState {
  final String url;
  ArtistImageLoaded(this.url);
}

class ArtistImageFailed extends ArtistImageState {}

class ArtistImageCubit extends Cubit<ArtistImageState> {
  final _service = DeezerService();

  ArtistImageCubit() : super(ArtistImageInitial());

  Future<void> load(String artistName) async {
    emit(ArtistImageLoading());
    final url = await _service.getArtistImageUrl(artistName);
    if (isClosed) return;
    if (url != null) {
      emit(ArtistImageLoaded(url));
    } else {
      emit(ArtistImageFailed());
    }
  }
}
