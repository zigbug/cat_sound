import 'package:flutter/material.dart';

/// Виджет выбора аудиофайла для трека
class TrackSelectorWidget extends StatelessWidget {
  final String trackName;
  final int trackNumber;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(int trackNumber) onFileSelected;

  const TrackSelectorWidget({
    super.key,
    required this.trackName,
    required this.trackNumber,
    required this.isSelected,
    required this.onTap,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InputChip(
          label: Text(
              trackName == 'Выберите файл ${trackNumber == 1 ? '+' : '-'}'
                  ? trackName
                  : trackName.split('\\').last),
          onPressed: onTap,
          selected: isSelected,
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: InkWell(
            onTap: () => onFileSelected(trackNumber),
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 147, 223, 219),
              ),
              child: const Icon(
                Icons.folder,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
