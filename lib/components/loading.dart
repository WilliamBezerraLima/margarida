import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
