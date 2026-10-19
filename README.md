# cat_sound

**Life is... Skipping rope** — десктопный аудиоплеер с системой именованных «точек останова» для разметки звуковых дорожек.

A desktop audio player with named breakpoints for annotating audio tracks.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?logo=dart&logoColor=white)](https://dart.dev)

---

## 🇷🇺 Русский

### Описание

Приложение позволяет подгрузить два аудиофайла (слоты **«+»** и **«−»**), расставить на
таймлайне именованные точки останова и сохранить их рядом с треком в отдельный файл
`<имя_трека>.pstn` (JSON). При следующем выборе этого же файла метки подгружаются
автоматически — разметка хранится вместе со звуком, а не внутри приложения.

Файлы `.pstn` помечаются скрытыми (`attrib +h`), поэтому не засоряют папку с музыкой.
В первую очередь приложение рассчитано на Windows (разделение путей по `\`, команда
`attrib`), остальные платформы собираются штатно через Flutter.

### Возможности

- Два слота для аудиофайлов с быстрым переключением чипами, выбор файла через диалог
- Воспроизведение/пауза (кнопка и **пробел**), перемотка в начало, слайдер позиции
- Точки останова: добавление (название + описание), редактирование, удаление
- Точки рисуются треугольниками над слайдером, **перетаскиваются мышью** и
  сортируются по позиции; клик по пункту списка — перемотка к точке
- Сохранение/загрузка меток: `<имя_трека>.pstn` рядом с аудиофайлом, JSON
  (`name`, `description`, `position` в миллисекундах)
- Точки подгружаются автоматически при выборе трека

### Технологии

- **Flutter** (десктоп + мобильные + web)
- [audioplayers](https://pub.dev/packages/audioplayers) — воспроизведение аудио
- [file_picker](https://pub.dev/packages/file_picker) — выбор файлов
- [path](https://pub.dev/packages/path), `dart:convert`, `dart:io` — работа с файлами

### Структура проекта

```
cat_sound/
├── lib/
│   ├── main.dart        # точка входа, MaterialApp, тема
│   └── page.dart        # плеер, выбор файлов, работа с точками останова
├── assets/              # иконка, фон, демо-аудио
├── windows/ linux/ macos/ web/ android/ ios/
└── pubspec.yaml
```

### Запуск

```bash
flutter pub get
flutter run -d windows    # или любая другая целевая платформа
```

---

## 🇬🇧 English

### Overview

Load two audio files (slots **«+»** and **«−»**), put named breakpoints on the timeline
and save them next to the track as `<track_name>.pstn` (JSON). When the same file is
picked again, breakpoints are loaded automatically — annotations live beside the sound
instead of inside the app.

`.pstn` files are marked hidden (`attrib +h`) to keep the music folder clean. The app is
primarily Windows-targeted (backslash path handling, `attrib`), other platforms build
normally via Flutter.

### Features

- Two audio slots with chip-based switching, file dialog picker
- Play/pause (button and **Space**), restart, position slider
- Breakpoints: add (name + description), edit, delete
- Breakpoints drawn as triangles above the slider, **draggable** with the mouse;
  clicking a list entry seeks to that point
- Save/load: `<track_name>.pstn` JSON next to the audio file
  (`name`, `description`, `position` in milliseconds)
- Breakpoints auto-load when a track is selected

### Tech stack

- **Flutter** (desktop + mobile + web)
- [audioplayers](https://pub.dev/packages/audioplayers) — audio playback
- [file_picker](https://pub.dev/packages/file_picker) — file selection
- [path](https://pub.dev/packages/path), `dart:convert`, `dart:io` — file handling

### Project structure

```
cat_sound/
├── lib/
│   ├── main.dart        # entry point, MaterialApp, theme
│   └── page.dart        # player, file picking, breakpoint logic
├── assets/              # icon, background, demo audio
├── windows/ linux/ macos/ web/ android/ ios/
└── pubspec.yaml
```

### Getting started

```bash
flutter pub get
flutter run -d windows    # or any other target platform
```
