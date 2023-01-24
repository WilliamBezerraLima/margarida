import 'package:margarida/riverpod/configuration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:margarida/riverpod/theme_controller.dart';

import 'main_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// final darkTheme = ThemeData(
//   primarySwatch: Colors.grey,
//   primaryColor: Colors.black,
//   brightness: Brightness.dark,
//   backgroundColor: const Color(0xFF212121),
//   accentColor: Colors.white,
//   iconTheme: const IconThemeData(color: Colors.black),
//   dividerColor: Colors.black12,
// );

// final lightTheme = ThemeData(
//   primarySwatch: Colors.grey,
//   primaryColor: Colors.white,
//   brightness: Brightness.light,
//   backgroundColor: const Color(0xFFE5E5E5),
//   accentColor: Colors.black,
//   iconTheme: const IconThemeData(color: Colors.white),
//   dividerColor: Colors.white54,
// );

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: AppBarTheme(
    color: Color(0xFF616161),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: const Color(0xFFFAFAFA),
    onPrimary: const Color(0xFFFAFAFA),
    primaryVariant: Colors.white38,
    secondary: Colors.red,
  ),
  cardTheme: const CardTheme(
    //color: const Color(0xFFE5E5E5),
    color: Colors.white,
  ),
  iconTheme: const IconThemeData(
    color: Colors.white54,
  ),
  textTheme: const TextTheme(
    subtitle1: TextStyle(
      color: Colors.black87,
      fontSize: 20.0,
    ),
    subtitle2: TextStyle(
      color: Colors.white70,
      fontSize: 18.0,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.grey,
  appBarTheme: const AppBarTheme(
    color: Colors.grey,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.black,
    primaryVariant: Colors.black,
    secondary: Colors.red,
  ),
  cardTheme: const CardTheme(
    color: Color(0xFFE5E5E5),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white54,
  ),
  textTheme: const TextTheme(
    subtitle1: TextStyle(
      color: Colors.black87,
      fontSize: 20.0,
    ),
    subtitle2: TextStyle(
      color: Colors.white70,
      fontSize: 18.0,
    ),
  ),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configProvider = ref.read(configurationControllerProvider);
    final themeProvider = ref.watch(themeControllerProvider);
    configProvider.loadConfigurationFromDatabase();

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Margarida',
      //theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'JosefinSans'),
      home: MainScreen(),
    );
  }
}
