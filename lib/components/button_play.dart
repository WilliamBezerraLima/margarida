import 'dart:math';

import 'package:margarida/riverpod/controls_controller.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ButtonPlay extends HookConsumerWidget {
  final Duration duration = const Duration(milliseconds: 300);

  const ButtonPlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    final controller = useAnimationController(
        duration: const Duration(milliseconds: 300), initialValue: 1);

    final controllerContainer = useAnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );

    Animation<double> offset =
        Tween<double>(begin: 1, end: 1.3).animate(controllerContainer);

    ref.listen<ControlsController>(controlsControllerProvider,
        (previous, next) {
      if (next.playing) {
        controllerContainer.forward();
        controller.forward();
      } else {
        controllerContainer.reverse();
        controller.reverse();
      }
    });

    return AnimatedBuilder(
        animation: controllerContainer,
        builder: (context, child) {
          return ScaleTransition(
            scale: offset,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withAlpha(60),
                    blurRadius: 4.0,
                    spreadRadius: 4.0,
                    offset: const Offset(
                      0.0,
                      3.0,
                    ),
                  ),
                ],
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.blueAccent, // Button color
                  child: InkWell(
                    splashColor: Colors.red, // Splash color
                    onTap: () async {
                      if (listProvider.playing) {
                        listProvider.pause();
                      } else {
                        listProvider.play();
                      }
                    },
                    child: SizedBox(
                        width: 80 * ratio,
                        height: 80 * ratio,
                        child: Center(
                          child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            color: Colors.white,
                            size: 80 * ratio,
                            progress: controller,
                          ),
                        )),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
