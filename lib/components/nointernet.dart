import 'dart:io';

import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, required this.onPressed});

  final Function onPressed;

  Future<bool> online() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return (result.isNotEmpty && result[0].rawAddress.isNotEmpty);
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: online(), // function where you call your api
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // AsyncSnapshot<Your object type>
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.blueAccent,
          );
        } else {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/nointernet.png",
                  width: 100,
                  fit: BoxFit.fitWidth,
                ),
                const Text(
                  "Sem acesso à Internet. \nFavor verifique sua conexão e tente novamente!",
                  textAlign: TextAlign.center,
                ),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      maximumSize: Size.fromWidth(250),
                    ),
                    onPressed: () {
                      onPressed();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.refresh_outlined),
                        Text("TENTAR NOVAMENTE!"),
                      ],
                    ))
              ],
            ),
          ); // snapshot.data  :- get your object which is pass from your downloadData() function
        }
      },
    );
  }
}
