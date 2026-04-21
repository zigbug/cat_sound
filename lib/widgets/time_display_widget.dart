import 'package:flutter/material.dart';

/// Утилита для форматирования длительности в строку MM:SS
class TimeUtils {
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

/// Виджет для отображения длительности
class DurationDisplayWidget extends StatelessWidget {
  final Duration duration;

  const DurationDisplayWidget({
    super.key,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Text(TimeUtils.formatDuration(duration));
  }
}
