import 'package:margarida/common/constants.dart';
import 'package:flutter/material.dart';

class AppBarMain extends StatelessWidget with PreferredSizeWidget {
  const AppBarMain({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Margarida',
            style: TextStyle(color: Constants.TITLE_COLOR),
          ),
        ],
      ),
      backgroundColor: Constants.APPBAR_COLOR,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
