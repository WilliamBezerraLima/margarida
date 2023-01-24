import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margarida/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:margarida/riverpod/theme_controller.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AppBarMain extends ConsumerWidget with PreferredSizeWidget {
  const AppBarMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeControllerProvider);

    return AppBar(
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.blueAccent.shade100),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            scale: 5,
          ),
          const SizedBox(width: 10),
          Text(
            'Margarida',
            style: TextStyle(color: themeProvider.appBarText1),
          ),
        ],
      ),
      backgroundColor: themeProvider.appBarColor1,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleSwitch(
            minWidth: 50.0,
            minHeight: 20.0,

            initialLabelIndex: themeProvider.dark ? 0 : 1,
            cornerRadius: 30.0,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey,
            inactiveFgColor: Colors.white,
            totalSwitches: 2,
            icons: const [
              Icons.lightbulb_outline,
              Icons.lightbulb,
            ],
            iconSize: 40.0,
            activeBgColors: const [
              [Colors.black45, Colors.black26],
              [Colors.yellow, Colors.orange]
            ],
            animate:
                true, // with just animate set to true, default curve = Curves.easeIn
            curve: Curves
                .bounceInOut, // animate must be set to true when using custom curve
            onToggle: (index) {
              if (index == 0) {
                themeProvider.setDark();
              } else {
                themeProvider.setLight();
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
