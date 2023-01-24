import 'package:margarida/components/button_play.dart';
import 'package:margarida/riverpod/listen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageListenControl extends StatefulWidget {
  const PageListenControl({super.key});

  @override
  State<PageListenControl> createState() => _PageListenControlState();
}

class _PageListenControlState extends State<PageListenControl> {
  @override
  Widget build(BuildContext context) {
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Progress(),
        const SizedBox(height: 4),
        const Timers(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ButtonPrevious(),
            SizedBox(width: 85 * ratio),
            const ButtonPlay(),
            SizedBox(width: 85 * ratio),
            const ButtonNext()
          ],
        )
      ],
    );
  }
}

class Progress extends ConsumerWidget {
  const Progress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return SliderTheme(
      data: SliderThemeData(
        overlayShape: RoundSliderOverlayShape(overlayRadius: 1 * ratio),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18 * ratio),
        trackHeight: 5 * ratio,
      ),
      child: Slider(
        activeColor: Colors.blueAccent.shade100,
        thumbColor: Colors.blueAccent,
        inactiveColor: Colors.black12,
        value: listProvider.position,
        max: listProvider.maxPosition,
        label: listProvider.position.round().toString(),
        onChanged: (double position) {
          listProvider.setPosition(position);
        },
      ),
    );
  }
}

class Timers extends ConsumerWidget {
  const Timers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(listProvider.positionDisplay,
              style: TextStyle(fontSize: 22 * ratio, color: Colors.white60)),
          if (listProvider.audio != null)
            Text(listProvider.audio!.duration!,
                style: TextStyle(fontSize: 22 * ratio, color: Colors.white60)),
        ],
      ),
    );
  }
}

class ButtonPrevious extends ConsumerWidget {
  const ButtonPrevious({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return ClipOval(
      child: Material(
        color: Colors.transparent, // Button color
        child: InkWell(
          splashColor: Colors.black12, // Splash color
          onTap: () {
            listProvider.previous();
          },
          child: SizedBox(
              width: 80 * ratio,
              height: 80 * ratio,
              child: Icon(
                Icons.skip_previous_rounded,
                color: Colors.blueAccent,
                size: 78 * ratio,
              )),
        ),
      ),
    );
  }
}

class ButtonNext extends ConsumerWidget {
  const ButtonNext({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var listProvider = ref.watch(listenControllerProvider);
    var ratio = MediaQuery.of(context).size.aspectRatio;

    return ClipOval(
      child: Material(
        color: Colors.transparent, // Button color
        child: InkWell(
          splashColor: Colors.black12, // Splash color
          onTap: () {
            listProvider.next();
          },
          child: SizedBox(
              width: 80 * ratio,
              height: 80 * ratio,
              child: Icon(
                Icons.skip_next_rounded,
                color: Colors.blueAccent,
                size: 78 * ratio,
              )),
        ),
      ),
    );
  }
}
