import 'dart:async';
import 'package:margarida/model/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ControlsController extends ChangeNotifier {
  bool _playing = false;

  bool get playing => _playing;

  Future<List<Tbplaylist>> get playlists async =>
      await Tbplaylist().select().toList();

  void play() {
    _playing = true;
    notifyListeners();
  }

  void stop() {
    _playing = false;
    notifyListeners();
  }
}

final controlsControllerProvider =
    ChangeNotifierProvider<ControlsController>((ref) {
  return ControlsController();
});
