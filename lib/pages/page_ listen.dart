import 'package:margarida/components/appbar_main.dart';
import 'package:margarida/components/button_more.dart';
import 'package:margarida/components/page_listen_control.dart';
import 'package:margarida/components/page_listen_detail.dart';
import 'package:margarida/components/page_listen_list.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageListen extends ConsumerWidget {
  const PageListen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listenProvider = ref.watch(listenControllerProvider);
    //var musicStatusProvider = ref.watch(musicStatusControllerProvider);

    double padding = MediaQuery.of(context).viewPadding.top;
    double height =
        MediaQuery.of(context).size.height - kToolbarHeight - padding;

    return Scaffold(
      appBar: const AppBarMain(),
      body: Stack(
        children: [
          AnimatedPositioned(
            height: listenProvider.isOpen ? 0 : height * 0.6,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 500),
            child: const PageListenList(),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              height: listenProvider.isOpen ? height : height * 0.4,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: listenProvider.isOpen ? 0.0 : 1.0,
                    color: listenProvider.isOpen
                        ? Colors.transparent
                        : Colors.white30,
                  ),
                ),
              ),
              child: Container(
                color: const Color(0xff3A3A3B),
                width: double.infinity,
                height: double.infinity,
                margin: const EdgeInsets.all(0),
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ButtonMore(),
                    PageListenDetail(),
                    PageListenControl()
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
