import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Сервис для работы с файловой системой: чтение, запись, сохранение точек останова
class FileStorageService {
  /// Сохраняет точки останова в файл
  Future<void> saveBreakpoints(String trackPath, List<Map<String, dynamic>> breakpoints) async {
    try {
      // Создаем имя файла для сохранения точек останова
      String fileName = '${path.basenameWithoutExtension(trackPath)}.pstn';
      String filePath = path.join(path.dirname(trackPath), fileName);

      // Преобразуем список точек останова в JSON
      String breakpointsJson = jsonEncode(breakpoints);

      // Записываем JSON в файл
      await File(filePath).writeAsString(breakpointsJson);
      
      // Делаем файл скрытым (только для Windows)
      if (Platform.isWindows) {
        await Process.run('attrib', ['+h', filePath]);
      }
      
      return; // Возвращаем путь к файлу
    } catch (e) {
      rethrow;
    }
  }

  /// Загружает точки останова из файла
  Future<List<Map<String, dynamic>>?> loadBreakpoints(String trackPath) async {
    try {
      // Создаем имя файла для загрузки точек останова
      String fileName = '${path.basenameWithoutExtension(trackPath)}.pstn';
      String filePath = path.join(path.dirname(trackPath), fileName);

      // Проверяем, существует ли файл
      if (await File(filePath).exists()) {
        // Читаем JSON из файла
        String jsonString = await File(filePath).readAsString();
        List<dynamic> breakpointsJson = jsonDecode(jsonString);

        // Преобразуем JSON в список карт
        return breakpointsJson
            .map((breakpointJson) => {
                  'name': breakpointJson['name'],
                  'description': breakpointJson['description'],
                  'position': breakpointJson['position'],
                })
            .toList();
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
