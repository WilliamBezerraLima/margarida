import 'dart:ui';

import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margarida/riverpod/theme_controller.dart';

class PageListenDetail extends ConsumerWidget {
  const PageListenDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var theme = ref.watch(themeControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (listProvider.audio != null)
          Expanded(
            flex: listProvider.isOpen ? 25 : 3,
            child: Material(
              elevation: 4.0,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              color: theme.backgroundColor1,
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
          ),
        if (listProvider.audio != null)
          Expanded(
            flex: listProvider.isOpen ? 2 : 1,
            child: Text(listProvider.audio!.title!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32 * ratio,
                    color: theme.title1)),
          ),
        //SizedBox(height: 6.0 * ratio),
        if (listProvider.audio != null)
          Expanded(
            flex: 1,
            child: Text(
              listProvider.audio!.author!,
              style: TextStyle(color: theme.tileTitle2, fontSize: 22 * ratio),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
