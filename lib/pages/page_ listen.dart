import 'package:margarida/components/appbar_main.dart';
import 'package:margarida/components/button_more.dart';
import 'package:margarida/components/page_listen_control.dart';
import 'package:margarida/components/page_listen_detail.dart';
import 'package:margarida/components/page_listen_list.dart';
import 'package:margarida/main.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margarida/riverpod/theme_controller.dart';

class PageListen extends ConsumerWidget {
  const PageListen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listenProvider = ref.watch(listenControllerProvider);
    var theme = ref.watch(themeControllerProvider);
    //var musicStatusProvider = ref.watch(musicStatusControllerProvider);

    double padding = MediaQuery.of(context).viewPadding.top;
    double height =
        MediaQuery.of(context).size.height - kToolbarHeight - padding;

    return Scaffold(
      appBar: const AppBarMain(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: AnimatedContainer(
              color: theme.backgroundColor1,
              height: listenProvider.isOpen ? 0 : height * 0.6,
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: const PageListenList(),
            ),
          ),
          Positioned(
            bottom: 0,
            child: AnimatedContainer(
              height: listenProvider.isOpen ? height : height * 0.4,
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              color: theme.cardBackground1,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                      flex: 1,
                      child: Center(
                        child: ButtonMore(),
                      )),
                  Expanded(
                    flex: listenProvider.isOpen ? 5 : 3,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: PageListenDetail(),
                    ),
                  ),

                  Expanded(
                    flex: listenProvider.isOpen ? 3 : 2,
                    child: const PageListenControl(),
                  ),
                  // PageListenDetail(),
                ],
              ),
            ),
          )

          // Expanded(
          //   child: AnimatedPositioned(
          //     height: listenProvider.isOpen ? 0 : height * 0.6,
          //     width: MediaQuery.of(context).size.width,
          //     duration: const Duration(milliseconds: 500),
          //     child: const PageListenList(),
          //   ),
          // ),
          // AnimatedPositioned(
          //   height: listenProvider.isOpen ? 0 : height * 0.4,
          //   width: MediaQuery.of(context).size.width,
          //   duration: const Duration(milliseconds: 500),
          //   child: Positioned(
          //     bottom: 0,
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: const [
          //         ButtonMore(),
          //         PageListenDetail(),
          //         PageListenControl()
          //       ],
          //     ),
          //   ),
          // ),

          // Positioned(
          //   bottom: 0,
          //   child: Expanded(
          //     child: AnimatedContainer(
          //       duration: const Duration(milliseconds: 500),
          //       curve: Curves.fastOutSlowIn,
          //       height: listenProvider.isOpen ? height : height * 0.4,
          //       width: MediaQuery.of(context).size.width,
          //       decoration: BoxDecoration(
          //         border: Border(
          //           top: BorderSide(
          //             width: listenProvider.isOpen ? 0.0 : 1.0,
          //             color: listenProvider.isOpen
          //                 ? Colors.transparent
          //                 : Colors.white30,
          //           ),
          //         ),
          //       ),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: const [
          //           ButtonMore(),
          //           PageListenDetail(),
          //           PageListenControl()
          //         ],
          //       ),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
