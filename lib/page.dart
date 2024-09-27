import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Список точек останова
  List<Breakpoint> breakpoints = [];

  // Индекс перемещаемой точки останова (или null, если никакая не перемещается)
  int? draggingBreakpointIndex;

  @override
  void initState() {
    super.initState();

    player.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    player.onPositionChanged.listen((Duration newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    player.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<void> _playSound() async {
    await player.play(AssetSource('01-ООР~1.MP3'));
    setState(() {
      isPlaying = true;
    });
  }

  Future<void> _stopSound() async {
    await player.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _pauseSound() async {
    await player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  // Функция для добавления точки останова
  void _addBreakpoint() {
    // Ставим на паузу при открытии диалога
    if (isPlaying) {
      _pauseSound();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String description = '';

        return AlertDialog(
          title: const Text('Добавить точку останова'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Название'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Описание'),
                onChanged: (value) {
                  description = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Добавить'),
              onPressed: () {
                setState(() {
                  breakpoints.add(Breakpoint(
                    name: name,
                    description: description,
                    position: position,
                  ));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 100,
                  icon:
                      Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: isPlaying ? _stopSound : _playSound,
                ),
                // Кнопка для добавления точки останова
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addBreakpoint,
                ),
              ],
            ),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (double value) async {
                    await player.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  children: breakpoints.asMap().entries.map((entry) {
                    final index = entry.key;
                    final breakpoint = entry.value;
                    final breakpointPosition =
                        breakpoint.position.inSeconds.toDouble();
                    final percent = breakpointPosition / duration.inSeconds;
                    return GestureDetector(
                      onHorizontalDragStart: (details) {
                        // Начало перетаскивания
                        setState(() {
                          draggingBreakpointIndex = index;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        // Обновление позиции точки останова
                        final newPosition = details.globalPosition.dx /
                            MediaQuery.of(context).size.width;
                        setState(() {
                          breakpoints[index] = breakpoint.copyWith(
                            position: Duration(
                                seconds:
                                    (duration.inSeconds * newPosition).toInt()),
                          );
                        });
                      },
                      onHorizontalDragEnd: (details) {
                        // Конец перетаскивания
                        setState(() {
                          draggingBreakpointIndex = null;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * percent -
                                10),
                        child: CustomPaint(
                          painter: TrianglePainter(
                            strokeColor: draggingBreakpointIndex == index
                                ? Colors.blue
                                : Colors.red,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(position)),
                  Text(formatDuration(duration)),
                ],
              ),
            ),
            // Список точек останова
            Expanded(
              child: ListView.builder(
                itemCount: breakpoints.length,
                itemBuilder: (context, index) {
                  final breakpoint = breakpoints[index];
                  return ListTile(
                    title: Text(breakpoint.name),
                    subtitle: Text(breakpoint.description),
                    onTap: () {
                      // Переход к точке останова
                      player.seek(breakpoint.position);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

// Класс для рисования треугольника
class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  TrianglePainter({required this.strokeColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// Класс для хранения информации о точке останова
class Breakpoint {
  final String name;
  final String description;
  final Duration position;

  Breakpoint({
    required this.name,
    required this.description,
    required this.position,
  });

  // Метод для создания копии объекта с измененными параметрами
  Breakpoint copyWith({
    String? name,
    String? description,
    Duration? position,
  }) {
    return Breakpoint(
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
    );
  }
}
