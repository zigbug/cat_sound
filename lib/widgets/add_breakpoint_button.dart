import 'package:cat_sound/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';

/// Виджет кнопки добавления точки останова
class AddBreakpointButton extends StatelessWidget {
  final bool activateButtons;

  const AddBreakpointButton({super.key, this.activateButtons = true});

  @override
  Widget build(BuildContext context) {
    return GlassButton(
        width: 80,
        height: 80,
        key: const Key('toStart'),
        active: activateButtons,
        onPressed: () => _showAddBreakpointDialog(context),
        signToShow: Image.asset('assets/pause_sign.png'));
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
