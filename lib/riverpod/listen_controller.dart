import 'dart:typed_data';

import 'package:audiofileplayer/audio_system.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:margarida/common/utils.dart';
import 'package:margarida/model/model.dart';
import 'package:margarida/riverpod/configuration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:margarida/riverpod/controls_controller.dart';

final Logger _logger = Logger('algures');

class ListenController extends ChangeNotifier {
  late ConfigurationController _config;
  late ControlsController _controls;
  ListenController(
      ConfigurationController config, ControlsController controls) {
    _config = config;
    _controls = controls;
  }

  static const String replayButtonId = 'replayButtonId';
  static const String newReleasesButtonId = 'newReleasesButtonId';
  bool _open = false;
  bool _initialized = false;
  double _turns = 0.0;
  List<Tbvideo> _audios = [];
  Tbplaylist _playlist = Tbplaylist();
  Tbvideo? _audio;
  double _position = 0;
  double _maxPosition = 0;
  String _positionDisplay = "0:00";
  Audio? audioRef;

  Tbplaylist get playlist => _playlist;
  List<Tbvideo> get audios => _audios;
  Tbvideo? get audio => _audio;
  double get position => _position;
  double get maxPosition => _maxPosition;
  String get positionDisplay => _positionDisplay;
  bool _playing = false;
  bool _paused = false;

  bool get paused => _paused;
  bool get playing => _playing;

  initState() {
    AudioSystem.instance.addMediaEventListener(_mediaEventListener);
  }

  void _mediaEventListener(MediaEvent mediaEvent) {
    _logger.info('App received media event of type: ${mediaEvent.type}');
    final MediaActionType type = mediaEvent.type;
    if (type == MediaActionType.play) {
      resume();
    } else if (type == MediaActionType.pause) {
      pause();
    } else if (type == MediaActionType.playPause) {
      _playing ? pause() : resume();
    } else if (type == MediaActionType.stop) {
      stop();
    } else if (type == MediaActionType.seekTo) {
      audioRef?.seek(mediaEvent.seekToPositionSeconds!);
      AudioSystem.instance
          .setPlaybackState(true, mediaEvent.seekToPositionSeconds!);
    } else if (type == MediaActionType.skipForward) {
      final double? skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _logger.info(
          'Skip-forward event had skipIntervalSeconds $skipIntervalSeconds.');
      _logger.info('Skip-forward is not implemented in this example app.');
    } else if (type == MediaActionType.skipBackward) {
      final double? skipIntervalSeconds = mediaEvent.skipIntervalSeconds;
      _logger.info(
          'Skip-backward event had skipIntervalSeconds $skipIntervalSeconds.');
      _logger.info('Skip-backward is not implemented in this example app.');
    } else if (type == MediaActionType.custom) {
      if (mediaEvent.customEventId == replayButtonId) {
        audioRef?.play();
        AudioSystem.instance.setPlaybackState(true, 0.0);
      } else if (mediaEvent.customEventId == newReleasesButtonId) {
        _logger
            .info('New-releases button is not implemented in this exampe app.');
      }
    }
  }

  void load() {
    if (!_initialized) {
      initState();
      _initialized = true;
    }
    var loadSuccessful = true;
    try {
      var file =
          '${_config.downloadpath}/${_audio!.path}/${_audio!.videoId}.mp4';

      if (_playing) audioRef?.pause();

      audioRef = Audio.loadFromAbsolutePath(
        file,
        onComplete: () => _handleOnComplete(),
        onDuration: (double durationSeconds) =>
            _handleDuration(durationSeconds),
        onPosition: (double positionSeconds) =>
            _handleOnPosition(positionSeconds),
        playInBackground: true,
        onError: (message) {
          loadSuccessful = false;
          toast("Erro ao carregar a música: ${_audio?.title}");
          next();
        },
      );

      if (loadSuccessful) {
        resume();
      }

      notifyListeners();
    } catch (e) {
      toast(e.toString());
    }
  }

  toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void setPosition(double position) {
    pause();
    _handleOnPosition(position);
    audioRef?.resume(endpointSeconds: 30);
    //audioRef?.resume(endpointSeconds: position);
  }

