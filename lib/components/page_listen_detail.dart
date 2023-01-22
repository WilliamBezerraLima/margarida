import 'dart:ui';

import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageListenDetail extends ConsumerWidget {
  const PageListenDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: listProvider.isOpen ? 20.0 : 10),
          if (listProvider.audio != null)
            Material(
              elevation: 4.0,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.fastOutSlowIn,
                height: listProvider.isOpen ? 250 : 50,
                width: listProvider.isOpen ? 250 : 50,
                child: Image.network(
                  listProvider.audio!.thumbnail!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          SizedBox(height: (listProvider.isOpen ? 30 : 15) * ratio),
          if (listProvider.audio != null)
            Text(listProvider.audio!.title!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 32 * ratio)),
          //SizedBox(height: 6.0 * ratio),
          if (listProvider.audio != null)
            Text(
              listProvider.audio!.author!,
              style: TextStyle(color: Colors.white60, fontSize: 22 * ratio),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
