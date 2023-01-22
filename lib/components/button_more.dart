import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonMore extends ConsumerWidget {
  const ButtonMore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listenProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return ClipOval(
      child: Material(
        color: Colors.white.withAlpha(20), // Button color
        child: InkWell(
          splashColor: Colors.white, // Splash color
          onTap: () {
            listenProvider.toggle();
          },
          child: SizedBox(
            width: 70 * ratio,
            height: 70 * ratio,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              turns: listenProvider.turns,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.blueAccent,
                size: 68 * ratio,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
