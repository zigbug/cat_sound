# 🎤 Skipping Rope Player

Flutter-приложение для обучения пению. Загружайте две дорожки (плюс и минус песни) и тренируйте свой вокал, переключаясь между ними.

[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Особенности

- 🎵 **Две дорожки одновременно** - загрузите версию с вокалом (+) и инструментальную версию (-)
- 🎤 **Обучение пению** - переключайтесь между треками для тренировки вокала
- 📍 **Точки останова (Breakpoints)** - создавайте метки на сложных участках песни
- ⏯️ **Управление воспроизведением** - Play, Pause, перемотка в начало
- 💾 **Сохранение точек останова** - автоматическое сохранение в файл `.pstn`
- 🎨 **Красивый UI** - современный Material Design 3 интерфейс
- 🎹 **Горячие клавиши** - поддержка пробела для Play/Pause
- 📁 **Выбор файлов** - встроенный файловый менеджер через `file_picker`
- 🖼️ **Перетаскивание точек** - drag & drop для изменения позиции меток

---

## 🎯 Как использовать

**Skipping Rope Player** создан для того, чтобы вы могли учиться петь вместе с любимыми песнями:

1. **Загрузите трек +** - версия с оригинальным вокалом
2. **Загрузите трек -** - инструментальная версия (минусовка)
3. **Создайте точки останова** - отметьте сложные места в песне
4. **Тренируйтесь** - переключайтесь между дорожками, повторяя за вокалистом
5. **Сохраняйте прогресс** - точки останова сохраняются для повторной тренировки

---

## 🏗 Архитектура

Проект построен на принципах **Clean Architecture** с использованием паттерна **BLoC** (Business Logic Component).

```
lib/
├── main.dart                          # Точка входа, настройка BLoC Provider
├── bloc/                              # Бизнес-логика
│   ├── audio_bloc.dart                # Главный BLoC
│   ├── audio_event.dart               # События (10 типов)
│   └── audio_state.dart               # Состояния
├── pages/                             # Экраны приложения
│   └── main_page.dart                 # Главный экран
├── models/                            # Модели данных
│   └── breakpoint.dart                # Модель точки останова
├── services/                          # Сервисы
│   └── file_storage_service.dart      # Работа с файловой системой
├── utils/                             # Утилиты
│   └── audio_utility.dart             # Работа с аудио
└── widgets/                           # Переиспользуемые виджеты
    ├── add_breakpoint_button.dart
    ├── audio_controls_widget.dart
    ├── audio_slider_widget.dart
    ├── breakpoint_list_widget.dart
    ├── save_breakpoints_button.dart
    ├── time_display_widget.dart
    ├── track_selector_widget.dart
    └── triangle_painter_widget.dart
```

### BLoC Events

| Событие | Описание |
|---------|----------|
| `AudioFileSelected` | Выбор аудиофайла (трек + или -) |
| `AudioPlayRequested` | Запуск воспроизведения |
| `AudioPauseRequested` | Пауза воспроизведения |
| `AudioSeekToStartRequested` | Перемотка в начало |
| `AudioSeekToPositionRequested` | Перемотка к позиции |
| `AudioBreakpointAdded` | Добавление точки останова |
| `AudioBreakpointEdited` | Редактирование точки |
| `AudioBreakpointDeleted` | Удаление точки |
| `AudioTrackSelected` | Переключение между треками (+ / -) |
| `AudioBreakpointsSaved` | Сохранение точек в файл |
| `AudioBreakpointsLoaded` | Загрузка точек из файла |

---

## 📦 Зависимости

| Пакет | Версия | Описание |
|-------|--------|----------|
| `flutter_bloc` | ^8.1.3 | Управление состоянием BLoC |
| `bloc` | ^8.1.4 | Базовая библиотека BLoC |
| `equatable` | ^2.0.5 | Сравнение объектов |
| `audioplayers` | ^6.1.0 | Воспроизведение аудио |
| `file_picker` | ^8.1.2 | Выбор файлов |
| `path` | ^1.9.0 | Работа с путями |

---

## 🚀 Установка

### Требования

- Flutter SDK >= 3.0
- Dart SDK >= 3.0
- Windows 10+ / macOS / Linux / Android / iOS

### Шаги

1. **Клонируйте репозиторий:**
   ```bash
   git clone https://github.com/ваш-username/cat_sound.git
   cd cat_sound
   ```

2. **Установите зависимости:**
   ```bash
   flutter pub get
   ```

3. **Запустите приложение:**
   ```bash
   flutter run
   ```

### Сборка для production

```bash
# Windows
flutter build windows --release

# Android
flutter build apk --release

# Web
flutter build web --release
```

---

## 📖 Использование

1. **Загрузите трек +** - нажмите на иконку папки `+` и выберите версию с вокалом
2. **Загрузите трек -** - нажмите на иконку папки `-` и выберите инструментальную версию
3. **Выберите трек** - нажмите на чипс трека для переключения между + и -
4. **Управляйте воспроизведением** - используйте кнопки Play/Pause
5. **Добавляйте точки останова** - нажмите кнопку `+` во время воспроизведения, чтобы отметить сложный участок
6. **Редактируйте точки** - нажмите на иконку карандаша в списке точек
7. **Перемещайте точки** - перетащите треугольник на слайдере
8. **Сохраняйте точки** - нажмите кнопку "Сохранить точки" для сохранения меток
9. **Тренируйтесь** - переключайтесь между дорожками, повторяя вокальную партию

### Горячие клавиши

- **Пробел** - Play / Pause

---

## 🎨 Дизайн

Приложение использует Material Design 3 с кастомной цветовой схемой:

- **Primary цвет:** `Color(0xFF78E9E7)` - бирюзовый
- **Фон:** Кастомное изображение (размещается в `assets/bckgrnd.png`)
- **Трек +:** Обозначается символом `+` - версия с вокалом
- **Трек -:** Обозначается символом `-` - инструментальная версия

---

## 📝 Формат файла точек останова

Точки останова сохраняются в формате JSON с расширением `.pstn`:

```json
[
  {
    "name": "Куплет 1",
    "description": "Первый куплет песни",
    "position": 15000
  },
  {
    "name": "Припев",
    "description": "Основной припев",
    "position": 45000
  }
]
```

- `name` - название точки
- `description` - описание
- `position` - позиция в миллисекундах

---

## 🧪 Тестирование

```bash
# Запуск юнит-тестов
flutter test

# Запуск тестов с покрытием
flutter test --coverage
```

---

## 🤝 Вклад

1. Fork проект
2. Создайте ветку для вашей фичи (`git checkout -b feature/AmazingFeature`)
3. Закоммитьте изменения (`git commit -m 'Add some AmazingFeature'`)
4. Пушните в ветку (`git push origin feature/AmazingFeature`)
5. Откройте Pull Request

---

## 📄 Лицензия

Этот проект распространяется под лицензией MIT. Смотрите файл [LICENSE](LICENSE) для деталей.

---

## 🙏 Благодарности

- [Flutter](https://flutter.dev) - кроссплатформенный фреймворк
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - управление состоянием
- [audioplayers](https://pub.dev/packages/audioplayers) - воспроизведение аудио
- [file_picker](https://pub.dev/packages/file_picker) - выбор файлов

---

## 📞 Контакты

Если у вас есть вопросы или предложения, создайте [issue](https://github.com/ваш-username/cat_sound/issues) или свяжитесь через [email](mailto:ваш-email@example.com).

---

<p align="center">Сделано с ❤️ на Flutter</p>
