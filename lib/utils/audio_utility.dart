import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Утилита для работы с аудио: воспроизведение, пауза, перемотка, обработка событий
class AudioUtility {
  final AudioPlayer _player = AudioPlayer();

  // Streams для передачи событий в Bloc
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  /// Текущее состояние воспроизведения
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Воспроизведение аудиофайла
  Future<void> play(String filePath) async {
    await _player.play(DeviceFileSource(filePath));
  }

  /// Пауза воспроизведения
  Future<void> pause() async {
    await _player.pause();
  }

  /// Остановка воспроизведения
  Future<void> stop() async {
    await _player.stop();
  }

  /// Перемотка к указанной позиции
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Перемотка в начало
  Future<void> seekToStart() async {
    await _player.seek(Duration.zero);
  }

  /// Подписка на событие завершения воспроизведения
  void setOnPlayerCompleteListener(VoidCallback callback) {
    _player.onPlayerComplete.listen((event) {
      callback();
    });
  }

  /// Получение экземпляра AudioPlayer (для расширенных операций)
  AudioPlayer getPlayer() => _player;

  /// Освобождение ресурсов
  Future<void> dispose() async {
    await _player.dispose();
  }
}
