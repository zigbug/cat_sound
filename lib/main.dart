import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/audio_bloc.dart';
import 'services/file_storage_service.dart';
import 'utils/audio_utility.dart';
import 'pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioBloc(
        audioUtility: AudioUtility(),
        fileStorageService: FileStorageService(),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Life is... Skipping rope',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 120, 233, 227),
          ),
          useMaterial3: true,
        ),
        home: const MainPage(title: 'Life is... Skipping rope'),
      ),
    );
  }
}
