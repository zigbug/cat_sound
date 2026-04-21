import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';

/// Виджет кнопки добавления точки останова
class AddBreakpointButton extends StatelessWidget {
  const AddBreakpointButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 50,
      icon: const Icon(Icons.add_circle),
      onPressed: () => _showAddBreakpointDialog(context),
    );
  }

  void _showAddBreakpointDialog(BuildContext context) {
    final bloc = context.read<AudioBloc>();
    final state = context.read<AudioBloc>().state;

    if (state.isPlaying) {
      bloc.add(const AudioPauseRequested());
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String name = '';
            String description = '';

            return AlertDialog(
              title: const Text('Добавить точку'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(labelText: 'Название'),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Описание'),
                    onChanged: (value) => description = value,
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Отмена'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Добавить'),
                  onPressed: () {
                    bloc.add(AudioBreakpointAdded(
                      name: name.isEmpty ? 'Без названия' : name,
                      description: description,
                      position: state.position,
                      trackNumber: state.selectedTrack,
                    ));
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
