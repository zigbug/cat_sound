import 'dart:async';
import 'package:bloc/bloc.dart';
import '../models/breakpoint.dart';
import '../services/file_storage_service.dart';
import '../utils/audio_utility.dart';
import 'audio_event.dart';
import 'audio_state.dart';

/// Bloc для управления аудио-логикой приложения
class AudioBloc extends Bloc<AudioEvent, AudioFullState> {
  final AudioUtility _audioUtility;
  final FileStorageService _fileStorageService;

  // Stream subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  AudioBloc({
    required AudioUtility audioUtility,
    required FileStorageService fileStorageService,
  })  : _audioUtility = audioUtility,
        _fileStorageService = fileStorageService,
        super(const AudioFullState()) {
    on<AudioFileSelected>(_onFileSelected);
    on<AudioPlayRequested>(_onPlayRequested);
    on<AudioPauseRequested>(_onPauseRequested);
    on<AudioStopRequested>(_onStopRequested);
    on<AudioSeekToStartRequested>(_onSeekToStartRequested);
    on<AudioSeekToPositionRequested>(_onSeekToPositionRequested);
    on<AudioBreakpointAdded>(_onBreakpointAdded);
    on<AudioBreakpointEdited>(_onBreakpointEdited);
    on<AudioBreakpointDeleted>(_onBreakpointDeleted);
    on<AudioTrackSelected>(_onTrackSelected);
    on<AudioBreakpointsSaved>(_onBreakpointsSaved);
    on<AudioBreakpointsLoaded>(_onBreakpointsLoaded);
    on<AudioBreakpointDragged>(_onBreakpointDragged);
    on<_AudioPositionChanged>(_onPositionChanged);
    on<_AudioDurationChanged>(_onDurationChanged);
    on<_ShowSnackBar>(_onShowSnackBar);

    // Инициализация слушателей аудио
    _initAudioListeners();
  }

  void _initAudioListeners() {
    // Подписка на изменения позиции
    _positionSubscription = _audioUtility.onPositionChanged.listen((position) {
      add(_AudioPositionChanged(position));
    });

    // Подписка на изменения длительности
    _durationSubscription = _audioUtility.onDurationChanged.listen((duration) {
      add(_AudioDurationChanged(duration));
    });
  }

  Future<void> _onFileSelected(
      AudioFileSelected event, Emitter<AudioFullState> emit) async {
    emit(state.copyWith(errorMessage: null));

    try {
      if (event.trackNumber == 1) {
        emit(state.copyWith(track1Path: event.filePath));
        add(AudioBreakpointsLoaded(filePath: event.filePath));
      } else {
        emit(state.copyWith(track2Path: event.filePath));
        add(AudioBreakpointsLoaded(filePath: event.filePath));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при выборе файла: $e'));
    }
  }

  Future<void> _onPlayRequested(
      AudioPlayRequested event, Emitter<AudioFullState> emit) async {
    final trackPath =
        state.selectedTrack == 1 ? state.track1Path : state.track2Path;

    if (trackPath == 'Выберите файл +' || trackPath == 'Выберите файл -') {
      emit(state.copyWith(errorMessage: 'Сначала выберите аудиофайл'));
      return;
    }

    try {
      await _audioUtility.play(trackPath);
      emit(state.copyWith(isPlaying: true, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при воспроизведении: $e'));
    }
  }

  Future<void> _onPauseRequested(
      AudioPauseRequested event, Emitter<AudioFullState> emit) async {
    try {
      await _audioUtility.pause();
      emit(state.copyWith(isPlaying: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при паузе: $e'));
    }
  }

  Future<void> _onStopRequested(
      AudioStopRequested event, Emitter<AudioFullState> emit) async {
    try {
      await _audioUtility.stop();
      await _audioUtility.seekToStart();
      emit(state.copyWith(isPlaying: false, position: Duration.zero));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при остановке: $e'));
    }
  }

  Future<void> _onSeekToStartRequested(
      AudioSeekToStartRequested event, Emitter<AudioFullState> emit) async {
    try {
      await _audioUtility.seekToStart();
      emit(state.copyWith(position: Duration.zero));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при перемотке: $e'));
    }
  }

  Future<void> _onSeekToPositionRequested(
      AudioSeekToPositionRequested event, Emitter<AudioFullState> emit) async {
    try {
      await _audioUtility.seek(event.position);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Ошибка при перемотке: $e'));
    }
  }

  Future<void> _onBreakpointAdded(
      AudioBreakpointAdded event, Emitter<AudioFullState> emit) async {
    final breakpoint = Breakpoint(
      name: event.name,
      description: event.description,
      position: event.position,
    );

    if (event.trackNumber == 1) {
      emit(state.copyWith(
        breakpoints1: [...state.breakpoints1, breakpoint],
      ));
    } else {
      emit(state.copyWith(
        breakpoints2: [...state.breakpoints2, breakpoint],
      ));
    }
  }

  Future<void> _onBreakpointEdited(
      AudioBreakpointEdited event, Emitter<AudioFullState> emit) async {
    if (event.trackNumber == 1) {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints1);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints[event.index] =
            updatedBreakpoints[event.index].copyWith(
          name: event.name,
          description: event.description,
        );
        emit(state.copyWith(
          breakpoints1: updatedBreakpoints,
        ));
      }
    } else {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints2);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints[event.index] =
            updatedBreakpoints[event.index].copyWith(
          name: event.name,
          description: event.description,
        );
        emit(state.copyWith(
          breakpoints2: updatedBreakpoints,
        ));
      }
    }
  }

  Future<void> _onBreakpointDeleted(
      AudioBreakpointDeleted event, Emitter<AudioFullState> emit) async {
    if (event.trackNumber == 1) {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints1);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints.removeAt(event.index);
        emit(state.copyWith(
          breakpoints1: updatedBreakpoints,
        ));
      }
    } else {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints2);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints.removeAt(event.index);
        emit(state.copyWith(
          breakpoints2: updatedBreakpoints,
        ));
      }
    }
  }

  Future<void> _onTrackSelected(
      AudioTrackSelected event, Emitter<AudioFullState> emit) async {
    emit(state.copyWith(selectedTrack: event.trackNumber));
  }

  Future<void> _onBreakpointsSaved(
      AudioBreakpointsSaved event, Emitter<AudioFullState> emit) async {
    final trackPath = state.currentTrackPath;

    if (trackPath == 'Выберите файл +' || trackPath == 'Выберите файл -') {
      emit(state.copyWith(errorMessage: 'Сначала выберите аудиофайл'));
      return;
    }

    try {
      final breakpointsData = state.currentBreakpoints
          .map((bp) => {
                'name': bp.name,
                'description': bp.description,
                'position': bp.position.inMilliseconds,
              })
          .toList();

      await _fileStorageService.saveBreakpoints(trackPath, breakpointsData);

      // Показываем уведомление через событие
      add(_ShowSnackBar('Точки останова сохранены'));
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Ошибка при сохранении точек останова: $e'));
    }
  }

  Future<void> _onBreakpointsLoaded(
      AudioBreakpointsLoaded event, Emitter<AudioFullState> emit) async {
    try {
      final breakpointsData =
          await _fileStorageService.loadBreakpoints(event.filePath);

      if (breakpointsData != null) {
        final breakpoints = breakpointsData
            .map((data) => Breakpoint(
                  name: data['name'] as String,
                  description: data['description'] as String,
                  position: Duration(milliseconds: data['position'] as int),
                ))
            .toList();

        if (event.filePath == state.track1Path) {
          emit(state.copyWith(
            breakpoints1: breakpoints,
          ));
        } else if (event.filePath == state.track2Path) {
          emit(state.copyWith(
            breakpoints2: breakpoints,
          ));
        }

        add(const _ShowSnackBar('Точки останова загружены'));
      } else {
        // Файл не найден - очищаем список
        if (event.filePath == state.track1Path) {
          emit(state.copyWith(
            breakpoints1: [],
          ));
        } else if (event.filePath == state.track2Path) {
          emit(state.copyWith(
            breakpoints2: [],
          ));
        }
        add(const _ShowSnackBar('Для этого трека пока нет точек останова'));
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Ошибка при загрузке точек останова: $e'));
    }
  }

  Future<void> _onBreakpointDragged(
      AudioBreakpointDragged event, Emitter<AudioFullState> emit) async {
    if (event.trackNumber == 1) {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints1);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints[event.index] =
            updatedBreakpoints[event.index].copyWith(
          position: event.newPosition,
        );
        emit(state.copyWith(
          breakpoints1: updatedBreakpoints,
        ));
      }
    } else {
      final updatedBreakpoints = List<Breakpoint>.from(state.breakpoints2);
      if (event.index >= 0 && event.index < updatedBreakpoints.length) {
        updatedBreakpoints[event.index] =
            updatedBreakpoints[event.index].copyWith(
          position: event.newPosition,
        );
        emit(state.copyWith(
          breakpoints2: updatedBreakpoints,
        ));
      }
    }
  }

  void _onPositionChanged(
      _AudioPositionChanged event, Emitter<AudioFullState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationChanged(
      _AudioDurationChanged event, Emitter<AudioFullState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onShowSnackBar(_ShowSnackBar event, Emitter<AudioFullState> emit) {
    // Уведомление обрабатывается в UI через BlocListener
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioUtility.dispose();
    return super.close();
  }
}

// Внутренние события для stream-подписок
class _AudioPositionChanged extends AudioEvent {
  final Duration position;
  const _AudioPositionChanged(this.position);
}

class _AudioDurationChanged extends AudioEvent {
  final Duration duration;
  const _AudioDurationChanged(this.duration);
}

class _ShowSnackBar extends AudioEvent {
  final String message;
  const _ShowSnackBar(this.message);
}
