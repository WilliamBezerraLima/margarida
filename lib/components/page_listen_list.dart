import 'dart:ui';

import 'package:margarida/model/model.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageListenList extends ConsumerWidget {
  const PageListenList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listenProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      curve: Curves.bounceOut,
      opacity: listenProvider.isOpen ? 0 : 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "A playlist contém ${listenProvider.audios.length} músicas",
              style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  fontSize: 30 * ratio),
            ),
            SizedBox(height: 8 * ratio),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: listenProvider.audios.length,
                itemBuilder: (ctx, index) {
                  var video = listenProvider.audios[index];

                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white12),
                      ),
                    ),
                    child: ListTile(
                      tileColor: listenProvider.playing &&
                              video.videoId == listenProvider.audio!.videoId
                          ? Colors.white10
                          : null,
                      onTap: () {
                        listenProvider.setVideo(video);
                        listenProvider.load();
                      },
                      contentPadding:
                          EdgeInsets.only(left: 20 * ratio, right: 20 * ratio),
                      leading: Thumbnail(video: video),
                      title:
                          Title(video: video, listenProvider: listenProvider),
                      subtitle: Subtitle(video: video),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Subtitle extends StatelessWidget {
  const Subtitle({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Tbvideo video;

  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Text(
              video.author!,
              style: TextStyle(fontSize: 22 * ratio),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (video.duration != null) const Spacer(),
        if (video.duration != null)
          Text(video.duration!, style: TextStyle(fontSize: 22 * ratio)),
      ],
    );
  }
}

class Title extends StatelessWidget {
  const Title({
    Key? key,
    required this.video,
    required this.listenProvider,
  }) : super(key: key);

  final Tbvideo video;
  final ListenController listenProvider;

  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Row(
      children: [
        Expanded(
          flex: 9,
          child: SizedBox(
            width: double.infinity,
            child: Text(
              video.title!,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 28 * ratio),
            ),
          ),
        ),
        if (listenProvider.playing &&
            video.videoId == listenProvider.audio!.videoId)
          Expanded(
            flex: 1,
            child: Image.asset(
              "assets/images/equalizer.gif",
              width: 8 * ratio,
              fit: BoxFit.fitWidth,
            ),
          ),
      ],
    );
  }
}

class Thumbnail extends StatelessWidget {
  const Thumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final Tbvideo video;

  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.white38.withAlpha(60),
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
      constraints:
          BoxConstraints.tightFor(height: 90 * ratio, width: 120 * ratio),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(video.thumbnailLow!, fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
          return Image.asset(
            "assets/images/noimage.png",
            fit: BoxFit.fitWidth,
            height: 30,
            width: 30 * ratio,
          );
        }),
      ),
    );
  }
}
