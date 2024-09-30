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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 100,
                  icon:
                      Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
                  onPressed: isPlaying ? _pauseSound : _playSound,
                ),
                // Кнопка для добавления точки останова
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.add_circle),
                  onPressed: _addBreakpoint,
                ),
              ],
            ),
            // Внутри Stack, где отрисовываются точки останова
            LayoutBuilder(
              builder: (context, constraints) {
                // constraints.maxWidth - это ширина слайдера
                return Stack(
                  children: [
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (double value) async {
                        await player.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    ...breakpoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final breakpoint = entry.value;
                      final breakpointPosition =
                          breakpoint.position.inSeconds.toDouble();

                      // Вычисляем точное процентное положение точки останова
                      final percent = duration.inSeconds == 0
                          ? 0
                          : breakpointPosition / duration.inSeconds;

                      // Рассчитываем точную позицию треугольника, учитывая ширину слайдера и padding
                      final sliderTrackWidth = constraints.maxWidth - 48;
                      final triangleLeftPosition =
                          sliderTrackWidth * percent + 14; //

                      // Ограничиваем позицию треугольника в пределах слайдера
                      final constrainedPosition = triangleLeftPosition.clamp(
                          0.0, sliderTrackWidth + 14);

                      return Positioned(
                        left:
                            constrainedPosition, // Ограниченная позиция треугольника
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            setState(() {
                              draggingBreakpointIndex = index;
                            });
                          },
                          onHorizontalDragUpdate: (details) {
                            final renderBox =
                                context.findRenderObject() as RenderBox;
                            final localPosition = renderBox
                                .globalToLocal(details.globalPosition)
                                .dx;

                            // Рассчитываем новое положение точки как процент от ширины слайдера
                            final newPositionPercent =
                                (localPosition) / sliderTrackWidth;
                            final newPosition = Duration(
                                seconds:
                                    (duration.inSeconds * newPositionPercent)
                                        .toInt());

                            setState(() {
                              if (newPosition >= Duration.zero &&
                                  newPosition <= duration) {
                                breakpoints[index] = breakpoints[index]
                                    .copyWith(position: newPosition);
                              }
                            });
                          },
                          onHorizontalDragEnd: (details) {
                            setState(() {
                              draggingBreakpointIndex = null;
                            });
                          },
                          child: SizedBox(
                            height: 40,
                            width: 20,
                            child: CustomPaint(
                              painter: TrianglePainter(
                                strokeColor: draggingBreakpointIndex == index
                                    ? Colors.red
                                    : Colors.blue,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
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
                  return Card(
                    child: ListTile(
                      title: Text(breakpoint.name),
                      subtitle: Text(breakpoint.description),
                      onTap: () {
                        // Переход к точке останова
                        player.seek(breakpoint.position);
                      },
                      // Добавляем trailing для отображения кнопки редактирования
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Открываем диалог для редактирования точки останова
                          _editBreakpoint(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Функция для редактирования точки останова
  void _editBreakpoint(int index) {
    // Ставим на паузу при открытии диалога
    if (isPlaying) {
      _pauseSound();
    }

    // Создаем копию точки останова для редактирования
    Breakpoint editedBreakpoint = breakpoints[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать точку останова'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(labelText: 'Название'),
                controller: TextEditingController(text: editedBreakpoint.name),
                onChanged: (value) {
                  editedBreakpoint = editedBreakpoint.copyWith(name: value);
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Описание'),
                controller:
                    TextEditingController(text: editedBreakpoint.description),
                onChanged: (value) {
                  editedBreakpoint =
                      editedBreakpoint.copyWith(description: value);
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
              child: const Text('Сохранить'),
              onPressed: () {
                setState(() {
                  breakpoints[index] = editedBreakpoint;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

class TrianglePainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  TrianglePainter({required this.strokeColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.fill; // Используем заливку для треугольника

    // Рисуем треугольник с острой вершиной вниз
    final path = Path();
    path.moveTo(size.width / 2, size.height - 20); // Вершина треугольника внизу
    path.lineTo(size.width, 0); // Правая сторона треугольника
    path.lineTo(0, 0); // Левая сторона треугольника
    path.close(); // Закрываем путь для треугольника

    canvas.drawPath(path, paint); // Рисуем треугольник
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
