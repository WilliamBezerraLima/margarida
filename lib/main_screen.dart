import 'package:margarida/components/appbar_main.dart';
import 'package:margarida/components/page_listen_control.dart';
import 'package:margarida/model/model.dart';
import 'package:margarida/pages/page_%20listen.dart';
import 'package:margarida/pages/page_import.dart';
import 'package:margarida/riverpod/import_controller.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:margarida/riverpod/playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margarida/riverpod/theme_controller.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  Image getImage(String id) {
    return Image.network(
      'https://img.youtube.com/vi/$id/hqdefault.jpg',
      fit: BoxFit.fitWidth,
      width: 220,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listenProvider = ref.watch(listenControllerProvider);
    final theme = ref.watch(themeControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;
    var height = MediaQuery.of(context).size.height;

    if (1 == 2) {
      Tbplaylist().select().delete(true);
      Tbvideo().select().delete(true);
    }

    return Scaffold(
      appBar: const AppBarMain(),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent.shade100),
              child: const Text('Margarida'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.train),
              title: const Text('Page 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor: theme.backgroundColor1,
      body: ref.watch(playlistsProvider).maybeWhen(
          orElse: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (playlists) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (playlists.isNotEmpty && playlists.length > 2)
                    Flexible(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Quantidade de playlists: ${playlists.length}",
                          style: TextStyle(color: theme.tileTitle2),
                        ),
                      ),
                    ),
                  Expanded(
                    flex: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          height: height,
                          width: MediaQuery.of(context).size.width,
                          child: playlists.isEmpty
                              ? Center(
                                  child: Text("Nenhuma lista cadastrada!",
                                      style:
                                          TextStyle(color: theme.tileTitle2)),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                    mainAxisSpacing: 10.0,
                                    crossAxisSpacing: 10.0,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: playlists.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var playlist = playlists[index];

                                    return InkWell(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8 * ratio)),
                                      onTap: () {
                                        listenProvider.setPlaylist(playlist);
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const PageListen()));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: listenProvider
                                                          .playlist.id ==
                                                      playlist.id
                                                  ? Colors.blueAccent.shade200
                                                  : Colors.white38,
                                              width:
                                                  listenProvider.playlist.id ==
                                                          playlist.id
                                                      ? 5
                                                      : 1),
                                          color: theme.cardBackground1,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.shadow1,
                                              blurRadius: 2,
                                              spreadRadius: 1,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        margin: const EdgeInsets.all(4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        height: 200 * ratio,
                                        width: 350 * ratio,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(
                                                    top: 5),
                                                child: listenProvider
                                                            .playlist.id ==
                                                        playlist.id
                                                    ? RippleAnimation(
                                                        repeat: true,
                                                        color:
                                                            Colors.blueAccent,
                                                        minRadius: 40,
                                                        ripplesCount: 6,
                                                        child: CircleAvatar(
                                                          radius: 48,
                                                          backgroundImage:
                                                              NetworkImage(playlist
                                                                  .thumbnail!),
                                                        ),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 48,
                                                        backgroundImage:
                                                            NetworkImage(playlist
                                                                .thumbnail!),
                                                      ),
                                              ),
                                            ),
                                            if (playlist.title != null)
                                              SizedBox(
                                                height: 8 * ratio,
                                              ),
                                            if (playlist.title != null)
                                              Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(
                                                    bottom: 5),
                                                child: Text(
                                                  playlist.title!,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25 * ratio,
                                                      color: listenProvider
                                                                  .playlist
                                                                  .id ==
                                                              playlist.id
                                                          ? Colors.blue.shade300
                                                          : theme.tileTitle2),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: PageListenControl(),
                    ),
                  ),
                ],
              ),
            );
          }),
      floatingActionButton: Padding(
        padding: listenProvider.playing
            ? const EdgeInsets.only(bottom: 80.0)
            : const EdgeInsets.all(0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PageImport()));
          },
          backgroundColor: Colors.blueAccent.shade200,
          child: Icon(
            Icons.install_mobile_outlined,
            color: Colors.white70,
            size: 60 * ratio,
          ),
        ),
      ),
    );
  }
}
