import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:lottie/lottie.dart';
import 'package:margarida/auth/secrets.dart';
import 'package:margarida/common/utils.dart';
import 'package:margarida/components/appbar_main.dart';
import 'package:margarida/components/loading.dart';
import 'package:margarida/components/nointernet.dart';
import 'package:margarida/model/model.dart';
import 'package:margarida/riverpod/import_controller.dart';
import 'package:margarida/riverpod/playlist_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../auth/secrets.dart' as secrets;

enum InternetStatus { none, wifi, mobile }

enum LinkType { none, single, playlistweb, playlistapp }

LinkType getLinkType(String link) {
  if (link.contains("&list=")) {
    return LinkType.playlistweb;
  }
  if (link.contains("playlist?list=")) {
    return LinkType.playlistweb;
  }

  if (link.startsWith("https://www.youtube.com/") ||
      link.startsWith("https://www.youtube.com/embed/") ||
      link.startsWith("https://youtu.be/") ||
      link.startsWith("https://youtube.com/")) {
    return LinkType.single;
  }

  return LinkType.none;
}

bool isPlayList(String link) {
  return [LinkType.playlistapp, LinkType.playlistweb]
      .contains(getLinkType(link));
}

class PageImport extends ConsumerStatefulWidget {
  const PageImport({Key? key}) : super(key: key);

  @override
  PageImportState createState() => PageImportState();
}

class PageImportState extends ConsumerState<PageImport> {
  final linkYoutube = TextEditingController();
  Tbplaylist playlist = Tbplaylist();
  List<Tbvideo> videos = [];

  bool noInternet = false;
  bool loading = false;
  final Connectivity _connectivity = Connectivity();

  Future<void> listVideosFromYoutubeList() async {
    var on = await online();
    if (!on) return;

    setState(() {
      loading = true;
    });

    final musicProvider = ref.read(musicStatusControllerProvider);
    musicProvider.clearRegistered();
    var path = const Uuid().v4();
    var yt = YoutubeExplode();

    playlist = Tbplaylist();
    videos = [];

    if (isPlayList(linkYoutube.text)) {
      var parts = linkYoutube.text.split("=");
      var listId = parts.last;
      var playlistFromYoutube = await yt.playlists.get(listId);
      playlist.title = playlistFromYoutube.title;
      playlist.author = playlistFromYoutube.author;
      playlist.playlistId = listId;
      playlist.videoId = getLinkType(linkYoutube.text) == LinkType.playlistapp
          ? parts[1]
          : parts[1].replaceAll("&list", "");
      playlist.thumbnail = playlistFromYoutube.thumbnails.standardResUrl;
      playlist.thumbnailLow = playlistFromYoutube.thumbnails.lowResUrl;
      playlist.thumbnailHigh = playlistFromYoutube.thumbnails.highResUrl;

      bool setedThumbnail = false;

      await for (var video in yt.playlists.getVideos(playlistFromYoutube.id)) {
        if (!setedThumbnail) {
          playlist.thumbnail = getImage(video.id.value);
          setedThumbnail = true;
        }
        var videoBean = castVideo(video, path);
        videos.add(videoBean);

        musicProvider.register(videoBean);
      }
    } else if (LinkType.single == getLinkType(linkYoutube.text)) {
      var videoDetails = await yt.videos.get(linkYoutube.text);
      playlist.thumbnail = getImage(videoDetails.id.value);
      var videoBean = castVideo(videoDetails, path);
      videos.add(videoBean);

      musicProvider.register(videoBean);
    } else {
      playlist.title = linkYoutube.text;
      String key = secrets.youtubeApiKey;
      YoutubeAPI ytApi = YoutubeAPI(key);
      List<YouTubeVideo> videoResult =
          await ytApi.search(linkYoutube.text, type: "video");

      for (var video in videoResult) {
        playlist.thumbnail = video.thumbnail.medium.url;
        var videoBean = castVideo2(video, path);
        videos.add(videoBean);
        musicProvider.register(videoBean);
      }
    }

    setState(() {
      loading = false;
    });

    musicProvider.setPlaylistAndVideos(playlist, videos);
  }

