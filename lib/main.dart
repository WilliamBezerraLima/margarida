import 'package:margarida/riverpod/configuration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final darkTheme = ThemeData(
  primarySwatch: Colors.grey,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF212121),
  // accentColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.black),
  dividerColor: Colors.black12,
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configProvider = ref.read(configurationControllerProvider);
    configProvider.loadConfigurationFromDatabase();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: darkTheme,
      title: 'Margarida',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'JosefinSans'),
      home: const MainScreen(),
    );
  }
}
