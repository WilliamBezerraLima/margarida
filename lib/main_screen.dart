import 'package:margarida/components/appbar_main.dart';
import 'package:margarida/model/model.dart';
import 'package:margarida/pages/page_%20listen.dart';
import 'package:margarida/pages/page_import.dart';
import 'package:margarida/riverpod/import_controller.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:margarida/riverpod/playlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    var ratio = MediaQuery.of(context).size.aspectRatio;

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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child:
                          Text("Quantidade de playlists: ${playlists.length}"),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        height: 350 * ratio,
                        width: MediaQuery.of(context).size.width,
                        child: playlists.isEmpty
                            ? const Center(
                                child: Text("Nenhuma lista cadastrada!"),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: playlists.length,
                                itemBuilder: (BuildContext context, int index) {
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
                                            color: const Color(0xffeeeeee),
                                            width: 1.0),
                                        color: Colors.black54,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8.0)),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.white30,
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
                                        children: [
                                          Center(
                                            child: Image.network(
                                                playlist.thumbnail!,
                                                fit: BoxFit.fitWidth,
                                                width: 270 * ratio,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                              return Image.asset(
                                                "assets/images/noimage.png",
                                                fit: BoxFit.fitWidth,
                                                width: 150 * ratio,
                                              );
                                            }),
                                          ),
                                          if (playlist.title != null)
                                            SizedBox(
                                              height: 8 * ratio,
                                            ),
                                          if (playlist.title != null)
                                            Text(
                                              playlist.title!,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 25 * ratio,
                                                  color: Colors.white70),
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
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
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
    );
  }
}