  String getImage(String id) {
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  Tbvideo castVideo(Video audio, String path) {
    return Tbvideo(
      videoId: audio.id.value,
      title: audio.title,
      author: audio.author,
      thumbnail: getImage(audio.id.value),
      thumbnailLow: audio.thumbnails.lowResUrl,
      thumbnailHigh: audio.thumbnails.highResUrl,
      path: path,
      duration: Util.formatSecondsToString(audio.duration!.inSeconds),
    );
  }

  Tbvideo castVideo2(YouTubeVideo audio, String path) {
    return Tbvideo(
      videoId: audio.id,
      title: audio.title,
      author: audio.description,
      thumbnail: getImage(audio.id!),
      thumbnailLow: getImage(audio.id!),
      thumbnailHigh: getImage(audio.id!),
      path: path,
      duration: audio.duration,
    );
  }

  Future<InternetStatus> internet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return InternetStatus.mobile;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return InternetStatus.wifi;
    }
    return InternetStatus.none;
  }

  Future<bool> online() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {}
    return false;
  }

  bool validState() {
    return (videos.isNotEmpty && !noInternet);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult status) async {
    if (!mounted) {
      return Future.value(null);
    }

    setState(() {
      noInternet = status == ConnectivityResult.none;
    });

    if (status == ConnectivityResult.wifi) return;
    String message = status == ConnectivityResult.none
        ? "Sem conexão com a Internet"
        : "Prefira conectar via Wifi. Esse processo requer muito dados móveis.";

    _dialogBuilder(context, message);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  initState() {
    super.initState();
    //var link = "https://www.youtube.com/watch?v=HQmmM_qwG4k";
    // var link =
    //     "https://www.youtube.com/watch?v=yO2n7QoyieM&list=PLQjNsI6Dpg11c9dywap9noqJWp74dkxNc";
    // Clipboard.setData(ClipboardData(text: link));

    Clipboard.getData(Clipboard.kTextPlain).then((value) async {
      if (value != null && value.text != null) {
        if (kDebugMode) {
          print('Clipboard content ${value.text}');
        }
        if (value.text!.startsWith("https://www.youtube.com/watch?v=") ||
            value.text!.startsWith("https://youtu.be/") ||
            value.text!.startsWith("https://www.youtube.com/embed/") ||
            value.text!.startsWith("https://youtube.com/")) {
          linkYoutube.text = value.text!;
          await listVideosFromYoutubeList();
        }
      }
    });

    initConnectivity();
  }

  @override
  void dispose() {
    linkYoutube.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = ref.watch(musicStatusControllerProvider);
    double width = MediaQuery.of(context).size.width;

    musicProvider.addListener(() async {
      if (musicProvider.error != null) {
        if (kDebugMode) {
          print("ShowModal Error ==========> ${musicProvider.error}");
        }
        await _dialogBuilder(context, musicProvider.error!);
      }
    });

    return Scaffold(
      appBar: const AppBarMain(),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: linkYoutube,
              onSubmitted: ((_) async {
                await listVideosFromYoutubeList();
              }),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: 'Enter a Youtube link',
                suffixIcon: IconButton(
                  onPressed: () async {
                    await listVideosFromYoutubeList();
                  },
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            if (validState())
              Container(
                padding: const EdgeInsets.all(3),
                margin: const EdgeInsets.only(top: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orangeAccent),
                  gradient: LinearGradient(colors: [
                    Colors.orangeAccent.shade200,
                    Colors.orangeAccent.shade400,
                    Colors.orangeAccent.shade700
                  ]),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_rounded,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "CLIQUE NOS CARDS PARA SELECIONAR \nAS MÚSICAS QUE DESEJA IMPORTAR!",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
            if (validState())
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  "Quantidade de músicas encontradas: ${videos.length}",
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.white70),
                ),
              ),
            if (noInternet)
              NoInternet(
                onPressed: () async {
                  initConnectivity();
                  await listVideosFromYoutubeList();
                },
              )
            else if (loading)
              const Loading()
            else if (validState())
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  itemBuilder: (BuildContext context, int index) {
                    var video = videos[index];
                    //musicProvider.register(video.videoId!);

                    return TileDetail(video: video);
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (validState()) ButtonImport(width: width)
          ],
        ),
      ),
    );
  }
}

