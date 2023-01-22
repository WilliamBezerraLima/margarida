import 'package:margarida/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playlistRepositoryProvider = Provider((_) => PlaylistRepository());

class PlaylistRepository {
  final List<Tbplaylist> _playlists = [];

  Future addPlaylist(Tbplaylist playlist, List<Tbvideo> videos) async {
    var id = await playlist.save();
    videos.forEach((video) {
      video.playlistId = id;
    });
    await Tbvideo.saveAll(videos);
    _playlists.add(playlist);
  }

  Future removePlaylist(Tbplaylist repository) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _playlists.remove(repository);
  }

  Future<List<Tbplaylist>> allPlaylists() async {
    if (_playlists.isEmpty) {
      _playlists.addAll(await Tbplaylist().select().toList());
    }
    return _playlists;
  }
}

final playlistsProvider = FutureProvider((ref) {
  final playlistRepository = ref.watch(playlistRepositoryProvider);
  return playlistRepository.allPlaylists();
});

final importControllerProvider = Provider((ref) {
  final playlistRepository = ref.watch(playlistRepositoryProvider);
  return ImportController(ref: ref, playlistRepository: playlistRepository);
});

class ImportController {
  final ProviderRef ref;
  final PlaylistRepository playlistRepository;

  ImportController({required this.ref, required this.playlistRepository});

  addPlaylist(Tbplaylist playlist, List<Tbvideo> videos) async {
    await playlistRepository.addPlaylist(playlist, videos);
    ref.refresh(playlistsProvider);
  }

  removePlaylist(Tbplaylist playlist) {
    playlistRepository.removePlaylist(playlist);
    ref.refresh(playlistsProvider);
  }
}
