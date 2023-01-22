import 'dart:io';

import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:margarida/model/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class ConfigurationController extends ChangeNotifier {
  bool? _autoplay;
  bool? _darkmode;
  String? _downloadpath;

  bool? get autoplay => _autoplay;
  bool? get darkmode => _darkmode;
  String? get downloadpath => _downloadpath;

  void loadConfigurationFromDatabase() {
    Tbconfiguration().select().toSingle().then((config) => {
          if (config?.downloadpath == null)
            {
              getDownloadPath().then(
                (path) {
                  Tbconfiguration(
                    autoplay: false,
                    darkmode: true,
                    downloadpath: path,
                  ).save().then((_) => {setConfiguration(false, true, path)});
                },
              )
            }
          else
            {
              setConfiguration(
                  config?.autoplay, config?.darkmode, config?.downloadpath)
            }
        });
  }

  setConfiguration(bool? autoplay, bool? darkmode, String? downloadPath) {
    _autoplay = autoplay;
    _darkmode = darkmode;
    _downloadpath = downloadPath;
  }

  Future<String> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print("Cannot get download folder path");
      }
    }
    return directory!.path;
  }
}

final configurationControllerProvider =
    ChangeNotifierProvider<ConfigurationController>((ref) {
  return ConfigurationController();
});