class TileDetail extends ConsumerWidget {
  const TileDetail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Tbvideo video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provider = ref.watch(musicStatusControllerProvider);

    return InkWell(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(
                      "Remover '${video.title}' da lista para importação?"),
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check))
                  ],
                ));
      },
      onTap: () {
        provider.select(video.videoId!);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shadowColor: Colors.black38,
        child: Container(
          decoration: !provider.isSelect(video.videoId!)
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green, width: 2),
                  // gradient: LinearGradient(colors: [
                  //   Colors.green.shade300,
                  //   Colors.green.shade500,
                  //   Colors.green.shade400
                  // ]),
                ),
          height: 80,
          padding: const EdgeInsets.all(6),
          child: Row(children: [
            Expanded(
              flex: 2,
              child: MSHCheckbox(
                size: 30,
                value: provider.isSelect(video.videoId!),
                style: MSHCheckboxStyle.fillFade,
                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                  checkedColor: Colors.green,
                  uncheckedColor: Colors.grey.shade600,
                ),
                duration: const Duration(milliseconds: 300),
                onChanged: (selected) {
                  provider.select(video.videoId!);
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(
                  video.thumbnail!,
                  height: 80.0,
                  width: 80.0,
                  fit: BoxFit.cover, //change image fill type
                ),
              ),
            ),
            const Spacer(flex: 1),
            Expanded(
              flex: 15,
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(video.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            video.author ?? "",
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 12.0,
                                color: Colors.white70),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          video.duration ?? "",
                          style: const TextStyle(
                              fontSize: 12.0, color: Colors.white70),
                        ),
                      ],
                    ),
                    if (provider.isStarted(video.videoId!))
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                                width: 100,
                                child: LinearProgressIndicator(
                                  color: Colors.green.shade500,
                                  value: provider
                                          .getMusic(video.videoId!)
                                          .percent /
                                      100,
                                )),
                            Text(
                              'Download ${provider.getMusic(video.videoId!).percent}%',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.green.shade500),
                            ),

                            // ElevatedButton(
                            //   onPressed: null,
                            //   child: Text("Cancelar"),
                            // ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ButtonImport extends ConsumerWidget {
  const ButtonImport({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var importProvider = ref.read(importControllerProvider);
    var downloadProvider = ref.read(musicStatusControllerProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            color: downloadProvider.importing
                ? Colors.black54
                : Colors.blueAccent.shade200,
            boxShadow: [
              BoxShadow(
                color: downloadProvider.importing
                    ? Colors.black26
                    : Colors.blueAccent.shade100,
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0),
              )
            ]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: downloadProvider.importing
                  ? Colors.black38
                  : Colors.blueAccent,
              minimumSize: Size(width, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              )),
          onPressed: downloadProvider.importing
              ? null
              : () async {
                  if (downloadProvider.hasSelecteds()) {
                    await downloadProvider.startAll().then((_) => {
                          importProvider.addPlaylist(
                            downloadProvider.playlist,
                            downloadProvider.getSelecteds()!,
                          ),
                          Navigator.of(context).pop()
                        });
                  } else {
                    _showMaterialDialog(context);
                  }
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (downloadProvider.importing)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white70,
                    strokeWidth: 2,
                  ),
                ),
              if (downloadProvider.importing)
                const SizedBox(
                  width: 10,
                ),
              Text(
                downloadProvider.downloadStatus == null
                    ? "IMPORTAR"
                    : downloadProvider.downloadStatus!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showMaterialDialog(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importação'),
          content: const Text(
              'Você não selecionou nenhuma música para importar.\n'
              'Se deseja importar todas as músicas, clique no botão "Todas".\n'
              'Ou clique em uma música para selecionar a mesma.'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.blueAccent),
                )),
            TextButton(
              onPressed: () {
                print('Importar todas!');
                Navigator.pop(context);
              },
              child: const Text(
                'IMPORTAR TODAS!',
                style: TextStyle(color: Colors.blueAccent),
              ),
            )
          ],
        );
      });
}

Future<void> _dialogBuilder(BuildContext context, String text) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: Text(text),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
