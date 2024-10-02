import 'package:cat_sound/page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life is... Skipping rope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 120, 233, 227)),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Life is... Skipping rope'),
    );
  }
}
