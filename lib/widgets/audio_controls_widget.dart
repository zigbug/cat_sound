import 'package:flutter/material.dart';

/// Виджет кнопок управления воспроизведением
class AudioControlsWidget extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final VoidCallback onSeekToStart;

  const AudioControlsWidget({
    super.key,
    required this.duration,
    required this.position,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    required this.onStop,
    required this.onSeekToStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Кнопка "В начало"
        IconButton(
          iconSize: 50,
          icon: const Icon(Icons.skip_previous),
          onPressed: onSeekToStart,
        ),
        // Кнопка Play/Pause
        IconButton(
          iconSize: 100,
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
          ),
          onPressed: isPlaying ? onPause : onPlay,
        ),
        // Кнопка остановки
        IconButton(
          iconSize: 50,
          icon: const Icon(Icons.stop),
          onPressed: onStop,
        ),
      ],
    );
  }
}
