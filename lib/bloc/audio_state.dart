import 'package:equatable/equatable.dart';
import '../models/breakpoint.dart';

/// Базовый класс для всех состояний аудио-блока
abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class AudioInitial extends AudioState {
  const AudioInitial();
}

/// Состояние загрузки
class AudioLoading extends AudioState {
  const AudioLoading();
}

/// Состояние успеха
class AudioSuccess extends AudioState {
  const AudioSuccess();
}

/// Состояние ошибки
class AudioError extends AudioState {
  final String message;

  const AudioError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние воспроизведения
class AudioPlayingState extends AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  const AudioPlayingState({
    required this.isPlaying,
    required this.position,
    required this.duration,
  });

  @override
  List<Object?> get props => [isPlaying, position, duration];
}

/// Полное состояние приложения
class AudioFullState extends AudioState {
  final String track1Path;
  final String track2Path;
  final int selectedTrack;
  final List<Breakpoint> breakpoints1;
  final List<Breakpoint> breakpoints2;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? errorMessage;

  const AudioFullState({
    this.track1Path = 'Выберите файл +',
    this.track2Path = 'Выберите файл -',
    this.selectedTrack = 1,
    this.breakpoints1 = const [],
    this.breakpoints2 = const [],
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
  });

  List<Breakpoint> get currentBreakpoints =>
      selectedTrack == 1 ? breakpoints1 : breakpoints2;
  String get currentTrackPath => selectedTrack == 1 ? track1Path : track2Path;

  AudioFullState copyWith({
    String? track1Path,
    String? track2Path,
    int? selectedTrack,
    List<Breakpoint>? breakpoints1,
    List<Breakpoint>? breakpoints2,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? errorMessage,
  }) {
    return AudioFullState(
      track1Path: track1Path ?? this.track1Path,
      track2Path: track2Path ?? this.track2Path,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      breakpoints1: breakpoints1 ?? this.breakpoints1,
      breakpoints2: breakpoints2 ?? this.breakpoints2,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        track1Path,
        track2Path,
        selectedTrack,
        breakpoints1,
        breakpoints2,
        isPlaying,
        position,
        duration,
        errorMessage,
      ];
}
