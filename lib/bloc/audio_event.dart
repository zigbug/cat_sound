import 'package:equatable/equatable.dart';

/// Базовый класс для всех событий аудио-блока
abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

/// Событие выбора аудиофайла
class AudioFileSelected extends AudioEvent {
  final String filePath;
  final int trackNumber; // 1 или 2

  const AudioFileSelected({required this.filePath, required this.trackNumber});

  @override
  List<Object?> get props => [filePath, trackNumber];
}

/// Событие запуска воспроизведения
class AudioPlayRequested extends AudioEvent {
  const AudioPlayRequested();
}

/// Событие паузы воспроизведения
class AudioPauseRequested extends AudioEvent {
  const AudioPauseRequested();
}

/// Событие остановки воспроизведения
class AudioStopRequested extends AudioEvent {
  const AudioStopRequested();
}

/// Событие перемотки в начало
class AudioSeekToStartRequested extends AudioEvent {
  const AudioSeekToStartRequested();
}

/// Событие перемотки к позиции
class AudioSeekToPositionRequested extends AudioEvent {
  final Duration position;

  const AudioSeekToPositionRequested({required this.position});

  @override
  List<Object?> get props => [position];
}

/// Событие добавления точки останова
class AudioBreakpointAdded extends AudioEvent {
  final String name;
  final String description;
  final Duration position;
  final int trackNumber;

  const AudioBreakpointAdded({
    required this.name,
    required this.description,
    required this.position,
    required this.trackNumber,
  });

  @override
  List<Object?> get props => [name, description, position, trackNumber];
}

/// Событие редактирования точки останова
class AudioBreakpointEdited extends AudioEvent {
  final int index;
  final String name;
  final String description;
  final int trackNumber;

  const AudioBreakpointEdited({
    required this.index,
    required this.name,
    required this.description,
    required this.trackNumber,
  });

  @override
  List<Object?> get props => [index, name, description, trackNumber];
}

/// Событие удаления точки останова
class AudioBreakpointDeleted extends AudioEvent {
  final int index;
  final int trackNumber;

  const AudioBreakpointDeleted({required this.index, required this.trackNumber});

  @override
  List<Object?> get props => [index, trackNumber];
}

/// Событие переключения выбранного трека
class AudioTrackSelected extends AudioEvent {
  final int trackNumber;

  const AudioTrackSelected({required this.trackNumber});

  @override
  List<Object?> get props => [trackNumber];
}

/// Событие сохранения точек останова
class AudioBreakpointsSaved extends AudioEvent {
  const AudioBreakpointsSaved();
}

/// Событие загрузки точек останова для трека
class AudioBreakpointsLoaded extends AudioEvent {
  final String filePath;

  const AudioBreakpointsLoaded({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Событие перетаскивания точки останова
class AudioBreakpointDragged extends AudioEvent {
  final int index;
  final Duration newPosition;
  final int trackNumber;

  const AudioBreakpointDragged({
    required this.index,
    required this.newPosition,
    required this.trackNumber,
  });

  @override
  List<Object?> get props => [index, newPosition, trackNumber];
}
