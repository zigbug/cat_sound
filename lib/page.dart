import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

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

  // Названия треков
  String trackName1 = 'Выберите файл +';
  String trackName2 = 'Выберите файл -';

  // Выбранный трек (1 или 2)
  int selectedTrack = 1;

  // Списки точек останова для каждого трека
  List<Breakpoint> breakpoints1 = [];
  List<Breakpoint> breakpoints2 = [];

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

  // Функция для сохранения точек останова в файл
  Future<void> _saveBreakpoints(String trackPath) async {
    try {
      // Получаем список точек останова для текущего трека
      List<Breakpoint> currentBreakpoints =
          selectedTrack == 1 ? breakpoints1 : breakpoints2;

      // Преобразуем список точек останова в JSON
      List<Map<String, dynamic>> breakpointsJson = currentBreakpoints
          .map((breakpoint) => {
                'name': breakpoint.name,
                'description': breakpoint.description,
                'position': breakpoint.position.inMilliseconds,
              })
          .toList();

      // Создаем имя файла для сохранения точек останова
      String fileName = path.basenameWithoutExtension(trackPath) + '.pstn';
      String filePath = path.join(path.dirname(trackPath), fileName);

      // Записываем JSON в файл
      await File(filePath).writeAsString(jsonEncode(breakpointsJson));

      print('Точки останова сохранены в: $filePath');
    } catch (e) {
      print('Ошибка при сохранении точек останова: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении точек останова')),
      );
    }
  }

  // Функция для загрузки точек останова из файла
  Future<void> _loadBreakpoints(String trackPath) async {
    try {
      // Создаем имя файла для загрузки точек останова
      String fileName = path.basenameWithoutExtension(trackPath) + '.pstn';
      String filePath = path.join(path.dirname(trackPath), fileName);

      // Проверяем, существует ли файл
      if (await File(filePath).exists()) {
        // Читаем JSON из файла
        String jsonString = await File(filePath).readAsString();
        List<dynamic> breakpointsJson = jsonDecode(jsonString);

        // Преобразуем JSON в список точек останова
        List<Breakpoint> loadedBreakpoints = breakpointsJson
            .map((breakpointJson) => Breakpoint(
                  name: breakpointJson['name'],
                  description: breakpointJson['description'],
                  position: Duration(milliseconds: breakpointJson['position']),
                ))
            .toList();

        // Обновляем список точек останова для текущего трека
        setState(() {
          if (selectedTrack == 1) {
            breakpoints1 = loadedBreakpoints;
          } else {
            breakpoints2 = loadedBreakpoints;
          }
        });

        print('Точки останова загружены из: $filePath');
      } else {
        print('Файл с точками останова не найден: $filePath');
      }
    } catch (e) {
      print('Ошибка при загрузке точек останова: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке точек останова')),
      );
    }
  }

  Future<void> _playSound() async {
    try {
      // Определяем, какой трек проигрывать
      String currentTrackName = selectedTrack == 1 ? trackName1 : trackName2;

      // Если трек выбран, проигрываем его
      if (currentTrackName != 'Выберите файл +' &&
          currentTrackName != 'Выберите файл -') {
        await player.play(DeviceFileSource(currentTrackName));
        setState(() {
          isPlaying = true;
        });
      }
    } catch (e) {
      // Обработка ошибок при проигрывании
      print('Ошибка при проигрывании: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при проигрывании: $e')),
      );
    }
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

  // Функция для перемотки в начало трека
  Future<void> _seekToStart() async {
    await player.seek(Duration.zero);
  }

  // Функция для выбора файла с помощью file_picker
  Future<void> _pickAudioFile(int trackNumber) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null) {
        String trackPath = result.files.single.path!;
        setState(() {
          if (trackNumber == 1) {
            trackName1 = result.files.single.path!;
          } else {
            trackName2 = result.files.single.path!;
          }
        });
        // Загружаем точки останова после выбора трека
        _loadBreakpoints(trackPath);
      }
    } catch (e) {
      // Обработка ошибок при выборе файла
      print('Ошибка при выборе файла: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе файла: $e')),
      );
    }
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
                  // Добавляем точку останова в соответствующий список
                  if (selectedTrack == 1) {
                    breakpoints1.add(Breakpoint(
                      name: name,
                      description: description,
                      position: position,
                    ));
                  } else {
                    breakpoints2.add(Breakpoint(
                      name: name,
                      description: description,
                      position: position,
                    ));
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Функция для редактирования точки останова
  void _editBreakpoint(int index) {
    // Ставим на паузу при открытии диалога
    if (isPlaying) {
      _pauseSound();
    }

    // Определяем, к какому списку относится точка останова
    List<Breakpoint> currentBreakpoints =
        selectedTrack == 1 ? breakpoints1 : breakpoints2;

    // Создаем копию точки останова для редактирования
    Breakpoint editedBreakpoint = currentBreakpoints[index];

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
                  currentBreakpoints[index] = editedBreakpoint;
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
    // Определяем текущий список точек останова
    List<Breakpoint> currentBreakpoints =
        selectedTrack == 1 ? breakpoints1 : breakpoints2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Чипсы для выбора трека
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      InputChip(
                        label: Text(trackName1 == 'Выберите файл +'
                            ? '+'
                            : trackName1.split('\\').last),
                        onPressed: () {
                          setState(() {
                            selectedTrack = 1;
                          });
                        },
                        selected: selectedTrack == 1,
                      ),
                      InkWell(
                        // Используем InkWell для эффекта нажатия
                        onTap: () => _pickAudioFile(1),
                        borderRadius:
                            BorderRadius.circular(20.0), // Закругляем кнопку
                        child: Container(
                          padding:
                              const EdgeInsets.all(4.0), // Добавляем отступы
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Делаем кнопку круглой
                            color: Colors.grey, // Цвет фона кнопки
                          ),
                          child: const Icon(
                            Icons.folder,
                            color: Colors.white, // Цвет иконки
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InputChip(
                        label: Text(trackName2 == 'Выберите файл -'
                            ? '-'
                            : trackName2.split('\\').last),
                        onPressed: () {
                          setState(() {
                            selectedTrack = 2;
                          });
                        },
                        selected: selectedTrack == 2,
                      ),
                      InkWell(
                        // Используем InkWell для эффекта нажатия
                        onTap: () => _pickAudioFile(2),
                        borderRadius:
                            BorderRadius.circular(20.0), // Закругляем кнопку
                        child: Container(
                          padding:
                              const EdgeInsets.all(4.0), // Добавляем отступы
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle, // Делаем кнопку круглой
                            color: Colors.grey, // Цвет фона кнопки
                          ),
                          child: const Icon(
                            Icons.folder,
                            color: Colors.white, // Цвет иконки
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Кнопка для сохранения точек останова
                  ElevatedButton(
                    onPressed: () {
                      // Сохраняем точки останова для текущего трека
                      if (selectedTrack == 1 &&
                          trackName1 != 'Выберите файл +') {
                        _saveBreakpoints(trackName1);
                      } else if (selectedTrack == 2 &&
                          trackName2 != 'Выберите файл -') {
                        _saveBreakpoints(trackName2);
                      }
                    },
                    child: const Text('Сохранить точки останова'),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Кнопка "В начало"
                IconButton(
                  iconSize: 50,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _seekToStart,
                ),
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
                    ...currentBreakpoints.asMap().entries.map((entry) {
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
                                currentBreakpoints[index] =
                                    currentBreakpoints[index]
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
                itemCount: currentBreakpoints.length,
                itemBuilder: (context, index) {
                  final breakpoint = currentBreakpoints[index];
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