  Future<void> play() async {
    if (audioRef == null) {
      load();
      return;
    }

    _playing = true;
    if (_paused) {
      resume();
    } else {
      await audioRef?.play();
    }
    _paused = false;

    notifyListeners();
  }

  void stop() {
    _playing = false;
    _paused = true;
    audioRef?.pause();
    AudioSystem.instance.stopBackgroundDisplay();
  }

  Future<void> pause() async {
    _playing = false;
    _paused = true;
    audioRef?.pause();
    _controls.stop();

    AudioSystem.instance.setPlaybackState(false, _position);

    AudioSystem.instance.setAndroidNotificationButtons([
      AndroidMediaButtonType.play,
      AndroidMediaButtonType.stop,
      const AndroidCustomMediaButton(
          'new releases', newReleasesButtonId, 'ic_new_releases_black_36dp'),
    ], androidCompactIndices: [
      0
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.play,
      MediaActionType.next,
      MediaActionType.previous,
    });

    notifyListeners();
  }

  Future<void> resume() async {
    _controls.play();
    audioRef?.resume();
    _playing = true;
    _paused = false;

    final Uint8List imageBytes = await getImageBytes(_audio!.thumbnail!);
    AudioSystem.instance.setMetadata(AudioMetadata(
        title: _audio!.title,
        artist: _audio!.author,
        durationSeconds: _maxPosition,
        artBytes: imageBytes));

    AudioSystem.instance.setPlaybackState(true, _position);

    AudioSystem.instance.setAndroidNotificationButtons(<dynamic>[
      AndroidMediaButtonType.pause,
      AndroidMediaButtonType.stop,
      const AndroidCustomMediaButton(
          'replay', replayButtonId, 'ic_replay_black_36dp')
    ], androidCompactIndices: <int>[
      0
    ]);

    AudioSystem.instance.setSupportedMediaActions(<MediaActionType>{
      MediaActionType.playPause,
      MediaActionType.pause,
      MediaActionType.next,
      MediaActionType.previous,
      MediaActionType.skipForward,
      MediaActionType.skipBackward,
      MediaActionType.seekTo,
    }, skipIntervalSeconds: 30);

    notifyListeners();
  }

  void previous() {
    var index = _audios.indexWhere((audio) => audio.id == _audio!.id);
    if (index > 0) {
      audioRef!
        ..pause()
        ..dispose();
      _audio = _audios[index - 1];
      load();
      if (_config.autoplay!) {
        play();
      }
      notifyListeners();
    }
  }

  void next() {
    try {
      var index = _audios.indexWhere((audio) => audio.id == _audio!.id);
      if (index < _audios.length) {
        audioRef!
          ..pause()
          ..dispose();
        _audio = _audios[index + 1];
        load();
        if (_config.autoplay!) {
          play();
        }
        notifyListeners();
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _handleOnComplete() {
    next();
  }

  void _handleDuration(double durationSeconds) {
    //print("---------------------------------  seconds: $durationSeconds");
    _maxPosition = durationSeconds;
    notifyListeners();
  }

  void _handleOnPosition(double positionSeconds) {
    //print("--------  positionSeconds: $positionSeconds | $_maxPosition");
    _position = double.parse(positionSeconds.toString());
    _positionDisplay = Util.formatSecondsToString(_position.toInt());
    notifyListeners();
  }

  bool get isOpen => _open;

  void toggle() {
    _open = !_open;
    _turns = _turns == 0.0 ? 0.5 : 0.0;
    notifyListeners();
  }

  double get turns => _turns;

  Future<void> setPlaylist(Tbplaylist playlist) async {
    _playlist = playlist;
    _audios = await Tbvideo().select().playlistId.equals(playlist.id).toList();
    _audio = _audios.first;
    load();
    notifyListeners();
  }

  void setVideo(Tbvideo video) {
    _audio = video;
    notifyListeners();
  }

  Future<Uint8List> getImageBytes(String imageUrl) async {
    Uint8List bytes =
        (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl))
            .buffer
            .asUint8List();
    return bytes;
  }
}

final listenControllerProvider =
    ChangeNotifierProvider<ListenController>((ref) {
  var config = ref.read(configurationControllerProvider);
  var controls = ref.read(controlsControllerProvider);
  return ListenController(config, controls);
});
