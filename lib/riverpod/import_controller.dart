import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:margarida/model/model.dart';
import 'package:margarida/riverpod/configuration_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicStatus {
  late String musicId;
  late String path;
  late int percent;
  late double position;
  late bool started;
  late bool selected;

  MusicStatus(
      {required this.musicId,
      required this.path,
      required this.position,
      required this.percent,
      required this.started,
      required this.selected});
}

class DownloadController extends ChangeNotifier {
  late ConfigurationController _config;
  DownloadController(ConfigurationController config) {
    _config = config;
  }

  final List<MusicStatus> _musicsStatus = [];
  Tbplaylist _playlist = Tbplaylist();
  List<Tbvideo> _videos = [];
  String? _error;
  int _countDownloaded = 0;
  bool _importing = false;

  String? get downloadStatus => _countDownloaded > 0
      ? "Importados $_countDownloaded de ${selectedCount()} arquivos"
      : null;
  Tbplaylist get playlist => _playlist;
  List<Tbvideo> get videos => _videos;
  bool get importing => _importing;

  Future<List<Tbplaylist>> get playlists async =>
      await Tbplaylist().select().toList();

  void setPlaylistAndVideos(Tbplaylist playlist, List<Tbvideo> videos) {
    _playlist = playlist;
    _videos = videos;
    notifyListeners();
  }

  List<MusicStatus> get musicsStatus => _musicsStatus;

  String? get error => _error;

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearRegistered() {
    _countDownloaded = 0;
    _musicsStatus.clear();
    notifyListeners();
  }

  void register(Tbvideo video) {
    if (_musicsStatus
        .where((element) => element.musicId == video.videoId)
        .isNotEmpty) {
      print("Already registed => ${_musicsStatus.length} | ${video.videoId}");
    } else {
      print("register => ${_musicsStatus.length} | ${video.videoId}");

      _musicsStatus.add(MusicStatus(
          musicId: video.videoId!,
          path: video.path!,
          position: 0,
          percent: 0,
          started: false,
          selected: false));
    }
  }

  void select(String musicId) {
    for (var music in _musicsStatus) {
      if (music.musicId == musicId) {
        music.selected = !music.selected;
      }
    }
    notifyListeners();
  }

  bool isSelect(String musicId) => _musicsStatus
      .where((music) => music.musicId == musicId && music.selected)
      .isNotEmpty;

  int selectedCount() => _musicsStatus.where((music) => music.selected).length;

  bool hasSelecteds() =>
      _musicsStatus.where((music) => music.selected).isNotEmpty;

  void start(String musicId) {
    for (var music in _musicsStatus) {
      if (music.musicId == musicId) {
        music.started = true;
      }
    }
    notifyListeners();
  }

  Future<void> startAll() async {
    _countDownloaded = 0;
    _importing = true;
    await Future.forEach(_musicsStatus.where((mus) => mus.selected),
        (music) async {
      try {
        await downloadMusic(music.musicId, music.path);
        _countDownloaded = _countDownloaded + 1;
      } catch (e) {
        setError(
            "Erro ao tentar fazer download das músicas. Favor tentar novamente!");
      }
    });
    _importing = false;
  }

  MusicStatus getMusic(String musicId) =>
      _musicsStatus.where((music) => music.musicId == musicId).first;

  bool isStarted(String musicId) => _musicsStatus
      .where((music) => music.musicId == musicId && music.started)
      .isNotEmpty;

  downloadMusic(String musicId, String path) async {
    var yt = YoutubeExplode();

    // Get video metadata.
    var video = await yt.videos.get(musicId);
    var getPath = _config.downloadpath;
    final Directory appDocDirFolder =
        await Directory('$getPath/$path').create(recursive: true);
    var downloadPath = appDocDirFolder.path;

    var manifest = await yt.videos.streamsClient.getManifest(musicId);
    var streams = manifest.audioOnly;

    // Get the audio track with the highest bitrate.
    var audio = streams.first;
    var audioStream = yt.videos.streamsClient.get(audio);

    // Compose the file name removing the unallowed characters in windows.
    var fileName = '$musicId.${audio.container.name}';
    var file = File('$downloadPath/$fileName');

// Delete the file if exists.
    if (file.existsSync()) {
      file.deleteSync();
    }

    // Open the file in writeAppend.
    var output = file.openWrite(mode: FileMode.writeOnlyAppend);
    //.openWrite(mode: FileMode.write);

    // Track the file download status.
    var len = audio.size.totalBytes;
    var count = 0;

    // Create the message and set the cursor position.
    var msg = 'Downloading ${video.title}.${audio.container.name}';
    stdout.writeln(msg);

    // Listen for data received.
    // var progressBar = ProgressBar();

    await for (final data in audioStream) {
      // Keep track of the current downloaded data.
      count += data.length;

      // Calculate the current progress.
      var progress = ((count / len) * 100).ceil();

      // Update the progressbar.
      //progressBar.update(progress);
      //print("progress: $progress");
      updateProgress(musicId, progress);

      // Write to file.
      output.add(data);
    }
    await output.close();
  }

  void updateProgress(String musicId, int progress) {
    var music = getMusic(musicId);
    music.started = true;
    music.percent = progress;
    notifyListeners();
  }
}

final musicStatusControllerProvider =
    ChangeNotifierProvider<DownloadController>((ref) {
  var config = ref.read(configurationControllerProvider);
  return DownloadController(config);
});
