import 'package:cat_sound/widgets/add_breakpoint_button.dart';
import 'package:cat_sound/widgets/button.dart';
import 'package:flutter/material.dart';

/// Виджет кнопок управления воспроизведением
class AudioControlsWidget extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final VoidCallback onSeekToStart;
  final bool activateButtons;

  const AudioControlsWidget({
    super.key,
    required this.duration,
    required this.position,
    required this.isPlaying,
    required this.onPlay,
    required this.onPause,
    required this.onSeekToStart,
    required this.activateButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Кнопка "В начало"
        GlassButton(
            width: 80,
            height: 80,
            key: const Key('toStart'),
            active: activateButtons,
            onPressed: onSeekToStart,
            signToShow: Image.asset('assets/pause_sign.png')),

        // Кнопка Play/Pause
        GlassButton(
          key: const Key('play'),
          active: activateButtons,
          onPressed: isPlaying ? onPause : onPlay,
          signToShow: isPlaying
              ? Image.asset('assets/pause_sign.png')
              : Image.asset('assets/play_sign.png'),
        ),
        // Кнопка добавления точки
        const AddBreakpointButton(),
      ],
    );
  }
}
