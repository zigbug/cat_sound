import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';

/// Виджет кнопки сохранения точек останова
class SaveBreakpointsButton extends StatelessWidget {
  const SaveBreakpointsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            context.read<AudioBloc>().add(const AudioBreakpointsSaved());
          },
          child: const Text('Сохранить точки'),
        ),
      ),
    );
  }
}
