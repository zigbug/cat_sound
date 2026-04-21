import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../widgets/track_selector_widget.dart';
import '../widgets/audio_controls_widget.dart';
import '../widgets/audio_slider_widget.dart';
import '../widgets/breakpoint_list_widget.dart';
import '../widgets/add_breakpoint_button.dart';
import '../widgets/save_breakpoints_button.dart';
import '../widgets/time_display_widget.dart';

/// Главная страница приложения
class MainPage extends StatelessWidget {
  final String title;

  const MainPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioBloc, AudioFullState>(
      listener: (context, state) {
        // Показываем уведомления
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: BlocBuilder<AudioBloc, AudioFullState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AudioFullState state) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          opacity: 0.4,
          image: AssetImage('assets/bckgrnd.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Выбор треков
            _buildTrackSelector(context, state),
            // Контролы воспроизведения
            _buildAudioControls(context, state),
            // Слайдер с точками останова
            _buildAudioSlider(context, state),
            // Время
            _buildTimeDisplay(state),
            // Кнопка сохранения
            const SaveBreakpointsButton(),
            // Список точек останова
            Expanded(
              child: _buildBreakpointList(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackSelector(BuildContext context, AudioFullState state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TrackSelectorWidget(
            trackName: state.track1Path,
            trackNumber: 1,
            isSelected: state.selectedTrack == 1,
            onTap: () => context
                .read<AudioBloc>()
                .add(const AudioTrackSelected(trackNumber: 1)),
            onFileSelected: (trackNumber) =>
                _showFilePicker(context, trackNumber),
          ),
          TrackSelectorWidget(
            trackName: state.track2Path,
            trackNumber: 2,
            isSelected: state.selectedTrack == 2,
            onTap: () => context
                .read<AudioBloc>()
                .add(const AudioTrackSelected(trackNumber: 2)),
            onFileSelected: (trackNumber) =>
                _showFilePicker(context, trackNumber),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context, AudioFullState state) {
    return AudioControlsWidget(
      duration: state.duration,
      position: state.position,
      isPlaying: state.isPlaying,
      onPlay: () => context.read<AudioBloc>().add(const AudioPlayRequested()),
      onPause: () => context.read<AudioBloc>().add(const AudioPauseRequested()),
      onSeekToStart: () =>
          context.read<AudioBloc>().add(const AudioSeekToStartRequested()),
    );
  }

  Widget _buildAudioSlider(BuildContext context, AudioFullState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AudioSliderWidget(
        position: state.position,
        duration: state.duration,
        breakpoints: state.currentBreakpoints,
        onSeek: (position) => context
            .read<AudioBloc>()
            .add(AudioSeekToPositionRequested(position: position)),
        onBreakpointDragged: (index, newPosition) {
          context.read<AudioBloc>().add(AudioBreakpointDragged(
                index: index,
                newPosition: newPosition,
                trackNumber: state.selectedTrack,
              ));
        },
      ),
    );
  }

  Widget _buildTimeDisplay(AudioFullState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DurationDisplayWidget(duration: state.position),
          DurationDisplayWidget(duration: state.duration),
        ],
      ),
    );
  }

  Widget _buildBreakpointList(BuildContext context, AudioFullState state) {
    return ListView.builder(
      itemCount: state.currentBreakpoints.length,
      itemBuilder: (context, index) {
        final breakpoint = state.currentBreakpoints[index];
        return BreakpointListItem(
          breakpoint: breakpoint,
          onTap: () => context
              .read<AudioBloc>()
              .add(AudioSeekToPositionRequested(position: breakpoint.position)),
          onEdit: () =>
              _showEditBreakpointDialog(context, index, state.selectedTrack),
          onDelete: () => _showDeleteConfirmationDialog(
              context, index, state.selectedTrack),
        );
      },
    );
  }

  Future<void> _showFilePicker(BuildContext context, int trackNumber) async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null && result.files.single.path != null) {
        context.read<AudioBloc>().add(AudioFileSelected(
              filePath: result.files.single.path!,
              trackNumber: trackNumber,
            ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
  }

  void _showEditBreakpointDialog(
      BuildContext context, int index, int trackNumber) {
    final bloc = context.read<AudioBloc>();
    final state = context.read<AudioBloc>().state;

    final breakpoints =
        trackNumber == 1 ? state.breakpoints1 : state.breakpoints2;
    if (index >= 0 && index < breakpoints.length) {
      final breakpoint = breakpoints[index];

      if (state.isPlaying) {
        bloc.add(const AudioPauseRequested());
      }

      showDialog(
        context: context,
        builder: (context) {
          final nameController = TextEditingController(text: breakpoint.name);
          final descController =
              TextEditingController(text: breakpoint.description);

          return AlertDialog(
            title: const Text('Редактировать точку'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Название'),
                  controller: nameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Описание'),
                  controller: descController,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text('Сохранить'),
                onPressed: () {
                  bloc.add(AudioBreakpointEdited(
                    index: index,
                    name: nameController.text,
                    description: descController.text,
                    trackNumber: trackNumber,
                  ));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, int index, int trackNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить точку'),
        content: const Text('Уверены, что хотите удалить эту точку?'),
        actions: [
          TextButton(
            child: const Text('Отмена'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Удалить'),
            onPressed: () {
              context.read<AudioBloc>().add(AudioBreakpointDeleted(
                    index: index,
                    trackNumber: trackNumber,
                  ));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
